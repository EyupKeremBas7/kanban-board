import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile/viewmodels/boards_viewmodel.dart';
import 'package:mobile/screens/board_detail.dart';

/// Panolar listesi ekranı — referans: panolar.jpeg
/// BoardsViewModel üzerinden gerçek API verisi gösterir.
class BoardsScreen extends StatefulWidget {
  const BoardsScreen({super.key});

  @override
  State<BoardsScreen> createState() => _BoardsScreenState();
}

class _BoardsScreenState extends State<BoardsScreen> {
  @override
  void initState() {
    super.initState();
    // Ekran açılınca board listesini çek
    final boardsVM = context.read<BoardsViewModel>();
    Future.microtask(() => boardsVM.fetchBoards());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panolar'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Arama işlevi
            },
          ),
          // Yenile butonu
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
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Henüz pano yok',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.5),
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'İlk panonuzu oluşturun',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.4),
                        ),
                  ),
                ],
              ),
            );
          }

          // Board listesi — workspace'e göre grouped
          // Backend workspace_id döner, şimdilik düz liste göster
          return RefreshIndicator(
            onRefresh: () => boardsVM.fetchBoards(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: boardsVM.boards.length,
              itemBuilder: (context, index) {
                final board = boardsVM.boards[index];
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
        onPressed: () {
          // TODO: Board oluşturma — Feature #9'da eklenecek
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Pano oluşturma yakında eklenecek')),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Pano Oluştur'),
      ),
    );
  }
}
