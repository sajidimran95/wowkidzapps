import 'package:flutter/material.dart';
import 'package:my_first_app/core/theme/app_colors.dart';

String customerInitialsFromName(String? name) {
  final trimmed = name?.trim() ?? '';
  if (trimmed.isEmpty) return 'C';

  final parts = trimmed.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
  if (parts.length == 1) {
    final word = parts.first;
    return word.length >= 2
        ? word.substring(0, 2).toUpperCase()
        : word[0].toUpperCase();
  }
  return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
}

class CustomerProfileAvatar extends StatelessWidget {
  const CustomerProfileAvatar({
    super.key,
    this.imageUrl,
    required this.name,
    this.radius = 32,
    this.backgroundColor,
    this.foregroundColor,
    this.fontSize,
  });

  final String? imageUrl;
  final String name;
  final double radius;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? fontSize;

  @override
  Widget build(BuildContext context) {
    final initials = customerInitialsFromName(name);
    final bg = backgroundColor ?? AppColors.primary.withValues(alpha: 0.15);
    final fg = foregroundColor ?? AppColors.primary;
    final textSize = fontSize ?? radius * 0.85;

    if (imageUrl == null || imageUrl!.trim().isEmpty) {
      return _InitialsAvatar(
        radius: radius,
        initials: initials,
        backgroundColor: bg,
        foregroundColor: fg,
        fontSize: textSize,
      );
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: bg,
      child: ClipOval(
        child: Image.network(
          imageUrl!,
          width: radius * 2,
          height: radius * 2,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _InitialsAvatar(
            radius: radius,
            initials: initials,
            backgroundColor: bg,
            foregroundColor: fg,
            fontSize: textSize,
          ),
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return SizedBox(
              width: radius * 2,
              height: radius * 2,
              child: Center(
                child: SizedBox(
                  width: radius * 0.5,
                  height: radius * 0.5,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: fg,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _InitialsAvatar extends StatelessWidget {
  const _InitialsAvatar({
    required this.radius,
    required this.initials,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.fontSize,
  });

  final double radius;
  final String initials;
  final Color backgroundColor;
  final Color foregroundColor;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor,
      child: Text(
        initials,
        style: TextStyle(
          color: foregroundColor,
          fontSize: fontSize,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
