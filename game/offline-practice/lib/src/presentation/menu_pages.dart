import 'package:flutter/material.dart';

const _navy = Color(0xff1b334d);
const _cyan = Color(0xff97dcf4);
const _orange = Color(0xffff850e);

class OfflineMenuPage extends StatefulWidget {
  const OfflineMenuPage({super.key});
  @override
  State<OfflineMenuPage> createState() => _OfflineMenuPageState();
}

class _OfflineMenuPageState extends State<OfflineMenuPage> {
  bool _opening = false;
  Future<void> _open(String route) async {
    if (_opening) return;
    setState(() => _opening = true);
    try {
      await Navigator.of(context).pushNamed<void>(route);
    } finally {
      if (mounted) setState(() => _opening = false);
    }
  }

  Widget _button(
    String id,
    String title,
    Color color,
    VoidCallback? action,
  ) => SizedBox(
    width: double.infinity,
    child: FilledButton(
      key: ValueKey(id),
      onPressed: action,
      style: FilledButton.styleFrom(
        backgroundColor: color,
        foregroundColor: color == _navy ? Colors.white : _navy,
        disabledBackgroundColor: color.withAlpha(155),
        disabledForegroundColor: _navy.withAlpha(160),
        minimumSize: const Size(0, 44),
        textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      child: Text(title),
    ),
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    body: MenuViewport(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 430),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'BÓNG RỔ',
              style: TextStyle(
                fontSize: 38,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                shadows: [Shadow(color: _navy, offset: Offset(2, 3))],
              ),
            ),
            const Text(
              'Tập luyện offline',
              style: TextStyle(color: _navy, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            _button('menu_create_room', 'Tạo phòng', _orange, null),
            const SizedBox(height: 6),
            _button('menu_join_room', 'Vào phòng', _navy, null),
            const SizedBox(height: 6),
            _button(
              'menu_practice',
              'Tập luyện',
              _cyan,
              _opening ? null : () => _open('/practice'),
            ),
            const SizedBox(height: 6),
            _button(
              'menu_settings',
              'Cài đặt',
              _navy,
              _opening ? null : () => _open('/settings'),
            ),
            const SizedBox(height: 8),
            const Text(
              'Chơi mạng chưa khả dụng: chưa có backend phòng.',
              textAlign: TextAlign.center,
              style: TextStyle(color: _navy, fontSize: 12),
            ),
          ],
        ),
      ),
    ),
  );
}

class OfflineSettingsPage extends StatelessWidget {
  const OfflineSettingsPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    body: MenuViewport(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: _navy,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'CÀI ĐẶT ÂM THANH',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _cyan,
                    fontWeight: FontWeight.w900,
                    fontSize: 23,
                  ),
                ),
                const Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Âm thanh',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    Switch(
                      key: ValueKey('settings_audio_switch'),
                      value: false,
                      onChanged: null,
                    ),
                  ],
                ),
                const Row(
                  children: [
                    Text('Âm lượng', style: TextStyle(color: Colors.white)),
                    Expanded(
                      child: Slider(
                        key: ValueKey('settings_audio_slider'),
                        value: 0,
                        onChanged: null,
                      ),
                    ),
                  ],
                ),
                const Text(
                  'Demo chưa tích hợp âm thanh. Công tắc và âm lượng chưa khả dụng.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 14),
                FilledButton(
                  key: const ValueKey('settings_back'),
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Quay lại'),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class MenuViewport extends StatelessWidget {
  const MenuViewport({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => Stack(
    fit: StackFit.expand,
    children: [
      const IgnorePointer(child: CustomPaint(painter: _CourtBackdrop())),
      SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Center(
                child: Padding(padding: const EdgeInsets.all(16), child: child),
              ),
            ),
          ),
        ),
      ),
    ],
  );
}

// Decorative court; gameplay remains a separate Scene route.
class _CourtBackdrop extends CustomPainter {
  const _CourtBackdrop();
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height, p = Paint();
    p.shader = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xff55c5fa), Color(0xffb7ebff)],
    ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, p);
    p.shader = null;
    p.color = Colors.white.withAlpha(200);
    for (final x in [0.12, 0.32, 0.85]) {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(w * x, h * 0.16),
          width: w * 0.15,
          height: h * 0.08,
        ),
        p,
      );
    }
    p.color = const Color(0xff559d83);
    canvas.drawRect(Rect.fromLTRB(0, h * 0.52, w, h * 0.68), p);
    p.color = const Color(0xffed9675);
    canvas.drawRect(Rect.fromLTRB(0, h * 0.68, w, h), p);
    p
      ..color = Colors.white
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(0, h * 0.69), Offset(w, h * 0.69), p);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.5, h * 0.96),
        width: w * 0.65,
        height: h * 0.3,
      ),
      p,
    );
    final board = Rect.fromLTWH(w * 0.85, h * 0.22, w * 0.1, h * 0.17);
    p
      ..style = PaintingStyle.fill
      ..color = Colors.white;
    canvas.drawRect(board, p);
    p
      ..style = PaintingStyle.stroke
      ..color = _orange;
    canvas.drawRect(board, p);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(board.center.dx, board.bottom + h * 0.025),
        width: w * 0.055,
        height: h * 0.035,
      ),
      p,
    );
    p.color = _navy;
    canvas.drawLine(
      Offset(board.right, board.bottom),
      Offset(board.right, h * 0.68),
      p,
    );
  }

  @override
  bool shouldRepaint(covariant _CourtBackdrop oldDelegate) => false;
}
