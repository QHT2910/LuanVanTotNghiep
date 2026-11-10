import 'dart:math' as math;

class PracticeConfig {
  const PracticeConfig({
    this.minX = -4,
    this.maxX = 4,
    this.minZ = -4,
    this.maxZ = 5,
    this.spawnX = 0,
    this.spawnZ = 3,
    this.hoopX = 0,
    this.hoopZ = -3,
    this.rimY = 3.05,
    this.rimInnerRadius = 0.45,
    this.rimTubeRadius = 0.035,
    this.ballRadius = 0.12,
    this.releaseY = 1.8,
    this.footRadius = 0.22,
    this.arcRadius = 5,
    this.moveSpeed = 2.5,
    this.chargeSeconds = 1.2,
    this.idealCharge = 0.6,
    this.missScale = 4,
    this.flightSeconds = 1.4,
    this.gravity = 9.81,
    this.step = 1 / 120,
    this.maxFrame = 0.1,
    this.resetDelay = 1,
    this.maxFlight = 4,
    this.lineTolerance = 1e-9,
    this.jumpSpeed = 5,
  });

  final double minX, maxX, minZ, maxZ, spawnX, spawnZ;
  final double hoopX, hoopZ, rimY, rimInnerRadius, rimTubeRadius;
  final double ballRadius, releaseY, footRadius, arcRadius, moveSpeed;
  final double chargeSeconds, idealCharge, missScale, flightSeconds;
  final double gravity, step, maxFrame, resetDelay, maxFlight;
  final double lineTolerance, jumpSpeed;

  double get jumpApex => jumpSpeed * jumpSpeed / (2 * gravity);
  double get jumpDuration => 2 * jumpSpeed / gravity;

  void validate() {
    final values = [
      minX,
      maxX,
      minZ,
      maxZ,
      spawnX,
      spawnZ,
      hoopX,
      hoopZ,
      rimY,
      rimInnerRadius,
      rimTubeRadius,
      ballRadius,
      releaseY,
      footRadius,
      arcRadius,
      moveSpeed,
      chargeSeconds,
      idealCharge,
      missScale,
      flightSeconds,
      gravity,
      step,
      maxFrame,
      resetDelay,
      maxFlight,
      lineTolerance,
      jumpSpeed,
    ];
    if (values.any((v) => !v.isFinite) ||
        minX >= maxX ||
        minZ >= maxZ ||
        footRadius <= 0 ||
        maxX - minX <= 2 * footRadius ||
        maxZ - minZ <= 2 * footRadius ||
        spawnX < minX + footRadius ||
        spawnX > maxX - footRadius ||
        spawnZ < minZ + footRadius ||
        spawnZ > maxZ - footRadius ||
        hoopX < minX ||
        hoopX > maxX ||
        hoopZ < minZ ||
        hoopZ > maxZ ||
        ballRadius <= 0 ||
        rimInnerRadius <= ballRadius ||
        rimTubeRadius <= 0 ||
        releaseY <= ballRadius ||
        rimY <= releaseY ||
        arcRadius <= 0 ||
        moveSpeed <= 0 ||
        chargeSeconds <= 0 ||
        idealCharge <= 0 ||
        idealCharge >= 1 ||
        missScale <= 0 ||
        gravity <= 0 ||
        flightSeconds <= 0 ||
        step <= 0 ||
        step > 0.05 ||
        maxFrame < step ||
        maxFrame > 0.25 ||
        resetDelay <= 0 ||
        lineTolerance < 0 ||
        jumpSpeed <= 0) {
      throw ArgumentError('Invalid experimental practice configuration');
    }

    final t = flightSeconds;
    final halfGT2 = 0.5 * gravity * t * t;
    final maximumOrigin = releaseY + jumpApex;
    final groundVy = (rimY - releaseY + halfGT2) / t;
    final highestOriginVy = (rimY - maximumOrigin + halfGT2) / t;
    final groundLanding =
        (groundVy +
            math.sqrt(
              groundVy * groundVy + 2 * gravity * (releaseY - ballRadius),
            )) /
        gravity;
    final derived = [
      jumpApex,
      jumpDuration,
      maximumOrigin,
      halfGT2,
      groundVy,
      highestOriginVy,
      groundLanding,
      gravity * t,
    ];
    // Upward launch for every reachable player height; the chosen time
    // must be on the descending branch, even for a ground release.
    // Higher release origins only make descent at this time stronger.
    if (derived.any((v) => !v.isFinite) ||
        highestOriginVy <= 0 ||
        groundVy - gravity * t >= 0 ||
        maxFlight <= t ||
        maxFlight <= groundLanding) {
      throw ArgumentError('Invalid jump/shot arc or flight horizon');
    }
  }
}
