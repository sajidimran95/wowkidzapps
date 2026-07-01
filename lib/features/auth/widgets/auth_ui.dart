import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_first_app/core/theme/app_colors.dart';

/// Playful kids-brand typography for login & registration.
abstract final class AuthTextStyles {
  static TextStyle title(BuildContext context) => GoogleFonts.fredoka(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: AppColors.primary,
        height: 1.15,
      );

  static TextStyle subtitle(BuildContext context) => GoogleFonts.nunito(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
        height: 1.4,
      );

  static TextStyle label(BuildContext context) => GoogleFonts.nunito(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      );

  static TextStyle body(BuildContext context) => GoogleFonts.nunito(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
      );

  static TextStyle link(BuildContext context) => GoogleFonts.fredoka(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: AppColors.primary,
      );

  static TextStyle button(BuildContext context) => GoogleFonts.fredoka(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      );

  static TextStyle chipTitle({required bool selected}) => GoogleFonts.fredoka(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: selected ? AppColors.primary : AppColors.textPrimary,
      );

  static TextStyle chipSubtitle(BuildContext context) => GoogleFonts.nunito(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: AppColors.textMuted,
      );
}

class AuthPageBackground extends StatelessWidget {
  const AuthPageBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFFFF0F6),
            AppColors.background,
            Color(0xFFF3EEFF),
          ],
        ),
      ),
      child: child,
    );
  }
}

class AuthPageTitle extends StatelessWidget {
  const AuthPageTitle({
    super.key,
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AuthTextStyles.title(context)),
        const SizedBox(height: 8),
        Text(subtitle, style: AuthTextStyles.subtitle(context)),
      ],
    );
  }
}

class AuthFormCard extends StatelessWidget {
  const AuthFormCard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.12)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class AuthPrimaryButton extends StatelessWidget {
  const AuthPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, Color(0xFFFF6B9D)],
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.28),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(label, style: AuthTextStyles.button(context)),
      ),
    );
  }
}

class AuthLinkRow extends StatelessWidget {
  const AuthLinkRow({
    super.key,
    required this.prompt,
    required this.actionLabel,
    required this.onTap,
  });

  final String prompt;
  final String actionLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(prompt, style: AuthTextStyles.body(context)),
        GestureDetector(
          onTap: onTap,
          child: Text(' $actionLabel', style: AuthTextStyles.link(context)),
        ),
      ],
    );
  }
}

class AuthIconBadge extends StatelessWidget {
  const AuthIconBadge({super.key, required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, size: 20, color: AppColors.primary),
    );
  }
}
