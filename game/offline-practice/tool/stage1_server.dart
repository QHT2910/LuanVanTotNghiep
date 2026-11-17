import 'dart:io';

import '../lib/src/network/stage1_server.dart';

Future<void> main() async {
  final server = Stage1Server();
  await server.start(port: 8091);
  stdout.writeln('Local diagnostic room: ${server.uri}');
  // Ctrl+C terminates this foreground diagnostic, never a persistent service.
  await ProcessSignal.sigint.watch().first;
  await server.close();
}
