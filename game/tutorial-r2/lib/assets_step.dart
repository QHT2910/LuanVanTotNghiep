import 'package:flutter_scene/scene.dart' as fs;
import 'package:vector_math/vector_math.dart' as vm;

const modelAsset = String.fromEnvironment('MODEL_ASSET');
const textureAsset = String.fromEnvironment('TEXTURE_ASSET');
const clipName = String.fromEnvironment('CLIP_NAME');

Future<void> addOptionalAssets(
  fs.Node world,
  fs.PhysicallyBasedMaterial ballMaterial,
) async {
  if (textureAsset.isNotEmpty) {
    ballMaterial.baseColorTexture = await fs.Texture2D.fromAsset(
      textureAsset,
      maxSize: 1024,
    );
  }

  if (modelAsset.isEmpty) return;

  final model = await fs.Node.fromGlbAsset(
    modelAsset,
    maxTextureSize: 1024,
  );

  model.position = vm.Vector3(-1.0, 0.0, 1.0);
  model.scale = vm.Vector3(1.0, 1.0, 1.0);
  world.add(model);

  final animations = model.parsedAnimations;
  if (animations.isEmpty) {
    if (clipName.isNotEmpty) {
      throw StateError(
        'Có yêu cầu clip nhưng GLB không chứa animation.',
      );
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
    ..playbackTimeScale = 1.0;

  clip.play();
}

