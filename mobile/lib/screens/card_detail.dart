import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile/viewmodels/cards_viewmodel.dart';
import 'package:mobile/viewmodels/checklists_viewmodel.dart';
import 'package:mobile/viewmodels/comments_viewmodel.dart';
import 'package:mobile/viewmodels/activity_viewmodel.dart';
import 'package:mobile/domain/models/board_card.dart';
import 'package:mobile/domain/models/checklist_item.dart';
import 'package:mobile/domain/models/card_comment.dart';
import 'package:mobile/domain/models/activity_log.dart';

/// Kart detay ekranı — tam MVVM entegrasyonu
/// Kural 18: Sadece cardId ve cardTitle taşınır, veri ViewModel'den okunur.
class CardDetailScreen extends StatefulWidget {
  final String cardId;
  final String cardTitle;

  const CardDetailScreen({
    super.key,
    required this.cardId,
    required this.cardTitle,
  });

  @override
  State<CardDetailScreen> createState() => _CardDetailScreenState();
}

class _CardDetailScreenState extends State<CardDetailScreen> {
  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _checklistController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Kural 10: async/await, ViewModel üzerinden veri çek
    Future.microtask(() {
      if (!mounted) return;
      context.read<ChecklistsViewModel>().fetchItems(widget.cardId);
      context.read<CommentsViewModel>().fetchComments(widget.cardId);
      context.read<ActivityViewModel>().fetchCardActivity(widget.cardId);
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    _checklistController.dispose();
    // clear ViewModel state (ekran kapandığında temizle)
    context.read<ChecklistsViewModel>().clear();
    context.read<CommentsViewModel>().clear();
    context.read<ActivityViewModel>().clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // BoardCard nesnesini CardsViewModel state'inden çek (ID ile)
    final card = context.select<CardsViewModel, BoardCard?>(
      (vm) => vm.cards.where((c) => c.id == widget.cardId).firstOrNull,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.cardTitle, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => _showEditCardDialog(context, card),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Açıklama ─────────────────────────────────────────────────
            _buildSectionHeader(
              context,
              icon: Icons.description_outlined,
              title: 'Açıklama',
            ),
            const SizedBox(height: 8),
            _DescriptionTile(card: card, cardId: widget.cardId),
            const Divider(height: 32),

            // ── Bitiş Tarihi ──────────────────────────────────────────────
            _buildSectionHeader(
              context,
              icon: Icons.calendar_today_outlined,
              title: 'Bitiş Tarihi',
            ),
            const SizedBox(height: 8),
            _DueDateTile(card: card, cardId: widget.cardId),
            const Divider(height: 32),

            // ── Checklist ─────────────────────────────────────────────────
            _buildSectionHeader(
              context,
              icon: Icons.check_box_outlined,
              title: 'Kontrol Listesi',
              trailing: TextButton.icon(
                onPressed: () => _showAddChecklistItemDialog(context),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Ekle'),
              ),
            ),
            const SizedBox(height: 8),
            _ChecklistSection(cardId: widget.cardId),
            const Divider(height: 32),

            // ── Yorumlar ──────────────────────────────────────────────────
            _buildSectionHeader(
              context,
              icon: Icons.comment_outlined,
              title: 'Yorumlar',
            ),
            const SizedBox(height: 8),
            _CommentInput(
              controller: _commentController,
              cardId: widget.cardId,
            ),
            const SizedBox(height: 12),
            _CommentsSection(cardId: widget.cardId),
            const Divider(height: 32),

            // ── Aktivite ─────────────────────────────────────────────────
            _buildSectionHeader(
              context,
              icon: Icons.history,
              title: 'Aktivite',
            ),
            const SizedBox(height: 8),
            _CardActivitySection(cardId: widget.cardId),
          ],
        ),
      ),
    );
  }

  /// Bölüm başlığı widget'ı (Kural 11 — global helper)
  Widget _buildSectionHeader(
    BuildContext context, {
    required IconData icon,
    required String title,
    Widget? trailing,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        ?trailing,
      ],
    );
  }

  // ── Diyaloglar ──────────────────────────────────────────────────────────

  void _showAddChecklistItemDialog(BuildContext context) {
    _checklistController.clear();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Öğe Ekle'),
        content: TextField(
          controller: _checklistController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Öğe başlığı',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (_) => _submitChecklistItem(dialogContext),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('İptal'),
          ),
          Consumer<ChecklistsViewModel>(
            builder: (context, vm, child) => FilledButton(
              onPressed: vm.isLoading
                  ? null
                  : () => _submitChecklistItem(dialogContext),
              child: vm.isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Ekle'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitChecklistItem(BuildContext dialogContext) async {
    final title = _checklistController.text.trim();
    if (title.isEmpty) return;

    final vm = context.read<ChecklistsViewModel>();
    final success = await vm.createItem(cardId: widget.cardId, title: title);

    if (!mounted) return;
    if (!dialogContext.mounted) return;
    Navigator.pop(dialogContext);

    if (!success) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(vm.errorMessage ?? 'Öğe eklenemedi'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  void _showEditCardDialog(BuildContext context, BoardCard? card) {
    if (card == null) return;
    final titleCtrl = TextEditingController(text: card.title);
    final descCtrl = TextEditingController(text: card.description ?? '');

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Kartı Düzenle'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(
                labelText: 'Başlık',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descCtrl,
              decoration: const InputDecoration(
                labelText: 'Açıklama',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('İptal'),
          ),
          Consumer<CardsViewModel>(
            builder: (context, vm, child) => FilledButton(
              onPressed: vm.isLoading
                  ? null
                  : () async {
                      final t = titleCtrl.text.trim();
                      if (t.isEmpty) return;
                      final success = await vm.updateCard(
                        cardId: widget.cardId,
                        title: t,
                        description: descCtrl.text.trim(),
                      );
                      if (!context.mounted) return;
                      Navigator.pop(dialogContext);
                      if (!success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              vm.errorMessage ?? 'Güncelleme başarısız',
                            ),
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.error,
                          ),
                        );
                      }
                    },
              child: const Text('Kaydet'),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Alt Widget'lar ─────────────────────────────────────────────────────────

class _DescriptionTile extends StatelessWidget {
  final BoardCard? card;
  final String cardId;

  const _DescriptionTile({required this.card, required this.cardId});

  @override
  Widget build(BuildContext context) {
    final description = card?.description;
    if (description == null || description.isEmpty) {
      return Text(
        'Henüz bir açıklama eklenmemiş.',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
        ),
      );
    }
    return Text(description, style: Theme.of(context).textTheme.bodyMedium);
  }
}

class _DueDateTile extends StatelessWidget {
  final BoardCard? card;
  final String cardId;

  const _DueDateTile({required this.card, required this.cardId});

  @override
  Widget build(BuildContext context) {
    // BoardCard modeli dueDate içermiyor — KanbanCard modeli içeriyor.
    // CardsViewModel BoardCard kullanıyor, dueDate şimdilik yok.
    return Text(
      'Belirlenmemiş',
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
      ),
    );
  }
}

/// Checklist bölümü — ChecklistsViewModel ile bağlı
class _ChecklistSection extends StatelessWidget {
  final String cardId;

  const _ChecklistSection({required this.cardId});

  @override
  Widget build(BuildContext context) {
    return Consumer<ChecklistsViewModel>(
      builder: (context, vm, _) {
        if (vm.isLoading && vm.items.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (vm.errorMessage != null && vm.items.isEmpty) {
          return Text(
            vm.errorMessage!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          );
        }

        if (vm.items.isEmpty) {
          return Text(
            'Henüz öğe yok. Ekle butonuna tıklayın.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          );
        }

        // İlerleme çubuğu
        final completed = vm.items.where((i) => i.isCompleted).length;
        final total = vm.items.length;
        final progress = total == 0 ? 0.0 : completed / total;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // İlerleme göstergesi
            Row(
              children: [
                Text(
                  '$completed/$total',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: LinearProgressIndicator(
                    value: progress.clamp(0.0, 1.0),
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Öğe listesi — Kural 8: ListView.builder
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: vm.items.length,
              itemBuilder: (context, index) {
                final item = vm.items[index];
                return _ChecklistItemTile(item: item);
              },
            ),
          ],
        );
      },
    );
  }
}

/// Tek bir checklist öğesi
class _ChecklistItemTile extends StatelessWidget {
  final ChecklistItem item;

  const _ChecklistItemTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final vm = context.read<ChecklistsViewModel>();

    return Dismissible(
      key: Key('checklist_${item.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        color: Theme.of(context).colorScheme.error,
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      onDismissed: (_) async {
        final success = await vm.deleteItem(item.id);
        if (!context.mounted) return;
        if (!success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(vm.errorMessage ?? 'Silme başarısız'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      },
      child: CheckboxListTile(
        value: item.isCompleted,
        onChanged: (_) => vm.toggleItem(item.id),
        title: Text(
          item.title,
          overflow: TextOverflow.ellipsis,
          style: item.isCompleted
              ? const TextStyle(decoration: TextDecoration.lineThrough)
              : null,
        ),
        controlAffinity: ListTileControlAffinity.leading,
        contentPadding: EdgeInsets.zero,
      ),
    );
  }
}

/// Yorum ekleme input alanı
class _CommentInput extends StatelessWidget {
  final TextEditingController controller;
  final String cardId;

  const _CommentInput({required this.controller, required this.cardId});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'Yorum yaz...',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
            ),
            maxLines: 3,
            minLines: 1,
            textInputAction: TextInputAction.newline,
          ),
        ),
        const SizedBox(width: 8),
        Consumer<CommentsViewModel>(
          builder: (context, vm, _) => FilledButton(
            onPressed: vm.isLoading
                ? null
                : () async {
                    final content = controller.text.trim();
                    if (content.isEmpty) return;

                    final success = await vm.createComment(
                      cardId: cardId,
                      content: content,
                    );

                    if (!context.mounted) return;
                    if (success) {
                      controller.clear();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(vm.errorMessage ?? 'Yorum eklenemedi'),
                          backgroundColor: Theme.of(context).colorScheme.error,
                        ),
                      );
                    }
                  },
            child: vm.isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Gönder'),
          ),
        ),
      ],
    );
  }
}

