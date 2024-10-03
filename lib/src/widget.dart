import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class ColorPreview extends StatefulWidget {
  const ColorPreview({
    super.key,
    required this.onColorChanged,
    this.initialColor = Colors.white,
  });

  final Color initialColor;
  final Widget Function(Color color) onColorChanged;

  @override
  State<ColorPreview> createState() => _ColorPreviewState();
}

class _ColorPreviewState extends State<ColorPreview> {
  final OverlayPortalController _tooltipController = OverlayPortalController();
  late Widget currentWidget;
  late Color pickerColor;
  late Offset _moveBlockOffset;

  // initial Position
  late Offset _initialOffset;

  bool isShake = false;

  @override
  void initState() {
    super.initState();

    currentWidget = widget.onColorChanged(widget.initialColor);

    pickerColor = widget.initialColor;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initialOffset = Offset(0, MediaQuery.of(context).size.height / 2);

      _moveBlockOffset = _initialOffset;
    });
  }

  HSVColor get hexColor {
    return HSVColor.fromColor(pickerColor);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        currentWidget,
        Positioned(
          top: 5,
          right: 5,
          child: OverlayPortal(
            controller: _tooltipController,
            overlayChildBuilder: (context) {
              return Stack(
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _moveBlockOffset = _initialOffset;
                      });
                      _tooltipController.hide();
                    },
                    child: Container(
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width,
                      // 透明にする
                      color: Colors.black.withOpacity(.1),
                    ),
                  ),
                  Positioned(
                    top: _moveBlockOffset.dy,
                    left: _moveBlockOffset.dx,
                    child: LongPressDraggable(
                      feedback: Container(),
                      onDragStarted: () {
                        setState(() {
                          isShake = true;
                        });
                      },
                      onDragEnd: (_) {
                        setState(() {
                          isShake = false;
                        });
                      },
                      onDragUpdate: (details) {
                        setState(() {
                          _moveBlockOffset = Offset(
                            _moveBlockOffset.dx + details.delta.dx,
                            _moveBlockOffset.dy + details.delta.dy,
                          );
                        });
                      },
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.3,
                        width: MediaQuery.of(context).size.height * 0.3,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              Container(
                                width:
                                    MediaQuery.of(context).size.height * 0.15,
                                height: 5,
                                decoration: const BoxDecoration(
                                    color: Colors.grey,
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(12.0))),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              ColorPicker(
                                colorPickerWidth:
                                    MediaQuery.of(context).size.height * .2,
                                pickerColor: pickerColor,
                                labelTypes: const [],
                                onColorChanged: (value) {
                                  setState(() {
                                    pickerColor = value;
                                    currentWidget =
                                        widget.onColorChanged(value);
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
            child: GestureDetector(
              onTap: () {
                _tooltipController.show();
              },
              child: ColorIndicator(
                hexColor,
                height: 30,
                width: 30,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ColorBourd extends StatelessWidget {
  const _ColorBourd({required this.pickerColor, required this.onColorChanged});

  final Color pickerColor;
  final Function(Color) onColorChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.3,
      width: MediaQuery.of(context).size.height * 0.3,
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: MediaQuery.of(context).size.height * 0.15,
              height: 5,
              decoration: const BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.all(Radius.circular(12.0))),
            ),
            const SizedBox(
              height: 10,
            ),
            ColorPicker(
              colorPickerWidth: MediaQuery.of(context).size.height * .2,
              pickerColor: pickerColor,
              labelTypes: const [],
              onColorChanged: onColorChanged,
            ),
          ],
        ),
      ),
    );
  }
}

// 揺れるアニメーション
class SwayAnimationWidget extends StatefulWidget {
  const SwayAnimationWidget({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  State<SwayAnimationWidget> createState() => _SwayAnimationWidgetState();
}

class _SwayAnimationWidgetState extends State<SwayAnimationWidget>
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
    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        return Transform.rotate(
          angle: math.sin(_controller.value * 15 * math.pi) / 60,
          child: child,
        );
      },
    );
  }
}
