import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_scene/scene.dart' as fs;
import 'package:vector_math/vector_math.dart' as v;

import '../src/presentation/human_actor.dart';
import 'hand_cpu.dart' show fixtures;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MaterialApp(home: Golden()));
}

class Golden extends StatefulWidget {
  const Golden({super.key});
  @override
  State<Golden> createState() => _Golden();
}

class _Golden extends State<Golden> {
  String status = 'collecting public Scene TRS';
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      collect();
    });
  }

  Future<void> collect() async {
    fs.Scene? scene;
    HumanActor? actor;
    try {
      debugPrint('STAGE3_BEGIN');
      // Numerical public TRS collector does not render or await shader readiness.
      debugPrint('STAGE3_IMPORT_BEGIN');
      actor = await HumanActor.load(alive: () => mounted, log: (_) {});
      if (actor == null) return;
      debugPrint('STAGE3_ACTOR_READY');
      scene = fs.Scene();
      scene.add(actor.node);
      List<List<double>> trs(fs.Node n) => [
        n.position.storage.toList(),
        n.rotation.storage.toList(),
        n.scale.storage.toList(),
      ];
      final bind = {
        for (final n in HumanActor.walk(actor.model))
          if (n != actor.model) n.name: trs(n),
      };
      final rows = <Map<String, dynamic>>[];
      for (final f in fixtures()) {
        if (f['begin'] == true) actor.layer.beginCharge();
        actor.node.position = v.Vector3.array(
          (f['feet'] as List<dynamic>).cast<double>(),
        );
        actor.node.rotation = v.Quaternion.axisAngle(
          v.Vector3(0, 1, 0),
          (f['yaw'] as double),
        );
        actor.layer.apply(
          base: (f['base'] as String),
          baseTime: (f['baseTime'] as double),
          shooting: (f['shooting'] as bool),
          shotTime: (f['shotTime'] as double),
          generation: (f['generation'] as int),
          accepted: (f['accepted'] as double),
          grounded: (f['grounded'] as bool),
          ready: (f['ready'] as bool),
          reset: (f['reset'] as bool),
        );
        scene.update(0);
        rows.add({
          'input': f,
          'alpha': actor.layer.alpha,
          'hand': actor.handWorld().storage.toList(),
          'publicTRS': {for (final n in actor.boundaryJoints) n.name: trs(n)},
          'importBoundary': actor.model.localTransform.storage.toList(),
        });
        actor.layer.recordSubmitted((f['tick'] as int));
        if (f['freeze'] == true &&
            !actor.layer.freezeSubmitted(
              (f['tick'] as int),
              (f['grounded'] as bool),
            ))
          throw StateError('freeze');
      }
      final file = File('${Directory.systemTemp.path}/stage3-golden.json');
      await file.writeAsString(
        jsonEncode({
          'schema': 1,
          'source': 'Flutter Scene public getters after Scene.update(0)',
          'bind': bind,
          'rows': rows,
        }),
      );
      setState(() => status = 'STAGE3 GOLDEN DONE ${rows.length} ${file.path}');
      debugPrint('STAGE3_GOLDEN_DONE ${rows.length} ${file.path}');
    } catch (e, st) {
      debugPrint('STAGE3_GOLDEN_ERROR $e $st');
      if (mounted) setState(() => status = 'ERROR $e');
    } finally {
      scene?.removeAll();
      actor?.dispose();
      scene?.dispose();
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [const CircularProgressIndicator(), Text(status)],
      ),
    ),
  );
}
