import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile/domain/models/activity_log.dart';
import 'package:mobile/viewmodels/activity_viewmodel.dart';
import 'package:mobile/viewmodels/boards_viewmodel.dart';
import 'package:mobile/viewmodels/cards_viewmodel.dart';
import 'package:mobile/viewmodels/workspaces_viewmodel.dart';
import 'package:mobile/l10n/app_localizations.dart';

enum ActivityScope { workspace, board, card }

class ActivityScreen extends StatefulWidget {
  final String? boardId;
  final String? boardName;
  final String? workspaceId;
  final String? workspaceName;
  final String? cardId;
  final String? cardName;
  final ActivityScope initialScope;

  const ActivityScreen({
    super.key,
    this.boardId,
    this.boardName,
    this.workspaceId,
    this.workspaceName,
    this.cardId,
    this.cardName,
    this.initialScope = ActivityScope.workspace,
  });

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  ActivityScope _scope = ActivityScope.workspace;
  String? _selectedWorkspaceId;
  String? _selectedBoardId;
  String? _selectedCardId;

  @override
  void initState() {
    super.initState();
    _scope = widget.initialScope;
    _selectedWorkspaceId = widget.workspaceId;
    _selectedBoardId = widget.boardId;
    _selectedCardId = widget.cardId;

    Future.microtask(() async {
      if (!mounted) return;

      await Future.wait([
        context.read<WorkspacesViewModel>().fetchWorkspaces(),
        context.read<BoardsViewModel>().fetchBoards(),
        context.read<CardsViewModel>().fetchCards(),
      ]);

      if (!mounted) return;
      await _loadCurrentScopeActivity();
    });
  }

