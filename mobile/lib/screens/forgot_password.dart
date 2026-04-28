import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile/viewmodels/auth_viewmodel.dart';

/// Şifre sıfırlama (Şifremi Unuttum) ekranı — POST /password-recovery/{email}
/// Auth gerektirmez. E-posta girip sıfırlama linki ister.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleRecover() async {
    if (!_formKey.currentState!.validate()) return;

    final authVM = context.read<AuthViewModel>();
    final success = await authVM.recoverPassword(_emailController.text.trim());

    if (!mounted) return;

    if (success) {
      setState(() => _emailSent = true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authVM.errorMessage ?? 'İşlem başarısız'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Şifremi Unuttum')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: _emailSent
            ? _buildSuccessView(context)
            : _buildFormView(context),
      ),
    );
  }

  Widget _buildFormView(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 32),
          Icon(
            Icons.lock_reset_rounded,
            size: 64,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'Şifrenizi sıfırlayın',
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'E-posta adresinizi girin, size şifre sıfırlama bağlantısı gönderelim.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(
              labelText: 'E-posta',
              prefixIcon: Icon(Icons.email_outlined),
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'E-posta adresi gerekli';
              }
              if (!value.contains('@')) {
                return 'Geçerli bir e-posta adresi girin';
              }
              return null;
            },
            onFieldSubmitted: (_) => _handleRecover(),
          ),
          const SizedBox(height: 24),
          Consumer<AuthViewModel>(
            builder: (context, authVM, child) {
              return FilledButton(
                onPressed: authVM.isLoading ? null : _handleRecover,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: authVM.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Sıfırlama Bağlantısı Gönder'),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessView(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 64),
        Icon(
          Icons.mark_email_read_rounded,
          size: 80,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 24),
        Text(
          'E-posta gönderildi!',
          style: Theme.of(context).textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          '${_emailController.text.trim()} adresine şifre sıfırlama bağlantısı gönderildi. Lütfen e-postanızı kontrol edin.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        OutlinedButton(
          onPressed: () => Navigator.pop(context),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: const Text('Giriş Ekranına Dön'),
        ),
      ],
    );
  }
}
