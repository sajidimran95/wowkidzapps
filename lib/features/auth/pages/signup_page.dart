import 'package:flutter/material.dart';
import 'package:my_first_app/core/app/app_controller.dart';
import 'package:my_first_app/core/theme/app_colors.dart';
import 'package:my_first_app/features/auth/pages/customer_login_welcome_page.dart';
import 'package:my_first_app/features/auth/pages/verify_email_page.dart';
import 'package:my_first_app/features/auth/pages/login_page.dart';
import 'package:my_first_app/features/auth/widgets/auth_shared_widgets.dart';
import 'package:my_first_app/features/auth/widgets/auth_ui.dart';

enum RegisterAs { customer, vendor }

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _contactController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  RegisterAs _registerAs = RegisterAs.customer;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _contactController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String get _registerButtonLabel => _registerAs == RegisterAs.customer
      ? 'Join as Customer 🛍️'
      : 'Join as Vendor 🏪';

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final name = _nameController.text.trim();
    final role = _registerAs == RegisterAs.customer ? 'Customer' : 'Vendor';
    final contact = parseContact(_contactController.text.trim());
    final resolvedContact = contact.email ?? contact.phone;
    if (resolvedContact == null) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid email or mobile number.')),
      );
      return;
    }

    final result = await AppController.instance.signup(
      name: name,
      phone: contact.phone,
      email: contact.email,
      role: role,
      password: _passwordController.text,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result.needsVerification) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VerifyEmailPage(
            contact: result.contact ?? resolvedContact,
            password: _passwordController.text,
          ),
        ),
      );
      return;
    }

    if (!result.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.message ?? 'Registration failed')),
      );
      return;
    }

    if (_registerAs == RegisterAs.customer) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const CustomerLoginWelcomePage()),
        (route) => route.isFirst,
      );
    } else {
      Navigator.popUntil(context, (route) => route.isFirst);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Welcome $name! Registered as $role successfully.'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.success,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
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
                          title: 'Join WowKidz! 🎉',
                          subtitle:
                              'Create your account & discover amazing kids styles!',
                        ),
                        const SizedBox(height: 20),
                        AuthFormCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              AuthInputField(
                                controller: _nameController,
                                label: 'Full Name',
                                hint: 'What should we call you?',
                                icon: Icons.person_outline,
                                required: true,
                                validator: (v) => v == null || v.trim().isEmpty
                                    ? 'Full Name is required'
                                    : null,
                              ),
                              const SizedBox(height: 16),
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
                              _RegisterAsSelector(
                                value: _registerAs,
                                onChanged: (v) => setState(() => _registerAs = v),
                              ),
                              const SizedBox(height: 16),
                              AuthInputField(
                                controller: _passwordController,
                                label: 'Password',
                                hint: 'Pick a strong password',
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
                              const SizedBox(height: 16),
                              AuthInputField(
                                controller: _confirmPasswordController,
                                label: 'Confirm Password',
                                hint: 'Type password again',
                                icon: Icons.lock_outline,
                                obscure: _obscureConfirm,
                                suffix: IconButton(
                                  onPressed: () => setState(
                                    () => _obscureConfirm = !_obscureConfirm,
                                  ),
                                  icon: Icon(
                                    _obscureConfirm
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    color: AppColors.textMuted,
                                    size: 20,
                                  ),
                                ),
                                validator: (v) {
                                  if (v == null || v.isEmpty) {
                                    return 'Please confirm your password';
                                  }
                                  if (v != _passwordController.text) {
                                    return 'Passwords do not match';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 22),
                              AuthPrimaryButton(
                                label: _registerButtonLabel,
                                isLoading: _isLoading,
                                onPressed: _signup,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        AuthLinkRow(
                          prompt: 'Already have an account?',
                          actionLabel: 'Sign In',
                          onTap: () => Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LoginPage(),
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

class _RegisterAsSelector extends StatelessWidget {
  const _RegisterAsSelector({
    required this.value,
    required this.onChanged,
  });

  final RegisterAs value;
  final ValueChanged<RegisterAs> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('I want to*', style: AuthTextStyles.label(context)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _RoleCard(
                title: 'Shop',
                subtitle: 'Buy',
                icon: Icons.shopping_bag_outlined,
                selected: value == RegisterAs.customer,
                onTap: () => onChanged(RegisterAs.customer),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _RoleCard(
                title: 'Sell',
                subtitle: 'Store',
                icon: Icons.storefront_outlined,
                selected: value == RegisterAs.vendor,
                onTap: () => onChanged(RegisterAs.vendor),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.1)
              : AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: selected ? AppColors.primary : AppColors.textMuted,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AuthTextStyles.chipTitle(selected: selected).copyWith(
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AuthTextStyles.chipSubtitle(context).copyWith(
                      fontSize: 9,
                    ),
                  ),
                ],
              ),
            ),
            if (selected) ...[
              const SizedBox(width: 4),
              const Icon(Icons.check_circle, size: 12, color: AppColors.primary),
            ],
          ],
        ),
      ),
    );
  }
}
