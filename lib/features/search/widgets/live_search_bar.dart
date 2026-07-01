import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:my_first_app/core/app/catalog_store.dart';
import 'package:my_first_app/core/theme/app_colors.dart';
import 'package:my_first_app/data/models/product.dart';
import 'package:my_first_app/features/product/pages/product_detail_page.dart';
import 'package:my_first_app/features/search/services/image_search_service.dart';
import 'package:my_first_app/features/search/services/voice_search_service.dart';
import 'package:my_first_app/shared/utils/search_navigation.dart';

class LiveSearchBar extends StatefulWidget {
  const LiveSearchBar({
    super.key,
    this.inline = false,
    this.autofocus = false,
    this.controller,
    this.focusNode,
    this.onSubmitted,
    this.hintText = 'Search kids clothing, toys & more...',
  });

  final bool inline;
  final bool autofocus;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final ValueChanged<String>? onSubmitted;
  final String hintText;

  @override
  State<LiveSearchBar> createState() => _LiveSearchBarState();
}

class _LiveSearchBarState extends State<LiveSearchBar> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  late final bool _ownsController;
  late final bool _ownsFocusNode;

  final _layerLink = LayerLink();
  final _barKey = GlobalKey();
  OverlayEntry? _overlayEntry;

  Timer? _debounce;
  List<Product> _suggestions = [];
  bool _loadingSuggestions = false;
  bool _listening = false;
  bool _imageSearching = false;

  static const _minQueryLength = 2;
  static const _suggestionLimit = 8;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _ownsFocusNode = widget.focusNode == null;
    _controller = widget.controller ?? TextEditingController();
    _focusNode = widget.focusNode ?? FocusNode();
    _controller.addListener(_onQueryChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _removeOverlay();
    _debounce?.cancel();
    _controller.removeListener(_onQueryChanged);
    _focusNode.removeListener(_onFocusChanged);
    if (_ownsController) _controller.dispose();
    if (_ownsFocusNode) _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChanged() {
    if (_focusNode.hasFocus) {
      _scheduleSuggestions();
      _showOverlay();
    } else {
      Future.delayed(const Duration(milliseconds: 150), () {
        if (!_focusNode.hasFocus) _removeOverlay();
      });
    }
    setState(() {});
  }

  void _onQueryChanged() {
    _scheduleSuggestions();
    if (_focusNode.hasFocus) {
      _showOverlay();
    }
  }

  void _scheduleSuggestions() {
    _debounce?.cancel();
    final query = _controller.text.trim();
    if (query.length < _minQueryLength) {
      setState(() {
        _suggestions = [];
        _loadingSuggestions = false;
      });
      _overlayEntry?.markNeedsBuild();
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 350), () async {
      setState(() => _loadingSuggestions = true);
      _overlayEntry?.markNeedsBuild();

      try {
        final products = await CatalogStore.instance.searchSuggestions(
          query,
          limit: _suggestionLimit,
        );
        if (!mounted) return;
        setState(() {
          _suggestions = products;
          _loadingSuggestions = false;
        });
      } catch (_) {
        if (!mounted) return;
        setState(() {
          _suggestions = [];
          _loadingSuggestions = false;
        });
      }
      _overlayEntry?.markNeedsBuild();
    });
  }

  void _showOverlay() {
    if (_overlayEntry != null) {
      _overlayEntry!.markNeedsBuild();
      return;
    }

    _overlayEntry = OverlayEntry(builder: (context) => _buildOverlay());
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  Widget _buildOverlay() {
    final box = _barKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !_focusNode.hasFocus) {
      return const SizedBox.shrink();
    }

    final query = _controller.text.trim();
    final showPanel = query.length >= _minQueryLength;

    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            onTap: () {
              _focusNode.unfocus();
              _removeOverlay();
            },
            behavior: HitTestBehavior.translucent,
            child: const SizedBox.expand(),
          ),
        ),
        CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0, box.size.height + 6),
          child: Material(
            elevation: 10,
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
            clipBehavior: Clip.antiAlias,
            child: SizedBox(
              width: box.size.width,
              child: showPanel
                  ? _SuggestionsPanel(
                      loading: _loadingSuggestions,
                      products: _suggestions,
                      query: query,
                      onProductTap: _openProduct,
                      onViewAll: _openAllResults,
                    )
                  : const SizedBox.shrink(),
            ),
          ),
        ),
      ],
    );
  }

  void _submitSearch([String? value]) {
    final query = (value ?? _controller.text).trim();
    if (query.isEmpty) return;
    _focusNode.unfocus();
    _removeOverlay();
    if (widget.onSubmitted != null) {
      widget.onSubmitted!(query);
    } else {
      openProductSearch(context, query);
    }
  }

  void _openProduct(Product product) {
    _focusNode.unfocus();
    _removeOverlay();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductDetailPage(product: product),
      ),
    );
  }

  void _openAllResults() {
    final query = _controller.text.trim();
    if (query.isEmpty) return;
    _focusNode.unfocus();
    _removeOverlay();
    openProductSearch(context, query);
  }

  Future<void> _startVoiceSearch() async {
    if (_listening) {
      await VoiceSearchService.instance.stop();
      setState(() => _listening = false);
      return;
    }

    setState(() => _listening = true);
    final text = await VoiceSearchService.instance.listen();
    if (!mounted) return;

    setState(() => _listening = false);
    if (text == null || text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not hear anything. Try again.')),
      );
      return;
    }

    _controller.text = text.trim();
    _controller.selection = TextSelection.fromPosition(
      TextPosition(offset: _controller.text.length),
    );
    _focusNode.requestFocus();
    _scheduleSuggestions();
    _showOverlay();
  }

  Future<void> _startImageSearch() async {
    if (_imageSearching) return;

    setState(() => _imageSearching = true);
    _focusNode.unfocus();
    _removeOverlay();

    try {
      final result =
          await ImageSearchService.instance.pickAndSearch(context);
      if (!mounted) return;

      if (result == null) return;

      if (result.products.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'No similar products found. Try another photo or type a keyword.',
            ),
          ),
        );
        return;
      }

      openProductSearch(
        context,
        result.query.isNotEmpty ? result.query : 'Image search',
        initialProducts: result.products,
      );
    } finally {
      if (mounted) setState(() => _imageSearching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final field = CompositedTransformTarget(
      key: _barKey,
      link: _layerLink,
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        autofocus: widget.autofocus,
        onSubmitted: _submitSearch,
        textInputAction: TextInputAction.search,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 14),
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textMuted,
                fontSize: 13,
              ),
          prefixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: _imageSearching ? null : _startImageSearch,
                icon: _imageSearching
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(
                        Icons.photo_camera_outlined,
                        color: AppColors.textMuted,
                        size: 20,
                      ),
                tooltip: 'Search by image',
                visualDensity: VisualDensity.compact,
              ),
              IconButton(
                onPressed: _startVoiceSearch,
                icon: Icon(
                  _listening ? Icons.mic : Icons.mic_none_outlined,
                  color: _listening ? AppColors.primary : AppColors.textMuted,
                  size: 20,
                ),
                tooltip: _listening ? 'Stop listening' : 'Voice search',
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 88),
          suffixIcon: IconButton(
            onPressed: () => _submitSearch(),
            icon: const Icon(Icons.search, color: AppColors.primary, size: 22),
            tooltip: 'Search',
          ),
          filled: true,
          fillColor: AppColors.categoryPink,
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
          isDense: true,
        ),
      ),
    );

    if (widget.inline) return field;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      child: field,
    );
  }
}

