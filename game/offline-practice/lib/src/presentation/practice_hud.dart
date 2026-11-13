import 'package:flutter/material.dart';

const practiceNavy = Color(0xff1d344e);
const practiceOrange = Color(0xffff861c);
const practiceActionSize = Size(64, 58);
const practiceShootSize = Size(100, 100);
typedef PracticeHudData = ({
  int score,
  int round,
  int points,
  double charge,
  double target,
  String dash,
});

class OfflinePracticeHud extends StatelessWidget {
  const OfflinePracticeHud({
    super.key,
    required this.data,
    required this.joystick,
    required this.jump,
    required this.dash,
    required this.shoot,
    required this.reset,
  });
  final ValueNotifier<PracticeHudData> data;
  final Widget joystick, jump, dash, shoot, reset;

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Padding(
      padding: const EdgeInsets.all(8),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            top: 0,
            left: 96,
            right: 112,
            child: Center(
              child: ValueListenableBuilder<PracticeHudData>(
                valueListenable: data,
                builder: (context, v, child) => Semantics(
                  label: 'practice_hud',
                  value:
                      'Điểm tập ${v.score}, lượt ${v.round}, cú ném ${v.points} điểm, offline',
                  excludeSemantics: true,
                  child: Container(
                    key: const ValueKey('offline_score'),
                    width: 337,
                    height: 28,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: practiceNavy,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'OFFLINE  ${v.score} điểm  ·  Lượt ${v.round}  ·  ${v.points}đ',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(top: 0, left: 0, child: reset),
          Positioned(bottom: 0, left: 0, child: joystick),
          Positioned(
            bottom: 0,
            right: 0,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                jump,
                const SizedBox(width: 8),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: practiceActionSize.width,
                      height: 20,
                      child: ValueListenableBuilder<PracticeHudData>(
                        valueListenable: data,
                        builder: (context, v, child) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 2,
                          ),
                          color: practiceNavy,
                          child: Semantics(
                            label: 'dash_status',
                            value: v.dash,
                            excludeSemantics: true,
                            child: Text(
                              switch (v.dash) {
                                'ready' => 'Sẵn',
                                'dashing' => 'Đang lướt',
                                'cooldown' => 'Hồi chiêu',
                                _ => v.dash,
                              },
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    dash,
                  ],
                ),
                const SizedBox(width: 8),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 100,
                      child: ValueListenableBuilder<PracticeHudData>(
                        valueListenable: data,
                        builder: (context, v, child) => Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              color: practiceNavy,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 2,
                              ),
                              child: Text(
                                'Mục tiêu ${(v.target * 100).round()}%',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                            const SizedBox(height: 3),
                            SizedBox(
                              height: 12,
                              child: LayoutBuilder(
                                builder: (context, bounds) => Stack(
                                  children: [
                                    Positioned.fill(
                                      child: LinearProgressIndicator(
                                        key: const ValueKey('shot_charge'),
                                        value: v.charge
                                            .clamp(0.0, 1.0)
                                            .toDouble(),
                                        color: practiceOrange,
                                        backgroundColor: practiceNavy,
                                      ),
                                    ),
                                    Positioned(
                                      left: (bounds.maxWidth * v.target - 1)
                                          .clamp(0.0, bounds.maxWidth - 2)
                                          .toDouble(),
                                      top: 0,
                                      bottom: 0,
                                      width: 2,
                                      child: const ColoredBox(
                                        key: ValueKey('charge_target'),
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    // Keep input outside listenable builders so held pointers survive.
                    shoot,
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
