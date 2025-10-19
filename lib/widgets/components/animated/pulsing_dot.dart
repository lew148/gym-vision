import 'package:flutter/material.dart';

class PulsingDot extends StatefulWidget {
  final double size;
  final Color color;

  const PulsingDot({
    super.key,
    this.size = 12,
    this.color = Colors.green,
  });

  @override
  State<PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<PulsingDot> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 1));
    _scale = Tween<double>(begin: 0.9, end: 3).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _opacity = Tween<double>(begin: 0.5, end: 0.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    startPulsing();
  }

  Future<void> startPulsing() async {
    while (mounted) {
      _controller.reset();
      await _controller.forward();
      await Future.delayed(const Duration(seconds: 1)); // second between pulses
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget getCircle({bool halfScale = false}) => Container(
          width: halfScale ? widget.size / 2 : widget.size,
          height: halfScale ? widget.size / 2 : widget.size,
          decoration: BoxDecoration(shape: BoxShape.circle, color: widget.color),
        );

    return Stack(
      alignment: Alignment.center,
      children: [
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: _scale.value,
              child: Opacity(opacity: _opacity.value, child: getCircle()),
            );
          },
        ),
        getCircle(halfScale: true),
      ],
    );
  }
}
