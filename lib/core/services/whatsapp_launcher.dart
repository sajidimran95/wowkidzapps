import 'package:my_first_app/data/models/whatsapp_chat_config.dart';
import 'package:url_launcher/url_launcher.dart';

class WhatsAppLauncher {
  WhatsAppLauncher._();

  static Future<bool> openChat(WhatsAppChatConfig config, {String? message}) async {
    if (!config.enabled || config.numberDigits.isEmpty) {
      return false;
    }

    final url = message == null || message.isEmpty
        ? (config.chatUrl ?? config.urlForText(config.prefillMessage))
        : config.urlForText(message);

    if (url.isEmpty) return false;

    final uri = Uri.parse(url);
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  static Future<bool> openProductOrder({
    required WhatsAppChatConfig config,
    required String productName,
    required String priceText,
    String? size,
    int? quantity,
    String? sku,
    String? productUrl,
  }) {
    final message = config.productOrderMessage(
      productName: productName,
      priceText: priceText,
      size: size,
      quantity: quantity,
      sku: sku,
      productUrl: productUrl,
    );
    return openChat(config, message: message);
  }
}
