import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_first_app/core/theme/app_colors.dart';
import 'package:my_first_app/features/auth/widgets/auth_ui.dart';
import 'package:my_first_app/shared/widgets/store_logo.dart';

enum AuthMethod { mobile, email }

class AuthHeader extends StatelessWidget {
  const AuthHeader({super.key, required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.orientationOf(context) == Orientation.landscape;

    return Container(
      width: double.infinity,
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(4, 4, 16, 20),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            ),
          ),
          StoreLogo.auth(
            width: isLandscape ? 280 : 220,
            height: 56,
          ),
        ],
      ),
    );
  }
}

class AuthMethodToggle extends StatelessWidget {
  const AuthMethodToggle({
    super.key,
    required this.method,
    required this.onChanged,
  });

  final AuthMethod method;
  final ValueChanged<AuthMethod> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: _Tab(
              label: 'Mobile',
              icon: Icons.phone_outlined,
              selected: method == AuthMethod.mobile,
              onTap: () => onChanged(AuthMethod.mobile),
            ),
          ),
          Expanded(
            child: _Tab(
              label: 'Email',
              icon: Icons.email_outlined,
              selected: method == AuthMethod.email,
              onTap: () => onChanged(AuthMethod.email),
            ),
          ),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: selected ? Colors.white : AppColors.textMuted,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: selected ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AuthInputField extends StatelessWidget {
  const AuthInputField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.keyboardType,
    this.obscure = false,
    this.suffix,
    this.validator,
    this.required = false,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final bool obscure;
  final Widget? suffix;
  final String? Function(String?)? validator;
  final bool required;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          required ? '$label*' : label,
          style: AuthTextStyles.label(context),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          keyboardType: obscure
              ? TextInputType.visiblePassword
              : keyboardType,
          autocorrect: !obscure,
          enableSuggestions: !obscure,
          textInputAction: obscure ? TextInputAction.done : TextInputAction.next,
          validator: validator,
          style: GoogleFonts.nunito(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.nunito(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textMuted,
            ),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 12, right: 4),
              child: AuthIconBadge(icon: icon),
            ),
            prefixIconConstraints: const BoxConstraints(minWidth: 56),
            suffixIcon: suffix,
            filled: true,
            fillColor: AppColors.background,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide(
                color: AppColors.primary.withValues(alpha: 0.15),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide(
                color: AppColors.primary.withValues(alpha: 0.15),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(color: AppColors.discount),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }
}

class AuthSocialButton extends StatelessWidget {
  const AuthSocialButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, color: AppColors.textPrimary),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        side: const BorderSide(color: AppColors.border),
        foregroundColor: AppColors.textPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }
}

bool isValidEmail(String value) {
  return RegExp(r'^[\w\.\-]+@([\w\-]+\.)+[\w\-]{2,}$').hasMatch(value.trim());
}

bool isValidPhone(String value) {
  return RegExp(r'^01\d{9}$').hasMatch(value.trim());
}

bool isValidEmailOrMobile(String value) {
  final trimmed = value.trim();
  if (trimmed.contains('@')) return isValidEmail(trimmed);
  return isValidPhone(trimmed);
}

({String? phone, String? email}) parseContact(String value) {
  final trimmed = value.trim();
  if (trimmed.contains('@')) {
    return (phone: null, email: trimmed);
  }
  return (phone: trimmed, email: null);
}

String? validateEmailOrMobile(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Email or mobile number is required';
  }
  if (!isValidEmailOrMobile(value)) {
    return 'Enter a valid email or 11-digit mobile (01XXXXXXXXX)';
  }
  return null;
}