  @override
  void dispose() {
    context.read<ActivityViewModel>().clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final title = widget.boardName != null
        ? '${widget.boardName} ${l10n.activity}'
        : l10n.activity;

    return Scaffold(
      appBar: AppBar(
        title: Text(title, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _reload),
        ],
      ),
      body: Consumer3<WorkspacesViewModel, BoardsViewModel, CardsViewModel>(
        builder: (context, workspacesVM, boardsVM, cardsVM, child) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: ToggleButtons(
                  isSelected: [
                    _scope == ActivityScope.workspace,
                    _scope == ActivityScope.board,
                    _scope == ActivityScope.card,
                  ],
                  onPressed: (index) async {
                    setState(() {
                      _scope = ActivityScope.values[index];
                    });
                    await _ensureSelectionForCurrentScope(
                      workspacesVM,
                      boardsVM,
                      cardsVM,
                    );
                    await _loadCurrentScopeActivity();
                  },
                  borderRadius: BorderRadius.circular(12),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(l10n.workspaces),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(l10n.boards),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(l10n.card),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildSelectorRow(
                  context,
                  workspacesVM,
                  boardsVM,
                  cardsVM,
                  l10n,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Consumer<ActivityViewModel>(
                  builder: (context, activityVM, child) {
                    if (activityVM.isLoading && activityVM.logs.isEmpty) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (activityVM.errorMessage != null &&
                        activityVM.logs.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
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
                                activityVM.errorMessage!,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              FilledButton.icon(
                                onPressed: _reload,
                                icon: const Icon(Icons.refresh),
                                label: Text(l10n.tryAgain),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    if (activityVM.logs.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.timeline_outlined,
                                size: 72,
                                color: Theme.of(
                                  context,
                                ).colorScheme.primary.withValues(alpha: 0.35),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                l10n.noActivity,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                l10n.noActivityFoundForSelection,
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: _reload,
                      child: ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(16),
                        itemCount: activityVM.logs.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final log = activityVM.logs[index];
                          return _ActivityTile(log: log, l10n: l10n);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSelectorRow(
    BuildContext context,
    WorkspacesViewModel workspacesVM,
    BoardsViewModel boardsVM,
    CardsViewModel cardsVM,
    AppLocalizations l10n,
  ) {
    switch (_scope) {
      case ActivityScope.workspace:
        if (workspacesVM.workspaces.isEmpty) {
          return _EmptySelectorHint(
            icon: Icons.workspaces_outline,
            text: l10n.noWorkspacesFound,
          );
        }
        return DropdownButton<String>(
          value: _selectedWorkspaceId,
          isExpanded: true,
          items: workspacesVM.workspaces
              .map(
                (workspace) => DropdownMenuItem(
                  value: workspace.id,
                  child: Text(workspace.name, overflow: TextOverflow.ellipsis),
                ),
              )
              .toList(),
          onChanged: (value) async {
            setState(() => _selectedWorkspaceId = value);
            await _loadCurrentScopeActivity();
          },
        );
      case ActivityScope.board:
        if (boardsVM.boards.isEmpty) {
          return _EmptySelectorHint(
            icon: Icons.dashboard_outlined,
            text: l10n.noBoardsFound,
          );
        }
        return DropdownButton<String>(
          value: _selectedBoardId,
          isExpanded: true,
          items: boardsVM.boards
              .map(
                (board) => DropdownMenuItem(
                  value: board.id,
                  child: Text(board.name, overflow: TextOverflow.ellipsis),
                ),
              )
              .toList(),
          onChanged: (value) async {
            setState(() => _selectedBoardId = value);
            await _loadCurrentScopeActivity();
          },
        );
      case ActivityScope.card:
        if (cardsVM.cards.isEmpty) {
          return _EmptySelectorHint(
            icon: Icons.check_box_outlined,
            text: l10n.noCardsFound,
          );
        }
        return DropdownButton<String>(
          value: _selectedCardId,
          isExpanded: true,
          items: cardsVM.cards
              .map(
                (card) => DropdownMenuItem(
                  value: card.id,
                  child: Text(card.title, overflow: TextOverflow.ellipsis),
                ),
              )
              .toList(),
          onChanged: (value) async {
            setState(() => _selectedCardId = value);
            await _loadCurrentScopeActivity();
          },
        );
    }
  }

  Future<void> _reload() async {
    await _loadCurrentScopeActivity();
  }

  Future<void> _ensureSelectionForCurrentScope(
    WorkspacesViewModel workspacesVM,
    BoardsViewModel boardsVM,
    CardsViewModel cardsVM,
  ) async {
    setState(() {
      if (_scope == ActivityScope.workspace) {
        if (_selectedWorkspaceId == null ||
            !workspacesVM.workspaces.any((w) => w.id == _selectedWorkspaceId)) {
          _selectedWorkspaceId = workspacesVM.workspaces.isNotEmpty
              ? workspacesVM.workspaces.first.id
              : null;
        }
      } else if (_scope == ActivityScope.board) {
        if (_selectedBoardId == null ||
            !boardsVM.boards.any((b) => b.id == _selectedBoardId)) {
          _selectedBoardId =
              boardsVM.boards.isNotEmpty ? boardsVM.boards.first.id : null;
        }
      } else {
        if (_selectedCardId == null ||
            !cardsVM.cards.any((c) => c.id == _selectedCardId)) {
          _selectedCardId =
              cardsVM.cards.isNotEmpty ? cardsVM.cards.first.id : null;
        }
      }
    });
  }

  Future<void> _loadCurrentScopeActivity() async {
    if (!mounted) return;

    final activityVM = context.read<ActivityViewModel>();
    final workspacesVM = context.read<WorkspacesViewModel>();
    final boardsVM = context.read<BoardsViewModel>();
    final cardsVM = context.read<CardsViewModel>();

    await _ensureSelectionForCurrentScope(workspacesVM, boardsVM, cardsVM);

    if (!mounted) return;

    switch (_scope) {
      case ActivityScope.workspace:
        if (_selectedWorkspaceId != null) {
          await activityVM.fetchWorkspaceActivity(_selectedWorkspaceId!);
        } else {
          activityVM.clear();
        }
        break;
      case ActivityScope.board:
        if (_selectedBoardId != null) {
          await activityVM.fetchBoardActivity(_selectedBoardId!);
        } else {
          activityVM.clear();
        }
        break;
      case ActivityScope.card:
        if (_selectedCardId != null) {
          await activityVM.fetchCardActivity(_selectedCardId!);
        } else {
          activityVM.clear();
        }
        break;
    }
  }
}

class _ActivityTile extends StatelessWidget {
  final ActivityLog log;
  final AppLocalizations l10n;

  const _ActivityTile({required this.log, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final icon = _iconForAction(log.action, log.entityType);

    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: colorScheme.primaryContainer,
          child: Icon(icon, color: colorScheme.onPrimaryContainer),
        ),
        title: Text(_titleText(log, l10n), overflow: TextOverflow.ellipsis),
        subtitle: Text(
          _subtitleText(log, l10n),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Text(
          _formatDate(log.createdAt),
          textAlign: TextAlign.right,
          style: Theme.of(context).textTheme.labelSmall,
        ),
      ),
    );
  }

  String _titleText(ActivityLog log, AppLocalizations l10n) {
    final actor = log.userFullName ?? log.userName ?? log.userEmail ?? l10n.unknownUser;
    return '$actor · ${log.action}';
  }

  String _subtitleText(ActivityLog log, AppLocalizations l10n) {
    final entityName = log.entityName ?? log.entityType;
    final valueLine = [
      if (log.oldValue != null && log.oldValue!.isNotEmpty)
        '${l10n.before}: ${log.oldValue}',
      if (log.newValue != null && log.newValue!.isNotEmpty)
        '${l10n.after}: ${log.newValue}',
    ].join(' • ');

    if (valueLine.isEmpty) {
      return entityName;
    }
    return '$entityName\n$valueLine';
  }

  IconData _iconForAction(String action, String entityType) {
    final normalized = action.toLowerCase();
    if (normalized.contains('create') || normalized.contains('add')) {
      return Icons.add_circle_outline;
    }
    if (normalized.contains('update') || normalized.contains('edit')) {
      return Icons.edit_outlined;
    }
    if (normalized.contains('delete') || normalized.contains('remove')) {
      return Icons.delete_outline;
    }
    if (normalized.contains('move')) {
      return Icons.drive_file_move_outline;
    }
    if (entityType.toLowerCase().contains('card')) {
      return Icons.view_agenda_outlined;
    }
    if (entityType.toLowerCase().contains('workspace')) {
      return Icons.workspaces_outlined;
    }
    return Icons.history;
  }

  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}\n${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}


class _EmptySelectorHint extends StatelessWidget {
  final IconData icon;
  final String text;

  const _EmptySelectorHint({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

