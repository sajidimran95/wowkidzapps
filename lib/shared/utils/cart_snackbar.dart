import 'package:flutter/material.dart';
import 'package:my_first_app/core/app/app_controller.dart';
import 'package:my_first_app/core/theme/app_colors.dart';

bool _cartDialogOpen = false;

void showAddedToCartSnackBar(BuildContext context, String productName) {
  if (_cartDialogOpen) {
    final nav = AppController.instance.navigatorKey.currentState;
    if (nav != null && nav.canPop()) {
      nav.pop();
    }
    _cartDialogOpen = false;
  }

  final navContext = AppController.instance.navigatorKey.currentContext ?? context;
  if (!navContext.mounted) return;

  _cartDialogOpen = true;

  showGeneralDialog<void>(
    context: navContext,
    barrierDismissible: true,
    barrierLabel: 'Dismiss',
    barrierColor: Colors.black.withValues(alpha: 0.32),
    transitionDuration: const Duration(milliseconds: 400),
    pageBuilder: (dialogContext, _, _) {
      return _CartAddSuccessDialog(
        productName: productName,
        onClose: () {
          if (dialogContext.mounted) {
            Navigator.of(dialogContext).pop();
          }
          _cartDialogOpen = false;
        },
        onViewCart: () {
          if (dialogContext.mounted) {
            Navigator.of(dialogContext).pop();
          }
          _cartDialogOpen = false;
          AppController.instance.goToCart(navContext);
        },
      );
    },
    transitionBuilder: (context, animation, _, child) {
      final curve = CurvedAnimation(parent: animation, curve: Curves.elasticOut);
      return FadeTransition(
        opacity: animation,
        child: ScaleTransition(scale: curve, child: child),
      );
    },
  ).whenComplete(() => _cartDialogOpen = false);
}

class _CartAddSuccessDialog extends StatefulWidget {
  const _CartAddSuccessDialog({
    required this.productName,
    required this.onClose,
    required this.onViewCart,
  });

  final String productName;
  final VoidCallback onClose;
  final VoidCallback onViewCart;

  @override
  State<_CartAddSuccessDialog> createState() => _CartAddSuccessDialogState();
}

class _CartAddSuccessDialogState extends State<_CartAddSuccessDialog> {
  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 3200), () {
      if (mounted) widget.onClose();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: SizedBox(
          width: 320,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.18),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.success,
                        size: 48,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Successfully Added!',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.success,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.productName,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Added to your cart',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: widget.onClose,
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              side: const BorderSide(color: AppColors.border),
                            ),
                            child: const Text('Continue'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: widget.onViewCart,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text('View Cart'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void showCartMessage(BuildContext context, String message) {
  final navContext = AppController.instance.navigatorKey.currentContext ?? context;
  if (!navContext.mounted) return;

  ScaffoldMessenger.of(navContext)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        persist: false,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
}
