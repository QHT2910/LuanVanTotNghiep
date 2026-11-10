import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'src/presentation/practice_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  runApp(const MaterialApp(home: PracticePage()));
}
