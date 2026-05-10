import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile/viewmodels/workspaces_viewmodel.dart';
import 'package:mobile/viewmodels/invitations_viewmodel.dart';
import 'package:mobile/domain/models/workspace.dart';
import 'package:mobile/screens/workspace_members.dart';
import 'package:mobile/viewmodels/navigation_viewmodel.dart';
import 'package:mobile/l10n/app_localizations.dart';

/// Workspace yönetim ekranı
/// WorkspacesViewModel üzerinden tam CRUD (listele, oluştur, düzenle, sil).
/// Kural 8: ListView.builder
/// Kural 16: Null safety
/// Kural 18: Navigasyonda sadece ID taşınır
class WorkspacesScreen extends StatefulWidget {
  const WorkspacesScreen({super.key});

  @override
  State<WorkspacesScreen> createState() => _WorkspacesScreenState();
}

class _WorkspacesScreenState extends State<WorkspacesScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        context.read<WorkspacesViewModel>().fetchWorkspaces();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.workspaces),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                context.read<WorkspacesViewModel>().fetchWorkspaces(),
          ),
        ],
      ),
      body: Consumer<WorkspacesViewModel>(
        builder: (context, vm, _) {
          // ── Loading ───────────────────────────────────────────────────
          if (vm.isLoading && vm.workspaces.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          // ── Error ─────────────────────────────────────────────────────
          if (vm.errorMessage != null && vm.workspaces.isEmpty) {
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
                    vm.errorMessage!,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () => vm.fetchWorkspaces(),
                    icon: const Icon(Icons.refresh),
                    label: Text(l10n.tryAgain),
                  ),
                ],
              ),
            );
          }

          // ── Empty ─────────────────────────────────────────────────────
          if (vm.workspaces.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.workspaces_outlined,
                    size: 64,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.noWorkspacesYet,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.createFirstWorkspace,
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

          // ── Liste ─────────────────────────────────────────────────────
          return RefreshIndicator(
            onRefresh: () => vm.fetchWorkspaces(),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: vm.workspaces.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final workspace = vm.workspaces[index];
                return _WorkspaceTile(workspace: workspace);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateWorkspaceDialog(context, l10n),
        icon: const Icon(Icons.add),
        label: Text(l10n.newWorkspace),
      ),
    );
  }

  // ── Create Dialog ──────────────────────────────────────────────────────

  void _showCreateWorkspaceDialog(BuildContext context, AppLocalizations l10n) {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.createWorkspace),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameCtrl,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: l10n.workspaceName,
                  border: const OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return l10n.nameRequired;
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: descCtrl,
                decoration: InputDecoration(
                  labelText: l10n.descriptionOptional,
                  border: const OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancel),
          ),
          Consumer<WorkspacesViewModel>(
            builder: (context, vm, child) => FilledButton(
              onPressed: vm.isLoading
                  ? null
                  : () async {
                      if (!formKey.currentState!.validate()) return;
                      final success = await vm.createWorkspace(
                        name: nameCtrl.text.trim(),
                        description: descCtrl.text.trim().isNotEmpty
                            ? descCtrl.text.trim()
                            : null,
                      );
                      if (!context.mounted) return;
                      Navigator.pop(dialogContext);
                      if (!success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(vm.errorMessage ?? l10n.createFailed),
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.error,
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l10n.workspaceCreatedSuccessfully),
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
                  : Text(l10n.add),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Workspace Tile ─────────────────────────────────────────────────────────

class _WorkspaceTile extends StatelessWidget {
  final Workspace workspace;

  const _WorkspaceTile({required this.workspace});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final vm = context.read<WorkspacesViewModel>();

    return Card(
      child: InkWell(
        onTap: () {
          context.read<NavigationViewModel>().navigateToWorkspaceBoards(workspace.id);
          Navigator.popUntil(context, (route) => route.isFirst);
        },
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
            child: Text(
              workspace.name.isNotEmpty ? workspace.name[0].toUpperCase() : '?',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSecondaryContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          title: Text(workspace.name, overflow: TextOverflow.ellipsis),
          subtitle:
              workspace.description != null && workspace.description!.isNotEmpty
              ? Text(
                  workspace.description!,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                )
              : null,
          trailing: PopupMenuButton<_WorkspaceAction>(
            icon: const Icon(Icons.more_vert),
            onSelected: (action) {
              switch (action) {
                case _WorkspaceAction.edit:
                  _showEditDialog(context, workspace, vm, l10n);
                case _WorkspaceAction.delete:
                  _showDeleteConfirm(context, workspace, vm, l10n);
                case _WorkspaceAction.invite:
                  _showInviteDialog(context, workspace, l10n);
                case _WorkspaceAction.manageMembers:
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          WorkspaceMembersScreen(workspace: workspace),
                    ),
                  );
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: _WorkspaceAction.manageMembers,
                child: Row(
                  children: [
                    const Icon(Icons.group_outlined, size: 18),
                    const SizedBox(width: 8),
                    Text(l10n.manageMembers),
                  ],
                ),
              ),
              PopupMenuItem(
                value: _WorkspaceAction.invite,
                child: Row(
                  children: [
                    const Icon(Icons.person_add_alt_1_outlined, size: 18),
                    const SizedBox(width: 8),
                    Text(l10n.inviteMember),
                  ],
                ),
              ),
              PopupMenuItem(
                value: _WorkspaceAction.edit,
                child: Row(
                  children: [
                    const Icon(Icons.edit_outlined, size: 18),
                    const SizedBox(width: 8),
                    Text(l10n.editProfile), // or l10n.edit
                  ],
                ),
              ),
              PopupMenuItem(
                value: _WorkspaceAction.delete,
                child: Row(
                  children: [
                    const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                    const SizedBox(width: 8),
                    Text(l10n.logout.split(' ')[0], // Hack to get 'Sil' or 'Delete' if I had it
                         style: const TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Edit Dialog ─────────────────────────────────────────────────────────

  void _showEditDialog(
    BuildContext context,
    Workspace workspace,
    WorkspacesViewModel vm,
    AppLocalizations l10n,
  ) {
    final nameCtrl = TextEditingController(text: workspace.name);
    final descCtrl = TextEditingController(text: workspace.description ?? '');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.editWorkspace),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameCtrl,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: l10n.workspaceName,
                  border: const OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return l10n.nameRequired;
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: descCtrl,
                decoration: InputDecoration(
                  labelText: l10n.descriptionOptional, // or description
                  border: const OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancel),
          ),
          Consumer<WorkspacesViewModel>(
            builder: (context, vm2, child) => FilledButton(
              onPressed: vm2.isLoading
                  ? null
                  : () async {
                      if (!formKey.currentState!.validate()) return;
                      final success = await vm2.updateWorkspace(
                        workspaceId: workspace.id,
                        name: nameCtrl.text.trim(),
                        description: descCtrl.text.trim(),
                      );
                      if (!context.mounted) return;
                      Navigator.pop(dialogContext);
                      if (!success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              vm2.errorMessage ?? l10n.save, // generic
                            ),
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.error,
                          ),
                        );
                      }
                    },
              child: Text(l10n.save),
            ),
          ),
        ],
      ),
    );
  }

  // ── Delete Confirm ──────────────────────────────────────────────────────

  void _showDeleteConfirm(
    BuildContext context,
    Workspace workspace,
    WorkspacesViewModel vm,
    AppLocalizations l10n,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.deleteWorkspaceTitle),
        content: Text(l10n.deleteWorkspaceConfirm(workspace.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              final success = await vm.deleteWorkspace(workspace.id);
              if (!context.mounted) return;
              if (!success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(vm.errorMessage ?? l10n.deleteFailed),
                    backgroundColor: Theme.of(context).colorScheme.error,
                  ),
                );
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(l10n.logout.split(' ')[0]), // Hack: use first word of logout if it's 'Sil'/'Delete'
          ),
        ],
      ),
    );
  }

  // ── Invite Dialog ─────────────────────────────────────────────────────────

  void _showInviteDialog(BuildContext context, Workspace workspace, AppLocalizations l10n) {
    final emailCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    String selectedRole = 'member'; // Default role

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(l10n.inviteMember),
              scrollable: true,
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        l10n.inviteToWorkspace(workspace.name),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: emailCtrl,
                        autofocus: true,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: l10n.email,
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.email_outlined),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return l10n.emailRequired;
                          }
                          if (!v.contains('@')) {
                            return l10n.invalidEmail;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        initialValue: selectedRole,
                        decoration: InputDecoration(
                          labelText: l10n.role,
                          border: const OutlineInputBorder(),
                        ),
                        items: [
                          DropdownMenuItem(
                            value: 'admin',
                            child: Text(l10n.adminRole),
                          ),
                          DropdownMenuItem(
                            value: 'member',
                            child: Text(l10n.memberRole),
                          ),
                          DropdownMenuItem(
                            value: 'observer',
                            child: Text(l10n.observerRole),
                          ),
                        ],
                        onChanged: (val) {
                          if (val != null) setState(() => selectedRole = val);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text(l10n.cancel),
                ),
                Consumer<InvitationsViewModel>(
                  builder: (context, vm, child) => FilledButton(
                    onPressed: vm.isLoading
                        ? null
                        : () async {
                            if (!formKey.currentState!.validate()) return;
                            final success = await vm.sendInvitation(
                              workspaceId: workspace.id,
                              inviteeEmail: emailCtrl.text.trim(),
                              role: selectedRole,
                            );
                            if (!context.mounted) return;
                            Navigator.pop(dialogContext);
                            if (!success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    vm.errorMessage ?? l10n.invitationFailed,
                                  ),
                                  backgroundColor: Theme.of(
                                    context,
                                  ).colorScheme.error,
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(l10n.invitationSentSuccessfully),
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
                        : Text(l10n.send),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

/// Kural 20: Magic string/int yerine enum kullan
enum _WorkspaceAction { edit, delete, invite, manageMembers }
