import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:my_first_app/core/app/catalog_store.dart';
import 'package:my_first_app/core/theme/app_colors.dart';
import 'package:my_first_app/features/shell/main_shell.dart';

/// Shows store logo + loading indicator, then opens the main app.
class AppBootstrap extends StatefulWidget {
  const AppBootstrap({super.key});

  @override
  State<AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends State<AppBootstrap> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      CatalogStore.instance.bootstrap();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: CatalogStore.instance,
      builder: (context, _) {
        final catalog = CatalogStore.instance;

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 450),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          child: catalog.bootstrapComplete
              ? const MainShell(key: ValueKey('main_shell'))
              : const AppPreloaderView(key: ValueKey('preloader')),
        );
      },
    );
  }
}

/// Splash — store logo only (no face/character preloader).
class AppPreloaderView extends StatelessWidget {
  const AppPreloaderView({super.key});

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.orientationOf(context) == Orientation.landscape;
    final logoWidth = isLandscape ? 220.0 : 200.0;
    final logoHeight = isLandscape ? 56.0 : 52.0;

    return Scaffold(
      backgroundColor: Colors.white,
      body: ListenableBuilder(
        listenable: CatalogStore.instance,
        builder: (context, _) {
          final catalog = CatalogStore.instance;
          final logoUrl = catalog.logoUrl;
          final titleStyle = Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w800,
              );

          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (logoUrl != null && logoUrl.isNotEmpty)
                    SizedBox(
                      width: logoWidth,
                      height: logoHeight,
                      child: CachedNetworkImage(
                        imageUrl: logoUrl,
                        fit: BoxFit.contain,
                        placeholder: (_, _) => const SizedBox.shrink(),
                        errorWidget: (_, _, _) => Text(
                          catalog.appName,
                          textAlign: TextAlign.center,
                          style: titleStyle,
                        ),
                      ),
                    )
                  else
                    Text(
                      catalog.appName,
                      textAlign: TextAlign.center,
                      style: titleStyle,
                    ),
                  const SizedBox(height: 36),
                  const SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
