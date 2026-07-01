import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_first_app/core/app/catalog_store.dart';
import 'package:my_first_app/data/models/product.dart';

class ImageSearchService {
  ImageSearchService._();
  static final ImageSearchService instance = ImageSearchService._();

  final _picker = ImagePicker();

  Future<ImageSearchResult?> pickAndSearch(BuildContext context) async {
    final source = await _pickSource(context);
    if (source == null) return null;

    final file = await _picker.pickImage(
      source: source,
      maxWidth: 1280,
      imageQuality: 85,
    );
    if (file == null) return null;

    final apiProducts =
        await CatalogStore.instance.searchProductsByImage(file.path);
    if (apiProducts.isNotEmpty) {
      return ImageSearchResult(
        products: apiProducts,
        query: 'Similar products',
        source: ImageSearchSource.api,
        imagePath: file.path,
      );
    }

    final labels = await _labelsFromImage(file.path);
    if (labels.isEmpty) {
      return ImageSearchResult(
        products: const [],
        query: '',
        source: ImageSearchSource.failed,
        imagePath: file.path,
      );
    }

    final query = labels.join(' ');
    final products = await CatalogStore.instance.searchProducts(query);
    return ImageSearchResult(
      products: products,
      query: query,
      source: ImageSearchSource.labels,
      imagePath: file.path,
    );
  }

  Future<ImageSource?> _pickSource(BuildContext context) {
    return showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: const Text('Take a photo'),
                onTap: () =>
                    Navigator.pop(sheetContext, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Choose from gallery'),
                onTap: () =>
                    Navigator.pop(sheetContext, ImageSource.gallery),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<List<String>> _labelsFromImage(String path) async {
    if (kIsWeb) return [];

    final labeler = ImageLabeler(
      options: ImageLabelerOptions(confidenceThreshold: 0.65),
    );

    try {
      final labels = await labeler.processImage(InputImage.fromFilePath(path));
      return labels
          .map((label) => label.label.trim())
          .where((label) => label.isNotEmpty)
          .take(3)
          .toList();
    } catch (_) {
      return [];
    } finally {
      await labeler.close();
    }
  }
}

enum ImageSearchSource { api, labels, failed }

class ImageSearchResult {
  const ImageSearchResult({
    required this.products,
    required this.query,
    required this.source,
    required this.imagePath,
  });

  final List<Product> products;
  final String query;
  final ImageSearchSource source;
  final String imagePath;
}
