import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile/domain/models/board_card.dart';
import 'package:mobile/viewmodels/boards_viewmodel.dart';
import 'package:mobile/viewmodels/lists_viewmodel.dart';
import 'package:mobile/viewmodels/cards_viewmodel.dart';

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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer<BoardsViewModel>(
          builder: (context, boardsVM, child) {
            final board = boardsVM.boards.cast<dynamic>().firstWhere(
                  (b) => b.id == widget.boardId,
                  orElse: () => null,
                );
            return Text(
              board?.name ?? widget.boardName,
              overflow: TextOverflow.ellipsis,
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // TODO: Filtre
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Board bildirimleri
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit') {
                _showEditBoardDialog(context);
              } else if (value == 'delete') {
                _showDeleteBoardDialog(context);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 20),
                    SizedBox(width: 8),
                    Text('Panoyu Düzenle'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red, size: 20),
                    SizedBox(width: 8),
                    Text('Panoyu Sil', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Consumer2<ListsViewModel, CardsViewModel>(
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
                    label: const Text('Tekrar Dene'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(8),
            itemCount: listsVM.lists.length + 1,
            itemBuilder: (context, listIndex) {
              // Son eleman = "Liste Ekle" butonu
              if (listIndex == listsVM.lists.length) {
                return Container(
                  width: 280,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  child: Card(
                    child: InkWell(
                      onTap: () => _showAddListDialog(context),
                      child: const Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.add),
                            SizedBox(width: 8),
                            Text('Liste Ekle'),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }

              final list = listsVM.lists[listIndex];
              final listCards = cardsVM.getCardsForList(list.id);

              return Container(
                width: 280,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                child: Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Liste başlığı
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                list.name,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            PopupMenuButton<String>(
                              icon: const Icon(Icons.more_vert, size: 20),
                              onSelected: (value) {
                                if (value == 'edit') {
                                  _showEditListDialog(context, list);
                                } else if (value == 'delete') {
                                  _showDeleteListDialog(context, list);
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      Icon(Icons.edit, size: 20),
                                      SizedBox(width: 8),
                                      Text('Listeyi Düzenle'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete, color: Colors.red, size: 20),
                                      SizedBox(width: 8),
                                      Text('Listeyi Sil', style: TextStyle(color: Colors.red)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Kartlar listesi
                      Expanded(
                        child: DragTarget<BoardCard>(
                          onWillAcceptWithDetails: (details) {
                            final incomingCard = details.data;
                            if (incomingCard.listId == list.id) return false;
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
                                _activeDropListId == list.id || candidateData.isNotEmpty;

                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 120),
                              margin: const EdgeInsets.symmetric(horizontal: 8),
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
                              child: ListView.builder(
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
                                        child: _buildCardTile(context, card),
                                      ),
                                    ),
                                    childWhenDragging: Opacity(
                                      opacity: 0.35,
                                      child: _buildCardTile(context, card),
                                    ),
                                    child: _buildCardTile(context, card),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ),
                      // Kart ekle butonu
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: TextButton.icon(
                          onPressed: () => _showAddCardDialog(context, list.id),
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Kart ekle'),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildCardTile(BuildContext context, BoardCard card) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: InkWell(
        onTap: () => _showEditCardDialog(context, card),
        onLongPress: () => _showDeleteCardDialog(context, card),
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

  Future<void> _handleCardDrop(
    BuildContext context,
    CardsViewModel cardsVM,
    BoardCard card,
    String targetListId,
  ) async {
    setState(() => _activeDropListId = null);

    final success = await cardsVM.moveCardToList(
      cardId: card.id,
      targetListId: targetListId,
    );

    if (!context.mounted) return;

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(cardsVM.errorMessage ?? 'Kart taşınamadı'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  // ==================== Board Dialogları ====================

  void _showEditBoardDialog(BuildContext context) {
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
          title: const Text('Panoyu Düzenle'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Pano Adı',
                border: OutlineInputBorder(),
              ),
              validator: (val) {
                if (val == null || val.trim().isEmpty) return 'İsim gerekli';
                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('İptal'),
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
                              const SnackBar(content: Text('Pano güncellendi')),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(vm.errorMessage ?? 'Hata'),
                                backgroundColor: Theme.of(context).colorScheme.error,
                              ),
                            );
                          }
                        },
                  child: vm.isLoading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Kaydet'),
                );
              },
            ),
          ],
        );
      },
    );
  }

  void _showDeleteBoardDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Panoyu Sil'),
          content: const Text('Bu panoyu silmek istediğinize emin misiniz? Bu işlem geri alınamaz.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('İptal'),
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
                                backgroundColor: Theme.of(context).colorScheme.error,
                              ),
                            );
                          }
                        },
                  style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
                  child: vm.isLoading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
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

  void _showAddListDialog(BuildContext context) {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Yeni Liste Ekle'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Liste Adı',
                border: OutlineInputBorder(),
              ),
              validator: (val) {
                if (val == null || val.trim().isEmpty) return 'İsim gerekli';
                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('İptal'),
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
                                backgroundColor: Theme.of(context).colorScheme.error,
                              ),
                            );
                          }
                        },
                  child: vm.isLoading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Ekle'),
                );
              },
            ),
          ],
        );
      },
    );
  }

  void _showEditListDialog(BuildContext context, dynamic list) {
    final controller = TextEditingController(text: list.name);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Listeyi Düzenle'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Liste Adı',
                border: OutlineInputBorder(),
              ),
              validator: (val) {
                if (val == null || val.trim().isEmpty) return 'İsim gerekli';
                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('İptal'),
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
                                backgroundColor: Theme.of(context).colorScheme.error,
                              ),
                            );
                          }
                        },
                  child: vm.isLoading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Kaydet'),
                );
              },
            ),
          ],
        );
      },
    );
  }

  void _showDeleteListDialog(BuildContext context, dynamic list) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Listeyi Sil'),
          content: Text('${list.name} isimli listeyi silmek istediğinize emin misiniz?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('İptal'),
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
                                backgroundColor: Theme.of(context).colorScheme.error,
                              ),
                            );
                          }
                        },
                  style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
                  child: vm.isLoading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
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
    final titleController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Yeni Kart Ekle'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Kart Başlığı',
                border: OutlineInputBorder(),
              ),
              validator: (val) {
                if (val == null || val.trim().isEmpty) return 'Başlık gerekli';
                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('İptal'),
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
                            title: titleController.text.trim(),
                          );
                          if (!context.mounted) return;
                          if (success) {
                            Navigator.pop(dialogContext);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(vm.errorMessage ?? 'Hata'),
                                backgroundColor: Theme.of(context).colorScheme.error,
                              ),
                            );
                          }
                        },
                  child: vm.isLoading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Ekle'),
                );
              },
            ),
          ],
        );
      },
    );
  }

  void _showEditCardDialog(BuildContext context, dynamic card) {
    final titleController = TextEditingController(text: card.title);
    final descController = TextEditingController(text: card.description ?? '');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Kartı Düzenle'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Kart Başlığı',
                    border: OutlineInputBorder(),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'Başlık gerekli';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: descController,
                  decoration: const InputDecoration(
                    labelText: 'Açıklama',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('İptal'),
            ),
            Consumer<CardsViewModel>(
              builder: (context, vm, child) {
                return FilledButton(
                  onPressed: vm.isLoading
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) return;
                          final success = await vm.updateCard(
                            cardId: card.id,
                            title: titleController.text.trim(),
                            description: descController.text.trim(),
                          );
                          if (!context.mounted) return;
                          if (success) {
                            Navigator.pop(dialogContext);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(vm.errorMessage ?? 'Hata'),
                                backgroundColor: Theme.of(context).colorScheme.error,
                              ),
                            );
                          }
                        },
                  child: vm.isLoading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Kaydet'),
                );
              },
            ),
          ],
        );
      },
    );
  }

  void _showDeleteCardDialog(BuildContext context, dynamic card) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Kartı Sil'),
          content: Text('"${card.title}" kartını silmek istediğinize emin misiniz?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('İptal'),
            ),
            Consumer<CardsViewModel>(
              builder: (context, vm, child) {
                return FilledButton(
                  onPressed: vm.isLoading
                      ? null
                      : () async {
                          final success = await vm.deleteCard(card.id);
                          if (!context.mounted) return;
                          if (success) {
                            Navigator.pop(dialogContext);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(vm.errorMessage ?? 'Hata'),
                                backgroundColor: Theme.of(context).colorScheme.error,
                              ),
                            );
                          }
                        },
                  style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
                  child: vm.isLoading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Sil'),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
