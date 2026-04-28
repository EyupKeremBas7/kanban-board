import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile/viewmodels/workspaces_viewmodel.dart';
import 'package:mobile/viewmodels/invitations_viewmodel.dart';
import 'package:mobile/domain/models/workspace.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Çalışma Alanları'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Yenile',
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
                    label: const Text('Tekrar Dene'),
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
                    'Henüz çalışma alanı yok',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Yeni bir çalışma alanı oluşturun',
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
        onPressed: () => _showCreateWorkspaceDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Yeni Alan'),
      ),
    );
  }

  // ── Create Dialog ──────────────────────────────────────────────────────

  void _showCreateWorkspaceDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Yeni Çalışma Alanı'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameCtrl,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Alan Adı',
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Ad gerekli';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: descCtrl,
                decoration: const InputDecoration(
                  labelText: 'Açıklama (isteğe bağlı)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('İptal'),
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
                            content: Text(vm.errorMessage ?? 'Oluşturulamadı'),
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.error,
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Çalışma alanı oluşturuldu'),
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
    final vm = context.read<WorkspacesViewModel>();

    return Card(
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
                _showEditDialog(context, workspace, vm);
              case _WorkspaceAction.delete:
                _showDeleteConfirm(context, workspace, vm);
              case _WorkspaceAction.invite:
                _showInviteDialog(context, workspace);
            }
          },
          itemBuilder: (_) => const [
            PopupMenuItem(
              value: _WorkspaceAction.invite,
              child: Row(
                children: [
                  Icon(Icons.person_add_alt_1_outlined, size: 18),
                  SizedBox(width: 8),
                  Text('Üye Davet Et'),
                ],
              ),
            ),
            PopupMenuItem(
              value: _WorkspaceAction.edit,
              child: Row(
                children: [
                  Icon(Icons.edit_outlined, size: 18),
                  SizedBox(width: 8),
                  Text('Düzenle'),
                ],
              ),
            ),
            PopupMenuItem(
              value: _WorkspaceAction.delete,
              child: Row(
                children: [
                  Icon(Icons.delete_outline, size: 18, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Sil', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Edit Dialog ─────────────────────────────────────────────────────────

  void _showEditDialog(
    BuildContext context,
    Workspace workspace,
    WorkspacesViewModel vm,
  ) {
    final nameCtrl = TextEditingController(text: workspace.name);
    final descCtrl = TextEditingController(text: workspace.description ?? '');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Çalışma Alanını Düzenle'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameCtrl,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Alan Adı',
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Ad gerekli';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: descCtrl,
                decoration: const InputDecoration(
                  labelText: 'Açıklama',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('İptal'),
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
                              vm2.errorMessage ?? 'Güncelleme başarısız',
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

  // ── Delete Confirm ──────────────────────────────────────────────────────

  void _showDeleteConfirm(
    BuildContext context,
    Workspace workspace,
    WorkspacesViewModel vm,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Çalışma Alanını Sil'),
        content: Text(
          '"${workspace.name}" çalışma alanı silinecektir. '
          'Bu işlem geri alınamaz.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('İptal'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              final success = await vm.deleteWorkspace(workspace.id);
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
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }

  // ── Invite Dialog ─────────────────────────────────────────────────────────

  void _showInviteDialog(BuildContext context, Workspace workspace) {
    final emailCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    String selectedRole = 'member'; // Default role

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Üye Davet Et'),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${workspace.name} alanına yeni bir üye davet edin.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: emailCtrl,
                      autofocus: true,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'E-posta Adresi',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'E-posta gerekli';
                        }
                        if (!v.contains('@')) {
                          return 'Geçerli bir e-posta girin';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: selectedRole,
                      decoration: const InputDecoration(
                        labelText: 'Rol',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'admin',
                          child: Text('Yönetici (Admin)'),
                        ),
                        DropdownMenuItem(
                          value: 'member',
                          child: Text('Üye (Member)'),
                        ),
                        DropdownMenuItem(
                          value: 'observer',
                          child: Text('Gözlemci (Observer)'),
                        ),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => selectedRole = val);
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
                                    vm.errorMessage ?? 'Davet gönderilemedi',
                                  ),
                                  backgroundColor: Theme.of(
                                    context,
                                  ).colorScheme.error,
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Davet başarıyla gönderildi'),
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
          },
        );
      },
    );
  }
}

/// Kural 20: Magic string/int yerine enum kullan
enum _WorkspaceAction { edit, delete, invite }
