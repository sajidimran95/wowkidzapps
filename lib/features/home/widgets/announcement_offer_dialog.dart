import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:my_first_app/data/api/wowkidz_api.dart';
import 'package:my_first_app/data/models/announcement_offer.dart';
import 'package:url_launcher/url_launcher.dart';

class AnnouncementOfferDialog extends StatefulWidget {
  const AnnouncementOfferDialog({super.key, required this.offer});

  final AnnouncementOffer offer;

  @override
  State<AnnouncementOfferDialog> createState() => _AnnouncementOfferDialogState();
}

class _AnnouncementOfferDialogState extends State<AnnouncementOfferDialog> {
  final _emailController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _subscribe() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email')),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      await WowKidzApi.instance.subscribeNewsletter(email);
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Subscribed successfully!')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _openLink() async {
    if (widget.offer.link.isEmpty) return;
    final uri = Uri.tryParse(widget.offer.link);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final offer = widget.offer;

    if (offer.isNewsletter) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (offer.imageUrl.isNotEmpty)
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: CachedNetworkImage(
                    imageUrl: offer.imageUrl,
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (offer.title.isNotEmpty)
                      Text(
                        offer.title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                    if (offer.details.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(offer.details),
                    ],
                    const SizedBox(height: 16),
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        hintText: 'Your email',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _submitting ? null : _subscribe,
                        child: _submitting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Subscribe'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Stack(
        children: [
          if (offer.imageUrl.isNotEmpty)
            GestureDetector(
              onTap: offer.link.isNotEmpty ? _openLink : null,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: CachedNetworkImage(
                  imageUrl: offer.imageUrl,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          Positioned(
            top: 4,
            right: 4,
            child: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close),
            ),
          ),
        ],
      ),
    );
  }
}