/// Yorumlar listesi bölümü
class _CommentsSection extends StatelessWidget {
  final String cardId;

  const _CommentsSection({required this.cardId});

  @override
  Widget build(BuildContext context) {
    return Consumer<CommentsViewModel>(
      builder: (context, vm, _) {
        if (vm.isLoading && vm.comments.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (vm.errorMessage != null && vm.comments.isEmpty) {
          return Text(
            vm.errorMessage!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          );
        }

        if (vm.comments.isEmpty) {
          return Text(
            'Henüz yorum yok.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          );
        }

        // Kural 8: ListView.builder — sadece görüneni render et
        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: vm.comments.length,
          separatorBuilder: (context, index) => const Divider(height: 16),
          itemBuilder: (context, index) {
            final comment = vm.comments[index];
            return _CommentTile(comment: comment);
          },
        );
      },
    );
  }
}

class _CardActivitySection extends StatelessWidget {
  final String cardId;

  const _CardActivitySection({required this.cardId});

  @override
  Widget build(BuildContext context) {
    return Consumer<ActivityViewModel>(
      builder: (context, vm, _) {
        if (vm.isLoading && vm.logs.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (vm.errorMessage != null && vm.logs.isEmpty) {
          return Text(
            vm.errorMessage!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          );
        }

        if (vm.logs.isEmpty) {
          return Text(
            'Henüz aktivite yok.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: vm.logs.length,
          separatorBuilder: (context, index) => const Divider(height: 16),
          itemBuilder: (context, index) {
            final log = vm.logs[index];
            return _ActivityLogTile(log: log);
          },
        );
      },
    );
  }
}

class _ActivityLogTile extends StatelessWidget {
  final ActivityLog log;

  const _ActivityLogTile({required this.log});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 16,
          child: Icon(_iconForAction(log.action), size: 16),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${log.userName ?? log.userEmail ?? 'Kullanıcı'} · ${log.action}',
                style: Theme.of(
                  context,
                ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                log.entityName ?? log.entityType,
                style: Theme.of(context).textTheme.bodySmall,
                overflow: TextOverflow.ellipsis,
              ),
              if ((log.oldValue ?? '').isNotEmpty ||
                  (log.newValue ?? '').isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  [
                    if ((log.oldValue ?? '').isNotEmpty)
                      'Önce: ${log.oldValue}',
                    if ((log.newValue ?? '').isNotEmpty)
                      'Sonra: ${log.newValue}',
                  ].join(' • '),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '${log.createdAt.day.toString().padLeft(2, '0')}.${log.createdAt.month.toString().padLeft(2, '0')}',
          style: Theme.of(context).textTheme.labelSmall,
        ),
      ],
    );
  }

