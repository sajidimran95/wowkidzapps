import 'package:flutter/material.dart';
import 'package:my_first_app/core/app/catalog_store.dart';
import 'package:my_first_app/core/theme/app_colors.dart';
import 'package:my_first_app/features/home/widgets/search_bar_widget.dart';
import 'package:my_first_app/shared/widgets/store_logo.dart';

class HomeAppBar extends StatefulWidget {
  const HomeAppBar({super.key});

  @override
  State<HomeAppBar> createState() => _HomeAppBarState();
}

class _HomeAppBarState extends State<HomeAppBar> {
  bool _searchActive = false;
  final _searchController = TextEditingController();
  final _searchFocus = FocusNode();

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _openSearch() {
    setState(() => _searchActive = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _searchFocus.requestFocus();
    });
  }

  void _closeSearch() {
    _searchController.clear();
    _searchFocus.unfocus();
    setState(() => _searchActive = false);
  }

  @override
  Widget build(BuildContext context) {
    final catalog = CatalogStore.instance;

    return SliverAppBar(
      floating: true,
      snap: true,
      pinned: false,
      elevation: 0,
      backgroundColor: AppColors.surface,
      title: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: _searchActive
            ? SearchBarWidget(
                key: const ValueKey('search'),
                inline: true,
                controller: _searchController,
                focusNode: _searchFocus,
                onSubmitted: (_) => _closeSearch(),
              )
            : ListenableBuilder(
                listenable: catalog,
                builder: (context, _) {
                  return Row(
                    key: const ValueKey('logo'),
                    children: [
                      const StoreLogo(size: 36, borderRadius: 10),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              catalog.appName,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.primary,
                                  ),
                            ),
                            Text(
                              catalog.tagline,
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(
                                    color: AppColors.textMuted,
                                    fontSize: 10,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
      ),
      actions: [
        if (_searchActive)
          IconButton(
            onPressed: _closeSearch,
            icon: const Icon(Icons.close, size: 24),
            tooltip: 'Close search',
          )
        else ...[
          IconButton(
            onPressed: _openSearch,
            icon: const Icon(Icons.search, size: 24),
            tooltip: 'Search',
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_outlined, size: 24),
            tooltip: 'Notifications',
          ),
        ],
        const SizedBox(width: 4),
      ],
    );
  }
}
