import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile/viewmodels/boards_viewmodel.dart';
import 'package:mobile/screens/card_detail.dart';

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
  @override
  Widget build(BuildContext context) {
    // TODO: Provider üzerinden BoardDetailViewModel'den veri çekilecek
    // Şimdilik mock veri
    final mockLists = [
      _MockListColumn(
        name: 'In Progress',
        cards: [
          _MockCardItem(title: 'NV - Pose Estimation', commentCount: 17, checklistProgress: '0/9'),
          _MockCardItem(title: 'NV - Shoplifting Model', commentCount: 0, checklistProgress: '0/9'),
          _MockCardItem(title: 'NV - Heat Map', commentCount: 3, checklistProgress: '0/9'),
        ],
      ),
      _MockListColumn(
        name: 'Active',
        cards: [
          _MockCardItem(title: 'NV - API Integration', commentCount: 5, checklistProgress: '2/6'),
        ],
      ),
      _MockListColumn(
        name: 'Done',
        cards: [
          _MockCardItem(title: 'NV - Setup', commentCount: 1, checklistProgress: '9/9'),
        ],
      ),
    ];

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
      body: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.all(8),
        itemCount: mockLists.length + 1, // +1 "Liste ekle" butonu için
        itemBuilder: (context, listIndex) {
          // Son eleman = "Liste Ekle" butonu
          if (listIndex == mockLists.length) {
            return Container(
              width: 280,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              child: Card(
                child: InkWell(
                  onTap: () {
                    // TODO: Yeni liste ekleme
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Liste ekleme yakında')),
                    );
                  },
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

          final list = mockLists[listIndex];
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
                        IconButton(
                          icon: const Icon(Icons.more_vert, size: 20),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                  // Kartlar listesi
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      itemCount: list.cards.length,
                      itemBuilder: (context, cardIndex) {
                        final card = list.cards[cardIndex];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          color: Theme.of(context).colorScheme.surfaceContainerHighest,
                          child: InkWell(
                            onTap: () {
                              // Navigator ile cardId taşıma (Kural 6)
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CardDetailScreen(
                                    cardId: 'mock-card-$listIndex-$cardIndex',
                                    cardTitle: card.title,
                                  ),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    card.title,
                                    style: Theme.of(context).textTheme.bodyMedium,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                  ),
                                  const SizedBox(height: 8),
                                  // Kart meta bilgileri
                                  Row(
                                    children: [
                                      if (card.commentCount > 0) ...[
                                        Icon(Icons.comment_outlined,
                                            size: 14,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface
                                                .withValues(alpha: 0.6)),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${card.commentCount}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall,
                                        ),
                                        const SizedBox(width: 12),
                                      ],
                                      Icon(Icons.check_box_outlined,
                                          size: 14,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface
                                              .withValues(alpha: 0.6)),
                                      const SizedBox(width: 4),
                                      Text(
                                        card.checklistProgress,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  // Kart ekle butonu
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: TextButton.icon(
                      onPressed: () {
                        // TODO: Kart ekleme
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Kart ekleme yakında')),
                        );
                      },
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Kart ekle'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

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
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
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
          content: const Text(
              'Bu panoyu silmek istediğinize emin misiniz? Bu işlem geri alınamaz.'),
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
                            Navigator.pop(dialogContext); // dialog
                            Navigator.pop(context); // ekrandan çık
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
}

// Mock veri sınıfları — ViewModel entegrasyonunda kaldırılacak
class _MockListColumn {
  final String name;
  final List<_MockCardItem> cards;
  const _MockListColumn({required this.name, required this.cards});
}

class _MockCardItem {
  final String title;
  final int commentCount;
  final String checklistProgress;
  const _MockCardItem({
    required this.title,
    this.commentCount = 0,
    this.checklistProgress = '0/0',
  });
}
