import 'package:flutter/material.dart';
import 'package:my_first_app/core/app/catalog_store.dart';
import 'package:my_first_app/core/theme/app_colors.dart';
import 'package:my_first_app/shared/widgets/store_logo.dart';

class HomeAppBar extends StatelessWidget {
  const HomeAppBar({super.key, this.onSearchTap});

  final VoidCallback? onSearchTap;

  @override
  Widget build(BuildContext context) {
    final catalog = CatalogStore.instance;

    return SliverAppBar(
      floating: true,
      snap: true,
      pinned: false,
      elevation: 0,
      backgroundColor: AppColors.surface,
      title: ListenableBuilder(
        listenable: catalog,
        builder: (context, _) {
          final isLandscape =
              MediaQuery.orientationOf(context) == Orientation.landscape;

          return Align(
            alignment: Alignment.centerLeft,
            child: StoreLogo.navbar(
              width: isLandscape ? 200 : 156,
              height: 40,
            ),
          );
        },
      ),
      actions: [
        IconButton(
          onPressed: onSearchTap,
          icon: const Icon(Icons.search, size: 24, color: AppColors.primary),
          tooltip: 'Search',
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(
            Icons.notifications_outlined,
            size: 24,
            color: AppColors.primary,
          ),
          tooltip: 'Notifications',
        ),
        const SizedBox(width: 4),
      ],
    );
  }
}
