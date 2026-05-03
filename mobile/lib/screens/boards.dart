import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile/viewmodels/boards_viewmodel.dart';
import 'package:mobile/viewmodels/workspaces_viewmodel.dart';
import 'package:mobile/screens/board_detail.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Pano ara...',
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase();
                  });
                },
              )
            : const Text('Panolar'),
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
                    label: const Text('Tekrar Dene'),
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
                    'Henüz pano yok',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'İlk panonuzu oluşturun',
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
          // Backend workspace_id döner, şimdilik düz liste göster
          final filteredBoards = boardsVM.boards.where((b) {
            return b.name.toLowerCase().contains(_searchQuery);
          }).toList();

          if (filteredBoards.isEmpty && _searchQuery.isNotEmpty) {
            return const Center(child: Text('Aranan kriterlere uygun pano bulunamadı.'));
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
        onPressed: () => _showCreateBoardDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Pano Oluştur'),
      ),
    );
  }

  void _showCreateBoardDialog(BuildContext context) {
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
              title: const Text('Yeni Pano Oluştur'),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Pano Adı',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Pano adı gerekli';
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
                              'Pano oluşturmak için önce bir Çalışma Alanı oluşturmalısınız.',
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
                          decoration: const InputDecoration(
                            labelText: 'Çalışma Alanı',
                            border: OutlineInputBorder(),
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
                              return 'Çalışma alanı seçilmeli';
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
                  child: const Text('İptal'),
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
                                  const SnackBar(
                                    content: Text('Pano oluşturuldu'),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      vm.errorMessage ?? 'Oluşturma başarısız',
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
                          : const Text('Oluştur'),
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
