import 'dart:typed_data';

import 'package:flutter_scene/scene.dart' as fs;
import 'package:vector_math/vector_math.dart' as vm;

import '../../lesson_host.dart';
import '../e/main.dart' as e;

void main() => startLesson(buildLesson);

Future<Lesson> buildLesson(fs.Scene scene) async {
  final lesson = e.buildLesson(scene);
  try {
    lesson.material
      ..baseColorFactor = vm.Vector4(1, 1, 1, 1)
      ..baseColorTexture = fs.Texture2D.fromPixels(
        Uint8List.fromList([
          240, 120, 30, 255, 80, 30, 10, 255,
          80, 30, 10, 255, 240, 120, 30, 255,
        ]),
        2,
        2,
      );
    await loadAssets(lesson);
    return lesson;
  } catch (_) {
    lesson.close();
    rethrow;
  }
}

Future<void> loadAssets(Lesson lesson) async {
  const texturePath = String.fromEnvironment('TEXTURE_ASSET');
  const modelPath = String.fromEnvironment('MODEL_ASSET');
  const clipName = String.fromEnvironment('CLIP_NAME');

  if (clipName.isNotEmpty && modelPath.isEmpty) {
    throw StateError('CLIP_NAME cần MODEL_ASSET.');
  }
  if (texturePath.isNotEmpty) {
    lesson.material.baseColorTexture = await fs.Texture2D.fromAsset(
      texturePath,
      maxSize: 1024,
    );
  }
  if (modelPath.isEmpty) return;

  final model = await fs.Node.fromGlbAsset(
    modelPath,
    maxTextureSize: 1024,
  );
  model.position = vm.Vector3(-1, 0, 1);
  model.scale = vm.Vector3(0.01, 0.01, 0.01);
  lesson.root.add(model);

  final animations = model.parsedAnimations;
  if (animations.isEmpty) {
    if (clipName.isNotEmpty) {
      throw StateError('Model không chứa animation.');
    }
    return;
  }

  final animation = clipName.isEmpty
      ? animations.first
      : model.findAnimationByName(clipName);
  if (animation == null) {
    throw StateError('Không tìm thấy clip: $clipName');
  }

  final clip = model.createAnimationClip(animation)
    ..loop = true
    ..playbackTimeScale = 1;
  clip.play();
}
