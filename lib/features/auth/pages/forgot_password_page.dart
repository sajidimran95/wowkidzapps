import 'package:flutter/material.dart';
import 'package:my_first_app/core/app/app_controller.dart';
import 'package:my_first_app/core/theme/app_colors.dart';
import 'package:my_first_app/features/auth/pages/reset_password_page.dart';
import 'package:my_first_app/features/auth/widgets/auth_shared_widgets.dart';
import 'package:my_first_app/features/auth/widgets/auth_ui.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _contactController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _contactController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final contact = parseContact(_contactController.text.trim());
    final resolved = contact.email ?? contact.phone ?? _contactController.text.trim();

    final error = await AppController.instance.requestPasswordReset(
      contact: resolved,
    );
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ResetPasswordPage(contact: resolved),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            AuthHeader(onBack: () => Navigator.pop(context)),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                child: AuthFormCard(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AuthPageTitle(
                          title: 'Forgot Password',
                          subtitle:
                              'Enter your email. We will send a 6-digit reset code.',
                        ),
                        const SizedBox(height: 20),
                        AuthInputField(
                          controller: _contactController,
                          label: 'Email or Mobile',
                          hint: 'you@email.com or 01XXXXXXXXX',
                          icon: Icons.alternate_email_outlined,
                          validator: validateEmailOrMobile,
                        ),
                        const SizedBox(height: 20),
                        AuthPrimaryButton(
                          label: 'Send Reset Code',
                          isLoading: _isLoading,
                          onPressed: _submit,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
