import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

final class ColorPreview extends StatefulWidget {
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
  late Size _moveRange;
  late Size _moveBlockSize;

  // initial Position
  late Offset _initialOffset;

  bool isDrag = false;

  void clampMoveBlockOffset() {
    double clampedX =
        _moveBlockOffset.dx.clamp(0, _moveRange.width - _moveBlockSize.width);
    double clampedY =
        _moveBlockOffset.dy.clamp(0, _moveRange.height - _moveBlockSize.height);
    _moveBlockOffset = Offset(clampedX, clampedY);
  }

  @override
  void initState() {
    super.initState();

    pickerColor = widget.initialColor;

    currentWidget = widget.onColorChanged(pickerColor);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final screenSize = MediaQuery.of(context).size;

      _moveRange = screenSize;
      _moveBlockSize = Size(screenSize.height * 0.3, screenSize.height * 0.4);
      _initialOffset = Offset(0, screenSize.height / 2);

      _moveBlockOffset = _initialOffset;
    });
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
                    top: MediaQuery.of(context).size.height / 4,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: Theme.of(context).colorScheme.surfaceBright),
                      ),
                      child: Text(
                        pickerColor.value.toRadixString(16),
                        style: Theme.of(context).textTheme.displayMedium,
                      ),
                    ),
                  ),
                  Positioned(
                      top: _moveBlockOffset.dy,
                      left: _moveBlockOffset.dx,
                      child: LongPressDraggable(
                        feedback: Container(),
                        onDragStarted: () {
                          setState(() {
                            isDrag = true;
                          });
                        },
                        onDragEnd: (_) {
                          setState(() {
                            isDrag = false;
                          });
                        },
                        onDragUpdate: (details) {
                          setState(() {
                            _moveBlockOffset = Offset(
                              _moveBlockOffset.dx + details.delta.dx,
                              _moveBlockOffset.dy + details.delta.dy,
                            );
                            clampMoveBlockOffset();
                          });
                        },
                        child: isDrag
                            ? _ShakeWidget(
                                child: _ColorBoard(
                                  size: _moveBlockSize,
                                  pickerColor: pickerColor,
                                ),
                              )
                            : _ColorBoard(
                                size: _moveBlockSize,
                                pickerColor: pickerColor,
                                onColorChanged: (value) {
                                  setState(() {
                                    pickerColor = value;
                                    currentWidget =
                                        widget.onColorChanged(value);
                                  });
                                },
                              ),
                      )),
                ],
              );
            },
            child: GestureDetector(
                onTap: () {
                  _tooltipController.show();
                },
                child: _RepaintIndicator(
                  HSVColor.fromColor(pickerColor),
                  height: 30,
                  width: 30,
                )),
          ),
        ),
      ],
    );
  }
}

class _RepaintIndicator extends StatelessWidget {
  const _RepaintIndicator(
    this.hsvColor, {
    this.width = 50.0,
    this.height = 50.0,
  });

  final HSVColor hsvColor;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(1000.0)),
        border: Border.all(color: const Color(0xffdddddd)),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(1000.0)),
        child: CustomPaint(painter: _RepaintIndicatorPaint(hsvColor.toColor())),
      ),
    );
  }
}

class _RepaintIndicatorPaint extends IndicatorPainter {
  _RepaintIndicatorPaint(super.color);

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class _ColorBoard extends StatelessWidget {
  const _ColorBoard(
      {required this.size, required this.pickerColor, this.onColorChanged});

  final Size size;
  final Color pickerColor;

  final Function(Color)? onColorChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size.height,
      width: size.width,
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
                onColorChanged: onColorChanged ?? (_) {}),
          ],
        ),
      ),
    );
  }
}

// 揺れるアニメーション
class _ShakeWidget extends StatefulWidget {
  const _ShakeWidget({
    required this.child,
  });

  final Widget child;

  @override
  State<_ShakeWidget> createState() => _ShakeWidgetState();
}

class _ShakeWidgetState extends State<_ShakeWidget>
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
          angle: math.sin(_controller.value * 15 * math.pi) / 80,
          child: child,
        );
      },
    );
  }
}
