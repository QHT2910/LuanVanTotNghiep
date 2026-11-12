import 'package:flutter/material.dart';

import 'menu_pages.dart';

class OfflineApp extends StatelessWidget {
  const OfflineApp({super.key, required this.practiceBuilder});
  final WidgetBuilder practiceBuilder;

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Bóng rổ',
    home: const OfflineMenuPage(),
    onGenerateRoute: (settings) {
      final WidgetBuilder? builder = switch (settings.name) {
        '/practice' => practiceBuilder,
        '/settings' => (_) => const OfflineSettingsPage(),
        _ => null,
      };
      if (builder == null) return null;
      return PageRouteBuilder<void>(
        settings: settings,
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
        pageBuilder: (context, animation, secondaryAnimation) =>
            builder(context),
      );
    },
  );
}
