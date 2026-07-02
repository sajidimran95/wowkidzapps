import 'package:flutter/material.dart';
import 'package:my_first_app/core/app/app_controller.dart';
import 'package:my_first_app/core/theme/app_colors.dart';
import 'package:my_first_app/features/auth/pages/customer_login_welcome_page.dart';
import 'package:my_first_app/features/auth/pages/forgot_password_page.dart';
import 'package:my_first_app/features/auth/pages/verify_email_page.dart';
import 'package:my_first_app/features/auth/pages/signup_page.dart';
import 'package:my_first_app/features/auth/widgets/auth_shared_widgets.dart';
import 'package:my_first_app/features/auth/widgets/auth_ui.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _contactController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _contactController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final contact = parseContact(_contactController.text.trim());
    final resolved = contact.phone ?? contact.email ?? _contactController.text.trim();

    final result = await AppController.instance.login(
      contact: resolved,
      password: _passwordController.text,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result.needsVerification) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VerifyEmailPage(
            contact: result.contact ?? resolved,
            password: _passwordController.text,
          ),
        ),
      );
      return;
    }

    if (!result.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.message ?? 'Login failed')),
      );
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const CustomerLoginWelcomePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AuthPageBackground(
        child: SafeArea(
          child: Column(
            children: [
              AuthHeader(onBack: () => Navigator.pop(context)),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const AuthPageTitle(
                          title: 'Welcome Back! 👋',
                          subtitle:
                              'Sign in to shop cute kids fashion & toys!',
                        ),
                        const SizedBox(height: 20),
                        AuthFormCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              AuthInputField(
                                controller: _contactController,
                                label: 'Email / Mobile',
                                hint: 'Your email or phone number',
                                icon: Icons.alternate_email,
                                keyboardType: TextInputType.emailAddress,
                                required: true,
                                validator: validateEmailOrMobile,
                              ),
                              const SizedBox(height: 16),
                              AuthInputField(
                                controller: _passwordController,
                                label: 'Password',
                                hint: 'Your secret password',
                                icon: Icons.lock_outline,
                                obscure: _obscurePassword,
                                required: true,
                                suffix: IconButton(
                                  onPressed: () => setState(
                                    () => _obscurePassword = !_obscurePassword,
                                  ),
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    color: AppColors.textMuted,
                                    size: 20,
                                  ),
                                ),
                                validator: (v) {
                                  if (v == null || v.isEmpty) {
                                    return 'Password is required';
                                  }
                                  if (v.length < 6) {
                                    return 'Password must be at least 6 characters';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: Checkbox(
                                      value: _rememberMe,
                                      onChanged: (v) => setState(
                                        () => _rememberMe = v ?? false,
                                      ),
                                      activeColor: AppColors.primary,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Remember me',
                                    style: AuthTextStyles.body(context),
                                  ),
                                  const Spacer(),
                                  TextButton(
                                    onPressed: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const ForgotPasswordPage(),
                                      ),
                                    ),
                                    child: Text(
                                      'Forgot?',
                                      style: AuthTextStyles.link(context),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              AuthPrimaryButton(
                                label: 'Let\'s Go! 🚀',
                                isLoading: _isLoading,
                                onPressed: _login,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        AuthLinkRow(
                          prompt: 'New here?',
                          actionLabel: 'Create Account',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SignupPage(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
