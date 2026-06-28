import 'package:flutter/material.dart';
import 'package:my_first_app/core/app/catalog_store.dart';
import 'package:my_first_app/core/services/whatsapp_launcher.dart';
import 'package:my_first_app/core/theme/app_colors.dart';
import 'package:my_first_app/features/dashboard/pages/addresses_page.dart';
import 'package:my_first_app/features/dashboard/pages/help_support_page.dart';
import 'package:my_first_app/features/dashboard/pages/profile_update_page.dart';

class DashboardMenuTab extends StatelessWidget {
  const DashboardMenuTab({
    super.key,
    this.onOrdersTap,
    this.onWishlistTap,
  });

  final VoidCallback? onOrdersTap;
  final VoidCallback? onWishlistTap;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Account Menu',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 12),
        _MenuCard(
          icon: Icons.person_outline,
          title: 'Update Profile',
          subtitle: 'Edit name, email and mobile',
          color: AppColors.primary,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProfileUpdatePage()),
          ),
        ),
        _MenuCard(
          icon: Icons.location_on_outlined,
          title: 'Addresses',
          subtitle: 'Saved addresses & create new',
          color: AppColors.success,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddressesPage()),
          ),
        ),
        _MenuCard(
          icon: Icons.favorite_border,
          title: 'Wishlist',
          subtitle: 'View saved products',
          color: AppColors.accent,
          onTap: onWishlistTap,
        ),
        _MenuCard(
          icon: Icons.help_outline,
          title: 'Help & Support',
          subtitle: 'Tickets list & create new ticket',
          color: AppColors.secondary,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const HelpSupportPage()),
          ),
        ),
        _MenuCard(
          icon: Icons.receipt_long_outlined,
          title: 'Order View',
          subtitle: 'Browse all orders and track status',
          color: AppColors.primary,
          onTap: onOrdersTap,
        ),
        _MenuCard(
          icon: Icons.privacy_tip_outlined,
          title: 'Privacy Policy',
          subtitle: 'How we protect your data',
          color: AppColors.textMuted,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Visit wowkidzbd.com for our privacy policy.'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        ListenableBuilder(
          listenable: CatalogStore.instance,
          builder: (context, _) {
            final wa = CatalogStore.instance.whatsapp;
            final contact = wa.displayContact;

            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.support_agent, color: AppColors.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Need help?',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                        Text(
                          contact.isNotEmpty
                              ? 'WhatsApp us at $contact'
                              : 'Open a support ticket above',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (wa.enabled)
                    IconButton(
                      onPressed: () => WhatsAppLauncher.openChat(wa),
                      icon: const Icon(Icons.chat, color: Color(0xFF25D366)),
                      tooltip: 'Chat on WhatsApp',
                    ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class _MenuCard extends StatelessWidget {
  const _MenuCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
