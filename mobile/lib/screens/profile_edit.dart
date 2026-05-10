import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile/viewmodels/auth_viewmodel.dart';
import 'package:mobile/l10n/app_localizations.dart';

/// Profil düzenleme ekranı — PATCH /users/me
/// StatefulWidget (form — Kural 16), SingleChildScrollView (Kural 10).
class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _fullNameController;
  late final TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthViewModel>().currentUser;
    _fullNameController = TextEditingController(text: user?.fullName ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSave(AppLocalizations l10n) async {
    if (!_formKey.currentState!.validate()) return;

    final authVM = context.read<AuthViewModel>();
    final currentUser = authVM.currentUser;

    // Sadece değişen alanları gönder
    final newName = _fullNameController.text.trim();
    final newEmail = _emailController.text.trim();

    final nameChanged = newName != (currentUser?.fullName ?? '');
    final emailChanged = newEmail != (currentUser?.email ?? '');

    if (!nameChanged && !emailChanged) {
      Navigator.pop(context);
      return;
    }

    final success = await authVM.updateProfile(
      fullName: nameChanged ? newName : null,
      email: emailChanged ? newEmail : null,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.profileUpdatedSuccessfully)));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authVM.errorMessage ?? l10n.save), // generic error
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.editProfile),
        actions: [
          Consumer<AuthViewModel>(
            builder: (context, authVM, child) {
              return TextButton(
                onPressed: authVM.isLoading ? null : () => _handleSave(l10n),
                child: authVM.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l10n.save),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Profil fotoğrafı alanı
              Center(
                child: Consumer<AuthViewModel>(
                  builder: (context, authVM, child) {
                    final user = authVM.currentUser;
                    final initials = (user?.fullName ?? '?')
                        .split(' ')
                        .where((s) => s.isNotEmpty)
                        .take(2)
                        .map((s) => s[0].toUpperCase())
                        .join();

                    return CircleAvatar(
                      radius: 48,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      child: Text(
                        initials.isNotEmpty ? initials : '?',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 32),
              // Ad Soyad
              TextFormField(
                controller: _fullNameController,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: l10n.fullName,
                  prefixIcon: const Icon(Icons.person_outlined),
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.fullNameRequired;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // E-posta
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  labelText: l10n.email,
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.emailRequired;
                  }
                  if (!value.contains('@')) {
                    return l10n.invalidEmail;
                  }
                  return null;
                },
                onFieldSubmitted: (_) => _handleSave(l10n),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