  IconData _iconForAction(String action) {
    final normalized = action.toLowerCase();
    if (normalized.contains('create') || normalized.contains('add')) {
      return Icons.add;
    }
    if (normalized.contains('update') || normalized.contains('edit')) {
      return Icons.edit;
    }
    if (normalized.contains('delete') || normalized.contains('remove')) {
      return Icons.delete;
    }
    if (normalized.contains('move')) {
      return Icons.drive_file_move;
    }
    return Icons.history;
  }
}

/// Tek bir yorum kartı
class _CommentTile extends StatelessWidget {
  final CardComment comment;

  const _CommentTile({required this.comment});

  @override
  Widget build(BuildContext context) {
    final vm = context.read<CommentsViewModel>();
    final displayName =
        comment.userFullName ?? comment.userEmail ?? 'Kullanıcı';
    final initials = displayName
        .split(' ')
        .where((s) => s.isNotEmpty)
        .take(2)
        .map((s) => s[0].toUpperCase())
        .join();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Text(
            initials.isNotEmpty ? initials : '?',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      displayName,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    _formatDate(comment.createdAt),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                  // Sil butonu
                  IconButton(
                    icon: Icon(
                      Icons.delete_outline,
                      size: 16,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () async {
                      final success = await vm.deleteComment(comment.id);
                      if (!context.mounted) return;
                      if (!success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(vm.errorMessage ?? 'Silme başarısız'),
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.error,
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                comment.content,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}.'
        '${dt.month.toString().padLeft(2, '0')}.'
        '${dt.year}';
  }
}
