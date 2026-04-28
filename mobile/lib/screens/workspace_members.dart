import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile/viewmodels/workspaces_viewmodel.dart';
import 'package:mobile/viewmodels/auth_viewmodel.dart';
import 'package:mobile/domain/models/workspace.dart';
import 'package:mobile/domain/models/workspace_member.dart';

class WorkspaceMembersScreen extends StatefulWidget {
  final Workspace workspace;

  const WorkspaceMembersScreen({super.key, required this.workspace});

  @override
  State<WorkspaceMembersScreen> createState() => _WorkspaceMembersScreenState();
}

class _WorkspaceMembersScreenState extends State<WorkspaceMembersScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        context.read<WorkspacesViewModel>().fetchWorkspaceMembers(
          widget.workspace.id,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.workspace.name} Üyeleri')),
      body: Consumer<WorkspacesViewModel>(
        builder: (context, vm, child) {
          if (vm.isLoading && vm.currentMembers.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (vm.errorMessage != null && vm.currentMembers.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  vm.errorMessage!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          if (vm.currentMembers.isEmpty) {
            return const Center(child: Text('Henüz üye bulunmuyor.'));
          }

          return RefreshIndicator(
            onRefresh: () => vm.fetchWorkspaceMembers(widget.workspace.id),
            child: ListView.separated(
              itemCount: vm.currentMembers.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final detail = vm.currentMembers[index];
                return _MemberTile(
                  detail: detail,
                  workspaceId: widget.workspace.id,
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _MemberTile extends StatelessWidget {
  final WorkspaceMemberDetail detail;
  final String workspaceId;

  const _MemberTile({required this.detail, required this.workspaceId});

  @override
  Widget build(BuildContext context) {
    final authVM = context.read<AuthViewModel>();
    final currentUserId = authVM.currentUser?.id;
    final isMe = detail.member.userId == currentUserId;

    // Check if current user is owner or admin to allow edits.
    // In a real app we'd check the current user's role in this workspace.
    // For now, if it's not "me", let's assume we can edit if we are not the one being edited.
    // A better approach is to check if I am an admin.
    final myMember = context
        .read<WorkspacesViewModel>()
        .currentMembers
        .firstWhere(
          (m) => m.member.userId == currentUserId,
          orElse: () => detail, // fallback
        );
    final isImAdmin =
        myMember.member.role == 'admin' || myMember.member.role == 'owner';

    final canEdit = isImAdmin && !isMe && detail.member.role != 'owner';

    String displayName =
        detail.fullName ?? detail.email ?? 'Bilinmeyen Kullanıcı';
    String initial = displayName.isNotEmpty
        ? displayName[0].toUpperCase()
        : '?';

    return ListTile(
      leading: CircleAvatar(child: Text(initial)),
      title: Text(
        displayName,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Row(
        children: [
          _RoleBadge(role: detail.member.role),
          if (isMe) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Ben',
                style: TextStyle(
                  fontSize: 10,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
      trailing: canEdit
          ? PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'remove') {
                  _showRemoveDialog(context);
                } else {
                  _updateRole(context, value);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'admin', child: Text('Admin Yap')),
                const PopupMenuItem(value: 'member', child: Text('Member Yap')),
                const PopupMenuItem(
                  value: 'observer',
                  child: Text('Observer Yap'),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem(
                  value: 'remove',
                  child: Text(
                    'Üyeyi Çıkar',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            )
          : null,
    );
  }

  Future<void> _updateRole(BuildContext context, String newRole) async {
    final vm = context.read<WorkspacesViewModel>();
    final success = await vm.updateMemberRole(
      workspaceId,
      detail.member.id,
      newRole,
    );
    if (!context.mounted) return;
    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(vm.errorMessage ?? 'Rol güncellenemedi'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  void _showRemoveDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Üyeyi Çıkar'),
        content: Text(
          'Bu üyeyi çalışma alanından çıkarmak istediğinize emin misiniz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('İptal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () async {
              final vm = context.read<WorkspacesViewModel>();
              final success = await vm.removeMember(
                workspaceId,
                detail.member.id,
              );
              if (!context.mounted) return;
              Navigator.pop(dialogContext);
              if (!success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(vm.errorMessage ?? 'Üye çıkarılamadı'),
                    backgroundColor: Theme.of(context).colorScheme.error,
                  ),
                );
              }
            },
            child: const Text('Çıkar'),
          ),
        ],
      ),
    );
  }
}

class _RoleBadge extends StatelessWidget {
  final String role;

  const _RoleBadge({required this.role});

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;

    switch (role.toLowerCase()) {
      case 'owner':
      case 'admin':
        bgColor = Colors.deepPurple.shade100;
        textColor = Colors.deepPurple.shade900;
        break;
      case 'observer':
        bgColor = Colors.grey.shade200;
        textColor = Colors.grey.shade800;
        break;
      case 'member':
      default:
        bgColor = Colors.blue.shade100;
        textColor = Colors.blue.shade900;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        role.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          color: textColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
