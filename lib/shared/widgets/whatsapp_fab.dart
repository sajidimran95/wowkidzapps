import 'package:flutter/material.dart';
import 'package:my_first_app/core/app/catalog_store.dart';
import 'package:my_first_app/core/services/whatsapp_launcher.dart';

/// Floating WhatsApp chat button — same role as the website footer chat icon.
class WhatsAppFab extends StatelessWidget {
  const WhatsAppFab({super.key});

  @override
  Widget build(BuildContext context) {
    final config = CatalogStore.instance.whatsapp;

    if (!config.enabled) {
      return const SizedBox.shrink();
    }

    return FloatingActionButton(
      onPressed: () => WhatsAppLauncher.openChat(config),
      backgroundColor: const Color(0xFF25D366),
      tooltip: 'Chat on WhatsApp',
      child: const Icon(Icons.chat, color: Colors.white),
    );
  }
}
