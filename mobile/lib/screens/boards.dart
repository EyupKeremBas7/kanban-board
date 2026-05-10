import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile/viewmodels/boards_viewmodel.dart';
import 'package:mobile/viewmodels/workspaces_viewmodel.dart';
import 'package:mobile/viewmodels/navigation_viewmodel.dart';
import 'package:mobile/screens/board_detail.dart';
import 'package:mobile/l10n/app_localizations.dart';

/// Panolar listesi ekranı — referans: panolar.jpeg
/// BoardsViewModel üzerinden gerçek API verisi gösterir.
class BoardsScreen extends StatefulWidget {
  const BoardsScreen({super.key});

  @override
  State<BoardsScreen> createState() => _BoardsScreenState();
}

class _BoardsScreenState extends State<BoardsScreen> {
  bool _isSearching = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Ekran açılınca board listesini çek
    final boardsVM = context.read<BoardsViewModel>();
    Future.microtask(() => boardsVM.fetchBoards());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: '${l10n.boards} ara...',
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase();
                  });
                },
              )
            : Text(l10n.boards),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _isSearching = false;
                  _searchQuery = '';
                  _searchController.clear();
                } else {
                  _isSearching = true;
                }
              });
            },
          ),
          // Yenile butonu
          if (!_isSearching)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                context.read<BoardsViewModel>().fetchBoards();
              },
            ),
        ],
      ),
      body: Consumer<BoardsViewModel>(
        builder: (context, boardsVM, child) {
          // Loading state
          if (boardsVM.isLoading && boardsVM.boards.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          // Error state
          if (boardsVM.errorMessage != null && boardsVM.boards.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    boardsVM.errorMessage!,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () => boardsVM.fetchBoards(),
                    icon: const Icon(Icons.refresh),
                    label: Text(l10n.tryAgain),
                  ),
                ],
              ),
            );
          }

          // Empty state
          if (boardsVM.boards.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.dashboard_outlined,
                    size: 64,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.noBoardsFound,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.createFirstWorkspace.replaceAll(l10n.workspaces, l10n.boards), // Fallback if no specific createFirstBoard
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.4),
                    ),
                  ),
                ],
              ),
            );
          }

          // Board listesi — workspace'e göre grouped
          final navVM = context.watch<NavigationViewModel>();
          
          final filteredBoards = boardsVM.boards.where((b) {
            final matchesSearch = b.name.toLowerCase().contains(_searchQuery);
            final matchesWorkspace = navVM.selectedWorkspaceId == null || 
                                     b.workspaceId == navVM.selectedWorkspaceId;
            return matchesSearch && matchesWorkspace;
          }).toList();

          if (filteredBoards.isEmpty) {
            if (_searchQuery.isNotEmpty || navVM.selectedWorkspaceId != null) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Kriterlere uygun pano bulunamadı.'), // I'll keep this for now or find a key
                    if (navVM.selectedWorkspaceId != null)
                      TextButton(
                        onPressed: () => navVM.clearWorkspaceFilter(),
                        child: const Text('Filtreyi Temizle'),
                      ),
                  ],
                ),
              );
            }
          }

          return RefreshIndicator(
            onRefresh: () => boardsVM.fetchBoards(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredBoards.length,
              itemBuilder: (context, index) {
                final board = filteredBoards[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: board.backgroundImage != null
                        ? const Icon(Icons.image, size: 40)
                        : const Icon(Icons.dashboard, size: 40),
                    title: Text(
                      board.name,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    onTap: () {
                      // Navigator ile ID taşıma (Kural 6)
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BoardDetailScreen(
                            boardId: board.id,
                            boardName: board.name,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateBoardDialog(context, l10n),
        icon: const Icon(Icons.add),
        label: Text(l10n.createBoard),
      ),
    );
  }

  void _showCreateBoardDialog(BuildContext context, AppLocalizations l10n) {
    final nameController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    String? selectedWorkspaceId;

    final workspacesVM = context.read<WorkspacesViewModel>();

    // Dialog açılırken workspaces yoksa çek
    if (workspacesVM.workspaces.isEmpty) {
      workspacesVM.fetchWorkspaces();
    }

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(l10n.createBoardTitle),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: l10n.boardName,
                        border: const OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return l10n.nameRequired;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // Workspace seçimi
                    Consumer<WorkspacesViewModel>(
                      builder: (context, vm, child) {
                        if (vm.isLoading) {
                          return const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }

                        if (vm.workspaces.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(
                              l10n.mustCreateWorkspaceFirst,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                          );
                        }

                        // Eğer seçili yoksa ilkini seç
                        selectedWorkspaceId ??= vm.workspaces.first.id;

                        return DropdownButtonFormField<String>(
                          initialValue: selectedWorkspaceId,
                          decoration: InputDecoration(
                            labelText: l10n.workspaces,
                            border: const OutlineInputBorder(),
                          ),
                          items: vm.workspaces.map((ws) {
                            return DropdownMenuItem(
                              value: ws.id,
                              child: Text(
                                ws.name,
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedWorkspaceId = value;
                            });
                          },
                          validator: (value) {
                            if (value == null) {
                              return l10n.nameRequired; // Placeholder or add workspaceRequired
                            }
                            return null;
                          },
                        );
                      },
                    ),
                  ],
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
                              if (selectedWorkspaceId == null) return;

                              final success = await vm.createBoard(
                                name: nameController.text.trim(),
                                workspaceId: selectedWorkspaceId!,
                              );

                              if (!context.mounted) return;

                              if (success) {
                                Navigator.pop(dialogContext);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(l10n.boardCreatedSuccessfully),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      vm.errorMessage ?? l10n.boardCreateFailed,
                                    ),
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
                          : Text(l10n.add),
                    );
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}

