import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile/domain/models/board_card.dart';
import 'package:mobile/viewmodels/boards_viewmodel.dart';
import 'package:mobile/viewmodels/lists_viewmodel.dart';
import 'package:mobile/viewmodels/cards_viewmodel.dart';
import 'package:mobile/screens/activity.dart';
import 'package:mobile/screens/card_detail.dart';
import 'package:mobile/l10n/app_localizations.dart';

/// Pano detay (Kanban görünümü) — referans: panoların-içi.jpeg
/// Yatay kaydırma ile sütunlar (listeler), her sütunda dikey kart listesi.
/// Constructor ile boardId alır (Navigator ID taşıma kuralı).
class BoardDetailScreen extends StatefulWidget {
  final String boardId;
  final String boardName; // Sadece fallback olarak

  const BoardDetailScreen({
    super.key,
    required this.boardId,
    required this.boardName,
  });

  @override
  State<BoardDetailScreen> createState() => _BoardDetailScreenState();
}

class _BoardDetailScreenState extends State<BoardDetailScreen> {
  String? _activeDropListId;
  bool _isFiltering = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        context.read<ListsViewModel>().fetchLists(widget.boardId);
        context.read<CardsViewModel>().fetchCards();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Consumer<BoardsViewModel>(
      builder: (context, boardsVM, child) {
        final board = boardsVM.boards.cast<dynamic>().firstWhere(
          (b) => b.id == widget.boardId,
          orElse: () => null,
        );

        return Scaffold(
          appBar: AppBar(
            title: _isFiltering
                ? TextField(
                    controller: _searchController,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: '${l10n.cards} ${l10n.save.toLowerCase()}...', // Using a mix for now if no specific search hint
                      border: InputBorder.none,
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value.toLowerCase();
                      });
                    },
                  )
                : Text(
                    board?.name ?? widget.boardName,
                    overflow: TextOverflow.ellipsis,
                  ),
            actions: [
              IconButton(
                icon: const Icon(Icons.timeline_outlined),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ActivityScreen(
                      boardId: widget.boardId,
                      boardName: widget.boardName,
                      initialScope: ActivityScope.board,
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.format_paint_outlined),
                onPressed: () => _showBackgroundPicker(context),
              ),
              IconButton(
                icon: Icon(_isFiltering ? Icons.filter_list_off : Icons.filter_list),
                onPressed: () {
                  setState(() {
                    if (_isFiltering) {
                      _isFiltering = false;
                      _searchQuery = '';
                      _searchController.clear();
                    } else {
                      _isFiltering = true;
                    }
                  });
                },
              ),
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () => _showNotificationSettings(context),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    _showEditBoardDialog(context, l10n);
                  } else if (value == 'delete') {
                    _showDeleteBoardDialog(context, l10n);
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        const Icon(Icons.edit, size: 20),
                        const SizedBox(width: 8),
                        Text(l10n.save), // Placeholder
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        const Icon(Icons.delete, color: Colors.red, size: 20),
                        const SizedBox(width: 8),
                        Text(l10n.deleteWorkspaceTitle.replaceAll(l10n.workspaces, l10n.boards).replaceAll('Workspace', 'Board'), style: const TextStyle(color: Colors.red)), // Hack for Delete Board if no key
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          body: Container(
            decoration: _buildBoardBackgroundDecoration(
              context,
              board?.backgroundImage as String?,
            ),
            child: Consumer2<ListsViewModel, CardsViewModel>(
              builder: (context, listsVM, cardsVM, child) {
                if (listsVM.isLoading && listsVM.lists.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (listsVM.errorMessage != null && listsVM.lists.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(listsVM.errorMessage!),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: () => listsVM.fetchLists(widget.boardId),
                          icon: const Icon(Icons.refresh),
                          label: Text(l10n.save), // Generic retry
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(8),
                  itemCount: listsVM.lists.length + 1,
                  itemBuilder: (context, listIndex) {
                    if (listIndex == listsVM.lists.length) {
                      return Container(
                        width: 280,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        child: Card(
                          child: InkWell(
                            onTap: () => _showAddListDialog(context, l10n),
                            child: Center(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.add),
                                  const SizedBox(width: 8),
                                  Text("${l10n.add} ${l10n.listName}"),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }

                    final list = listsVM.lists[listIndex];
                    var listCards = cardsVM.getCardsForList(list.id);
                    if (_searchQuery.isNotEmpty) {
                      listCards = listCards.where((c) => c.title.toLowerCase().contains(_searchQuery)).toList();
                    }

                    return DragTarget<BoardCard>(
                      onWillAcceptWithDetails: (details) {
                        setState(() => _activeDropListId = list.id);
                        return true;
                      },
                      onLeave: (_) {
                        if (_activeDropListId == list.id) {
                          setState(() => _activeDropListId = null);
                        }
                      },
                      onAcceptWithDetails: (details) {
                        _handleCardDrop(
                          context,
                          cardsVM,
                          details.data,
                          list.id,
                        );
                      },
                      builder: (context, candidateData, rejectedData) {
                        final isActiveTarget =
                            _activeDropListId == list.id ||
                            candidateData.isNotEmpty;

                        return Container(
                          width: 280,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 120),
                            decoration: BoxDecoration(
                              color: isActiveTarget
                                  ? Theme.of(context)
                                        .colorScheme
                                        .surfaceContainerHighest
                                        .withValues(alpha: 0.5)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isActiveTarget
                                    ? Theme.of(context).colorScheme.primary
                                    : Colors.transparent,
                              ),
                            ),
                            child: Card(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      16,
                                      12,
                                      8,
                                      8,
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            list.name,
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium
                                                ?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        PopupMenuButton<String>(
                                          icon: const Icon(
                                            Icons.more_vert,
                                            size: 20,
                                          ),
                                          onSelected: (value) {
                                            if (value == 'edit') {
                                              _showEditListDialog(
                                                context,
                                                l10n,
                                                list,
                                              );
                                            } else if (value == 'delete') {
                                              _showDeleteListDialog(
                                                context,
                                                l10n,
                                                list,
                                              );
                                            }
                                          },
                                          itemBuilder: (context) => [
                                            PopupMenuItem(
                                              value: 'edit',
                                              child: Row(
                                                children: [
                                                  const Icon(Icons.edit, size: 20),
                                                  const SizedBox(width: 8),
                                                  Text(l10n.editList),
                                                ],
                                              ),
                                            ),
                                            PopupMenuItem(
                                              value: 'delete',
                                              child: Row(
                                                children: [
                                                  const Icon(
                                                    Icons.delete,
                                                    color: Colors.red,
                                                    size: 20,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    l10n.deleteWorkspaceTitle.replaceAll(l10n.workspaces, l10n.listName).replaceAll('Workspace', 'List'),
                                                    style: const TextStyle(
                                                      color: Colors.red,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: ListView.builder(
                                      physics: const BouncingScrollPhysics(),
                                      padding: const EdgeInsets.all(8),
                                      itemCount: listCards.length,
                                      itemBuilder: (context, cardIndex) {
                                        final card = listCards[cardIndex];
                                        return LongPressDraggable<BoardCard>(
                                          data: card,
                                          feedback: Material(
                                            color: Colors.transparent,
                                            child: SizedBox(
                                              width: 240,
                                              child: Builder(
                                                builder: (innerContext) =>
                                                    _buildCardTile(
                                                  innerContext,
                                                  card,
                                                ),
                                              ),
                                            ),
                                          ),
                                          childWhenDragging: Opacity(
                                            opacity: 0.35,
                                            child: Builder(
                                              builder: (innerContext) =>
                                                  _buildCardTile(
                                                innerContext,
                                                card,
                                              ),
                                            ),
                                          ),
                                          child: Builder(
                                            builder: (innerContext) =>
                                                _buildCardTile(
                                              innerContext,
                                              card,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: TextButton.icon(
                                      onPressed: () =>
                                          _showAddCardDialog(context, list.id),
                                      icon: const Icon(Icons.add, size: 18),
                                      label: Text("${l10n.add} ${l10n.card.toLowerCase()}"),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildCardTile(BuildContext context, BoardCard card) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: InkWell(
        onTap: () {
          final board = context.read<BoardsViewModel>().boards.cast<dynamic>().firstWhere(
            (b) => b.id == widget.boardId,
            orElse: () => null,
          );
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CardDetailScreen(
                cardId: card.id,
                cardTitle: card.title,
                workspaceId: board?.workspaceId ?? '',
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Text(
            card.title,
            style: Theme.of(context).textTheme.bodyMedium,
            overflow: TextOverflow.ellipsis,
            maxLines: 3,
          ),
        ),
      ),
    );
  }

  BoxDecoration _buildBoardBackgroundDecoration(
    BuildContext context,
    String? backgroundImage,
  ) {
    final scheme = Theme.of(context).colorScheme;

    switch (backgroundImage) {
      case 'purple':
        return BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.purple.shade200, Colors.deepPurple.shade400],
          ),
        );
      case 'blue':
        return BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue.shade200, Colors.indigo.shade400],
          ),
        );
      case 'green':
        return BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.green.shade200, Colors.teal.shade400],
          ),
        );
      case 'orange':
        return BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.orange.shade200, Colors.deepOrange.shade400],
          ),
        );
      case 'pink':
        return BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.pink.shade200, Colors.redAccent.shade400],
          ),
        );
      case 'teal':
        return BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.teal.shade200, Colors.cyan.shade500],
          ),
        );
      case 'amber':
        return BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.amber.shade200, Colors.orange.shade500],
          ),
        );
      default:
        return BoxDecoration(color: scheme.surfaceContainerLowest);
    }
  }

  Future<void> _handleCardDrop(
    BuildContext context,
    CardsViewModel cardsVM,
    BoardCard card,
    String targetListId,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _activeDropListId = null);

    final success = await cardsVM.moveCardToList(
      cardId: card.id,
      targetListId: targetListId,
    );

    if (!context.mounted) return;

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(cardsVM.errorMessage ?? l10n.cardMoveFailed),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  // ==================== Board Dialogları ====================

  void _showNotificationSettings(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  l10n.notificationSettings,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.notifications_active),
                title: Text(l10n.allNotifications),
                subtitle: Text(l10n.notifyOnAllActivity),
                trailing: Switch(value: true, onChanged: (val) {}),
              ),
              ListTile(
                leading: const Icon(Icons.person),
                title: Text(l10n.cardAssignments),
                subtitle: Text(l10n.notifyOnPersonal),
                trailing: Switch(value: false, onChanged: (val) {}),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEditBoardDialog(BuildContext context, AppLocalizations l10n) {
    final boardsVM = context.read<BoardsViewModel>();
    final board = boardsVM.boards.cast<dynamic>().firstWhere(
      (b) => b.id == widget.boardId,
      orElse: () => null,
    );

    if (board == null) return;

    final controller = TextEditingController(text: board.name);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.editBoard),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: controller,
              decoration: InputDecoration(
                labelText: l10n.boardName,
                border: const OutlineInputBorder(),
              ),
              validator: (val) {
                if (val == null || val.trim().isEmpty) return l10n.nameRequired;
                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(l10n.cancel),
            ),
            Consumer<BoardsViewModel>(
              builder: (context, vm, child) {
                return FilledButton(
                  onPressed: vm.isLoading
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) return;
                          final success = await vm.updateBoard(
                            boardId: widget.boardId,
                            name: controller.text.trim(),
                          );
                          if (!context.mounted) return;
                          if (success) {
                            Navigator.pop(dialogContext);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(l10n.boardUpdated)),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(vm.errorMessage ?? l10n.error),
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.error,
                              ),
                            );
                          }
                        },
                  child: vm.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(l10n.save),
                );
              },
            ),
          ],
        );
      },
    );
  }

  void _showDeleteBoardDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text("${l10n.deleteBoardConfirm.split('?')[0].trim()}?"), // Fallback if no specific title
          content: Text(
            l10n.deleteBoardConfirm,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(l10n.cancel),
            ),
            Consumer<BoardsViewModel>(
              builder: (context, vm, child) {
                return FilledButton(
                  onPressed: vm.isLoading
                      ? null
                      : () async {
                          final success = await vm.deleteBoard(widget.boardId);
                          if (!context.mounted) return;
                          if (success) {
                            Navigator.pop(dialogContext);
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Pano silindi')),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(vm.errorMessage ?? 'Hata'),
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.error,
                              ),
                            );
                          }
                        },
                  style: FilledButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.error,
                  ),
                  child: vm.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Sil'),
                );
              },
            ),
          ],
        );
      },
    );
  }

  // ==================== List Dialogları ====================

  void _showAddListDialog(BuildContext context, AppLocalizations l10n) {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text("${l10n.add} ${l10n.listName}"),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: controller,
              decoration: InputDecoration(
                labelText: l10n.listName,
                border: OutlineInputBorder(),
              ),
              validator: (val) {
                if (val == null || val.trim().isEmpty) return l10n.nameRequired;
                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(l10n.cancel),
            ),
            Consumer<ListsViewModel>(
              builder: (context, vm, child) {
                return FilledButton(
                  onPressed: vm.isLoading
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) return;
                          final success = await vm.createList(
                            boardId: widget.boardId,
                            name: controller.text.trim(),
                          );
                          if (!context.mounted) return;
                          if (success) {
                            Navigator.pop(dialogContext);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(vm.errorMessage ?? 'Hata'),
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.error,
                              ),
                            );
                          }
                        },
                  child: vm.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Ekle'),
                );
              },
            ),
          ],
        );
      },
    );
  }

  void _showEditListDialog(BuildContext context, AppLocalizations l10n, dynamic list) {
    final controller = TextEditingController(text: list.name);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.editList),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: controller,
              decoration: InputDecoration(
                labelText: l10n.listName,
                border: OutlineInputBorder(),
              ),
              validator: (val) {
                if (val == null || val.trim().isEmpty) return l10n.nameRequired;
                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(l10n.cancel),
            ),
            Consumer<ListsViewModel>(
              builder: (context, vm, child) {
                return FilledButton(
                  onPressed: vm.isLoading
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) return;
                          final success = await vm.updateList(
                            listId: list.id,
                            name: controller.text.trim(),
                          );
                          if (!context.mounted) return;
                          if (success) {
                            Navigator.pop(dialogContext);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(vm.errorMessage ?? 'Hata'),
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.error,
                              ),
                            );
                          }
                        },
                  child: vm.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(l10n.save),
                );
              },
            ),
          ],
        );
      },
    );
  }

  void _showDeleteListDialog(
    BuildContext context,
    AppLocalizations l10n,
    dynamic list,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.deleteWorkspaceTitle.replaceAll(l10n.workspaces, l10n.listName)),
          content: Text(
            l10n.deleteListConfirm(list.name),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(l10n.cancel),
            ),
            Consumer<ListsViewModel>(
              builder: (context, vm, child) {
                return FilledButton(
                  onPressed: vm.isLoading
                      ? null
                      : () async {
                          final success = await vm.deleteList(list.id);
                          if (!context.mounted) return;
                          if (success) {
                            Navigator.pop(dialogContext);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(vm.errorMessage ?? 'Hata'),
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.error,
                              ),
                            );
                          }
                        },
                  style: FilledButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.error,
                  ),
                  child: vm.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Sil'),
                );
              },
            ),
          ],
        );
      },
    );
  }

  // ==================== Card Dialogları ====================

  void _showAddCardDialog(BuildContext context, String listId) {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text("${l10n.add} ${l10n.card}"),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: controller,
              decoration: InputDecoration(
                labelText: l10n.cardTitle,
                border: const OutlineInputBorder(),
              ),
              validator: (val) {
                if (val == null || val.trim().isEmpty) return l10n.titleRequired;
                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(l10n.cancel),
            ),
            Consumer<CardsViewModel>(
              builder: (context, vm, child) {
                return FilledButton(
                  onPressed: vm.isLoading
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) return;
                          final success = await vm.createCard(
                            listId: listId,
                            title: controller.text.trim(),
                          );
                          if (!context.mounted) return;
                          if (success) {
                            Navigator.pop(dialogContext);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(vm.errorMessage ?? 'Hata'),
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.error,
                              ),
                            );
                          }
                        },
                  child: vm.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Ekle'),
                );
              },
            ),
          ],
        );
      },
    );
  }

  // ==================== Background Seçici ====================

  void _showBackgroundPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        return Container(
          padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.boardBackground,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text('${l10n.colors}:', style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 8),
            SizedBox(
              height: 60,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildBackgroundOption(
                    context,
                    'none',
                    l10n.defaultOption,
                    Colors.grey.shade300,
                  ),
                  _buildBackgroundOption(
                    context,
                    'purple',
                    l10n.purple,
                    Colors.purple,
                  ),
                  _buildBackgroundOption(context, 'blue', l10n.blue, Colors.blue),
                  _buildBackgroundOption(
                    context,
                    'green',
                    l10n.green,
                    Colors.green,
                  ),
                  _buildBackgroundOption(
                    context,
                    'orange',
                    l10n.orange,
                    Colors.orange,
                  ),
                  _buildBackgroundOption(context, 'pink', l10n.pink, Colors.pink),
                  _buildBackgroundOption(
                    context,
                    'teal',
                    l10n.teal,
                    Colors.teal,
                  ),
                  _buildBackgroundOption(
                    context,
                    'amber',
                    l10n.yellow,
                    Colors.amber,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    },
    );
  }

  Widget _buildBackgroundOption(
    BuildContext context,
    String value,
    String label,
    Color color,
  ) {
    return GestureDetector(
      onTap: () async {
        final l10n = AppLocalizations.of(context)!;
        final boardsVM = context.read<BoardsViewModel>();
        final bgValue = value == 'none' ? null : value;
        final success = await boardsVM.updateBoard(
          boardId: widget.boardId,
          backgroundImage: bgValue,
        );
        if (!context.mounted) return;
        if (success) {
          Navigator.pop(context);
          return;
        }
        if (!success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                boardsVM.errorMessage ?? l10n.backgroundUpdateFailed,
              ),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      },
      child: Container(
        width: 60,
        height: 60,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline,
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: color.computeLuminance() > 0.5
                  ? Colors.black
                  : Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
