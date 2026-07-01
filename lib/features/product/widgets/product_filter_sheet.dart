import 'package:flutter/material.dart';
import 'package:my_first_app/core/theme/app_colors.dart';
import 'package:my_first_app/shared/utils/product_filters.dart';

Future<ProductFilterCriteria?> showProductFilterSheet({
  required BuildContext context,
  required ProductFilterCriteria initial,
  required List<String> categories,
  required List<String> sizes,
  required List<String> colors,
  bool showCategoryFilter = true,
}) {
  return showModalBottomSheet<ProductFilterCriteria>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => _ProductFilterSheet(
      initial: initial,
      categories: categories,
      sizes: sizes,
      colors: colors,
      showCategoryFilter: showCategoryFilter,
    ),
  );
}

class _ProductFilterSheet extends StatefulWidget {
  const _ProductFilterSheet({
    required this.initial,
    required this.categories,
    required this.sizes,
    required this.colors,
    required this.showCategoryFilter,
  });

  final ProductFilterCriteria initial;
  final List<String> categories;
  final List<String> sizes;
  final List<String> colors;
  final bool showCategoryFilter;

  @override
  State<_ProductFilterSheet> createState() => _ProductFilterSheetState();
}

class _ProductFilterSheetState extends State<_ProductFilterSheet> {
  late String? _category = widget.initial.category;
  late String? _size = widget.initial.size;
  late String? _color = widget.initial.color;
  late ProductSort _sort = widget.initial.sort;

  ProductFilterCriteria get _criteria => ProductFilterCriteria(
        category: _category,
        size: _size,
        color: _color,
        sort: _sort,
      );

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 12, 20, 20 + bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                'Filter Products',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  setState(() {
                    _category = null;
                    _size = null;
                    _color = null;
                    _sort = ProductSort.popular;
                  });
                },
                child: const Text('Reset'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(context).height * 0.55,
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionTitle('Sort by'),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: ProductSort.values.map((sort) {
                      final selected = _sort == sort;
                      return ChoiceChip(
                        label: Text(ProductFilterCriteria.sortLabel(sort)),
                        selected: selected,
                        onSelected: (_) => setState(() => _sort = sort),
                        selectedColor:
                            AppColors.primary.withValues(alpha: 0.15),
                        labelStyle: TextStyle(
                          color: selected
                              ? AppColors.primary
                              : AppColors.textSecondary,
                          fontWeight:
                              selected ? FontWeight.w600 : FontWeight.w500,
                          fontSize: 12,
                        ),
                      );
                    }).toList(),
                  ),
                  if (widget.showCategoryFilter &&
                      widget.categories.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    _SectionTitle('Category'),
                    _OptionChips(
                      options: widget.categories,
                      selected: _category,
                      onSelected: (value) =>
                          setState(() => _category = value),
                    ),
                  ],
                  if (widget.sizes.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    _SectionTitle('Size'),
                    _OptionChips(
                      options: widget.sizes,
                      selected: _size,
                      onSelected: (value) => setState(() => _size = value),
                    ),
                  ],
                  if (widget.colors.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    _SectionTitle('Color'),
                    _OptionChips(
                      options: widget.colors,
                      selected: _color,
                      onSelected: (value) => setState(() => _color = value),
                    ),
                  ],
                  if (widget.sizes.isEmpty && widget.colors.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(
                        'Size and color filters appear when products include those options.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textMuted,
                            ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => Navigator.pop(context, _criteria),
              child: const Text('Apply Filters'),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        label,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class _OptionChips extends StatelessWidget {
  const _OptionChips({
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  final List<String> options;
  final String? selected;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((option) {
        final isSelected = selected == option;
        return FilterChip(
          label: Text(option),
          selected: isSelected,
          onSelected: (_) => onSelected(isSelected ? null : option),
          selectedColor: AppColors.primary.withValues(alpha: 0.15),
          checkmarkColor: AppColors.primary,
          labelStyle: TextStyle(
            color: isSelected ? AppColors.primary : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            fontSize: 12,
          ),
        );
      }).toList(),
    );
  }
}
