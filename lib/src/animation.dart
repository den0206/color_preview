import 'dart:math' as math;

import 'package:flutter/material.dart';

class ShakeWidget extends StatefulWidget {
  const ShakeWidget({
    super.key,
    required this.child,
    required this.isDrag,
  });
  final Widget child;
  final bool isDrag;

  @override
  State<ShakeWidget> createState() => _ShakeWidgetState();
}

class _ShakeWidgetState extends State<ShakeWidget>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return !widget.isDrag
        ? widget.child
        : AnimatedBuilder(
            animation: _controller,
            child: widget.child,
            builder: (context, child) {
              return Transform.rotate(
                angle: math.sin(_controller.value * 15 * math.pi) / 80,
                child: child,
              );
            },
          );
  }
}

class FadeinWidget extends StatefulWidget {
  const FadeinWidget({super.key, required this.child, this.duration});

  final Widget child;
  final Duration? duration;

  @override
  State<FadeinWidget> createState() => _FadeinWidgetState();
}

class _FadeinWidgetState extends State<FadeinWidget>
    with TickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> animation;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: widget.duration ?? const Duration(milliseconds: 500),
    );

    animation = CurvedAnimation(parent: controller, curve: Curves.easeIn);
    controller.forward();

    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.stop();
      }
    });
  }

  @override
  void dispose() {
    animation.removeStatusListener((status) {});
    controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: animation,
      child: widget.child,
    );
  }
}
