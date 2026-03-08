import 'package:flutter/material.dart';
import 'package:mobile/screens/board_detail.dart';

/// Panolar listesi ekranı — referans: panolar.jpeg
/// Workspace'e göre gruplanmış board listesi + "Pano Oluştur" FAB.
class BoardsScreen extends StatelessWidget {
  const BoardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Provider üzerinden BoardsViewModel'den veri çekilecek
    // Şimdilik mock veri
    final mockWorkspaces = [
      _MockWorkspaceGroup(
        workspaceName: 'DigiNova Staj VISION-B',
        boards: [
          _MockBoardItem(name: 'Gelen Kutusu', hasBackground: false),
        ],
      ),
      _MockWorkspaceGroup(
        workspaceName: 'NovaVision',
        boards: [
          _MockBoardItem(name: 'NovaVision', hasBackground: true),
        ],
      ),
    ];

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
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: mockWorkspaces.length,
        itemBuilder: (context, index) {
          final group = mockWorkspaces[index];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (index > 0) const SizedBox(height: 16),
              // Workspace başlığı
              Text(
                group.workspaceName,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.6),
                    ),
              ),
              const SizedBox(height: 8),
              // Board kartları
              ...group.boards.map((board) => Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: board.hasBackground
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
                              boardId: 'mock-board-id-$index',
                              boardName: board.name,
                            ),
                          ),
                        );
                      },
                    ),
                  )),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Pano oluşturma
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

// Mock veri sınıfları — ViewModel entegrasyonunda kaldırılacak
class _MockWorkspaceGroup {
  final String workspaceName;
  final List<_MockBoardItem> boards;
  const _MockWorkspaceGroup({
    required this.workspaceName,
    required this.boards,
  });
}

class _MockBoardItem {
  final String name;
  final bool hasBackground;
  const _MockBoardItem({required this.name, this.hasBackground = false});
}
