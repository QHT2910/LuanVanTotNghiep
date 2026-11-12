import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:offline_practice/src/presentation/offline_app.dart';
import 'package:offline_practice/src/presentation/practice_navigation.dart';

void main() {
  testWidgets('Menu routes, disabled features, fresh entry and both exits', (
    tester,
  ) async {
    var created = 0, exits = 0;
    await tester.pumpWidget(
      OfflineApp(
        practiceBuilder: (_) {
          created++;
          return PracticeNavigation(
            onExit: () => exits++,
            child: const Scaffold(body: Text('Practice fixture')),
          );
        },
      ),
    );
    for (final key in ['menu_create_room', 'menu_join_room']) {
      expect(
        tester.widget<FilledButton>(find.byKey(ValueKey(key))).onPressed,
        isNull,
      );
    }
    expect(created, 0);
    for (var n = 0; n < 2; n++) {
      await tester.ensureVisible(find.byKey(const ValueKey('menu_practice')));
      await tester.tap(find.byKey(const ValueKey('menu_practice')));
      await tester.pumpAndSettle();
      expect(created, n + 1);
      if (n == 0) {
        await tester.tap(find.byKey(const ValueKey('return_menu')));
      } else {
        await tester.binding.handlePopRoute();
      }
      await tester.pumpAndSettle();
      expect(exits, n + 1);
      expect(find.byKey(const ValueKey('menu_practice')), findsOneWidget);
    }
  });

  testWidgets('Settings unavailable audio, back and responsive layout', (
    tester,
  ) async {
    addTearDown(() => tester.binding.setSurfaceSize(null));
    for (final size in [
      const Size(320, 640),
      const Size(724, 280),
      const Size(960, 540),
    ]) {
      await tester.binding.setSurfaceSize(size);
      await tester.pumpWidget(
        OfflineApp(
          key: ValueKey(size),
          practiceBuilder: (_) => const SizedBox(),
        ),
      );
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byKey(const ValueKey('menu_settings')));
      await tester.tap(find.byKey(const ValueKey('menu_settings')));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<Switch>(find.byKey(const ValueKey('settings_audio_switch')))
            .onChanged,
        isNull,
      );
      expect(
        tester
            .widget<Slider>(find.byKey(const ValueKey('settings_audio_slider')))
            .onChanged,
        isNull,
      );
      expect(tester.takeException(), isNull);
      await tester.ensureVisible(find.byKey(const ValueKey('settings_back')));
      await tester.tap(find.byKey(const ValueKey('settings_back')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('menu_practice')), findsOneWidget);
    }
  });
}
