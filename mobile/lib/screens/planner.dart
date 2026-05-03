import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile/domain/models/board.dart';
import 'package:mobile/domain/models/workspace.dart';
import 'package:mobile/screens/board_detail.dart';
import 'package:mobile/viewmodels/boards_viewmodel.dart';
import 'package:mobile/viewmodels/workspaces_viewmodel.dart';

/// Ana Sayfa / Dashboard
/// Workspace'e göre gruplandırılmış board listesi ve son görüntülenenler.
class PlannerScreen extends StatefulWidget {
  const PlannerScreen({super.key});

  @override
  State<PlannerScreen> createState() => _PlannerScreenState();
}

class _PlannerScreenState extends State<PlannerScreen> {
  final List<String> _recentBoardIds = [];

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      context.read<BoardsViewModel>().fetchBoards();
      context.read<WorkspacesViewModel>().fetchWorkspaces();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ana Sayfa'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<BoardsViewModel>().fetchBoards();
              context.read<WorkspacesViewModel>().fetchWorkspaces();
            },
          ),
        ],
      ),
      body: Consumer2<BoardsViewModel, WorkspacesViewModel>(
        builder: (context, boardsVM, workspacesVM, child) {
          if (boardsVM.isLoading && workspacesVM.workspaces.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

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
                  Text(boardsVM.errorMessage!, textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () {
                      boardsVM.fetchBoards();
                      workspacesVM.fetchWorkspaces();
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Tekrar Dene'),
                  ),
                ],
              ),
            );
          }

          if (workspacesVM.workspaces.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.workspaces_outlined,
                    size: 72,
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.35),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Henüz çalışma alanı yok',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Board grupları burada workspace bazlı görünecek.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            );
          }

          final recentBoards = <Board>[];
          for (final id in _recentBoardIds) {
            for (final board in boardsVM.boards) {
              if (board.id == id) {
                recentBoards.add(board);
                break;
              }
            }
          }

          return RefreshIndicator(
            onRefresh: () async {
              await boardsVM.fetchBoards();
              await workspacesVM.fetchWorkspaces();
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // İstatistikler
                Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          title: 'Toplam Pano',
                          value: boardsVM.boards.length.toString(),
                          icon: Icons.dashboard_outlined,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          title: 'Çalışma Alanı',
                          value: workspacesVM.workspaces.length.toString(),
                          icon: Icons.workspaces_outline,
                        ),
                      ),
                    ],
                  ),
                ),
                if (recentBoards.isNotEmpty) ...[
                  Text(
                    'Son Görüntülenenler',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 120,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: recentBoards.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final board = recentBoards[index];
                        return _RecentBoardCard(
                          board: board,
                          onTap: () => _openBoard(board),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                ...workspacesVM.workspaces.map(
                  (workspace) => Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: _WorkspaceBoardSection(
                      workspace: workspace,
                      boards: boardsVM.boards
                          .where((b) => b.workspaceId == workspace.id)
                          .toList(),
                      onBoardTap: _openBoard,
                      onCreateBoard: () => _showCreateBoardDialog(
                        context,
                        workspaceId: workspace.id,
                        workspaceName: workspace.name,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _openBoard(Board board) {
    setState(() {
      _recentBoardIds.remove(board.id);
      _recentBoardIds.insert(0, board.id);
      if (_recentBoardIds.length > 6) {
        _recentBoardIds.removeLast();
      }
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            BoardDetailScreen(boardId: board.id, boardName: board.name),
      ),
    );
  }

  void _showCreateBoardDialog(
    BuildContext context, {
    required String workspaceId,
    required String workspaceName,
  }) {
    final nameController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('$workspaceName için Pano Oluştur'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: nameController,
              autofocus: true,
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
                          final success = await vm.createBoard(
                            name: nameController.text.trim(),
                            workspaceId: workspaceId,
                          );
                          if (!context.mounted) return;
                          Navigator.pop(dialogContext);
                          if (success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Pano oluşturuldu')),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  vm.errorMessage ?? 'Pano oluşturulamadı',
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
                          width: 18,
                          height: 18,
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
  }
}

class _WorkspaceBoardSection extends StatelessWidget {
  final Workspace workspace;
  final List<Board> boards;
  final ValueChanged<Board> onBoardTap;
  final VoidCallback onCreateBoard;

  const _WorkspaceBoardSection({
    required this.workspace,
    required this.boards,
    required this.onBoardTap,
    required this.onCreateBoard,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                workspace.name,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            TextButton.icon(
              onPressed: onCreateBoard,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Yeni Pano'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (boards.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Bu çalışma alanında henüz pano yok.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: boards.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.45,
            ),
            itemBuilder: (context, index) {
              final board = boards[index];
              return _BoardCard(board: board, onTap: () => onBoardTap(board));
            },
          ),
      ],
    );
  }
}

class _BoardCard extends StatelessWidget {
  final Board board;
  final VoidCallback onTap;

  const _BoardCard({required this.board, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Container(
          decoration: BoxDecoration(
            gradient: board.backgroundImage == null
                ? null
                : LinearGradient(
                    colors: [
                      Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.9),
                      Theme.of(
                        context,
                      ).colorScheme.secondary.withValues(alpha: 0.9),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
            color: board.backgroundImage == null
                ? Theme.of(context).colorScheme.surfaceContainerHighest
                : null,
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                board.backgroundImage == null
                    ? Icons.dashboard_outlined
                    : Icons.photo,
                color: board.backgroundImage == null
                    ? Theme.of(context).colorScheme.primary
                    : Colors.white,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    board.name,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: board.backgroundImage == null
                          ? null
                          : Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    board.visibility.name,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: board.backgroundImage == null
                          ? Theme.of(context).colorScheme.onSurfaceVariant
                          : Colors.white70,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecentBoardCard extends StatelessWidget {
  final Board board;
  final VoidCallback onTap;

  const _RecentBoardCard({required this.board, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      child: Card(
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  Icons.history,
                  color: Theme.of(context).colorScheme.primary,
                ),
                Text(
                  board.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
