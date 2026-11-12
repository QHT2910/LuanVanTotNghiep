import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'src/presentation/practice_page.dart';
import 'src/presentation/offline_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  runApp(OfflineApp(practiceBuilder: (_) => const PracticePage()));
}
