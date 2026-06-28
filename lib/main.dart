import 'package:flutter/material.dart';
import 'package:my_first_app/core/app/app_controller.dart';
import 'package:my_first_app/core/app/catalog_store.dart';
import 'package:my_first_app/core/theme/app_theme.dart';
import 'package:my_first_app/features/shell/main_shell.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  CatalogStore.instance.loadHome();
  AppController.instance.restoreSession();
  runApp(const WowKidzApp());
}

class WowKidzApp extends StatelessWidget {
  const WowKidzApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppController.instance,
      builder: (context, _) {
        return MaterialApp(
          title: 'WowKidz',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          navigatorKey: AppController.instance.navigatorKey,
          home: const MainShell(),
        );
      },
    );
  }
}