class _SuggestionsPanel extends StatelessWidget {
  const _SuggestionsPanel({
    required this.loading,
    required this.products,
    required this.query,
    required this.onProductTap,
    required this.onViewAll,
  });

  final bool loading;
  final List<Product> products;
  final String query;
  final ValueChanged<Product> onProductTap;
  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Center(
          child: SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    if (products.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          'No products found for "$query"',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textMuted,
              ),
        ),
      );
    }

    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 360),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: products.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final product = products[index];
                return _SuggestionTile(
                  product: product,
                  onTap: () => onProductTap(product),
                );
              },
            ),
          ),
          const Divider(height: 1),
          TextButton(
            onPressed: onViewAll,
            child: const Text('View all result'),
          ),
        ],
      ),
    );
  }
}

class _SuggestionTile extends StatelessWidget {
  const _SuggestionTile({
    required this.product,
    required this.onTap,
  });

  final Product product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: product.imageUrl,
                width: 52,
                height: 52,
                fit: BoxFit.cover,
                placeholder: (_, _) => Container(
                  width: 52,
                  height: 52,
                  color: AppColors.categoryPink,
                ),
                errorWidget: (_, _, _) => Container(
                  width: 52,
                  height: 52,
                  color: AppColors.categoryPink,
                  child: const Icon(Icons.image_not_supported_outlined),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: List.generate(
                      5,
                      (_) => const Icon(
                        Icons.star_border,
                        size: 14,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.formattedSalePrice,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
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
}
