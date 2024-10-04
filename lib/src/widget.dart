import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

final class ColorPreview extends StatefulWidget {
  const ColorPreview({
    super.key,
    required this.onTargetWidget,
    this.initialColor = Colors.white,
  });

  final Color initialColor;
  final Widget Function(Color color) onTargetWidget;

  @override
  State<ColorPreview> createState() => _ColorPreviewState();
}

class _ColorPreviewState extends State<ColorPreview>
    with WidgetsBindingObserver {
  final OverlayPortalController _tooltipController = OverlayPortalController();
  late Widget currentWidget;
  late Color pickerColor;
  Orientation? _lastOrientation;

  late Offset _moveBlockOffset;

  bool isDrag = false;

  bool get isPortrait {
    return MediaQuery.of(context).orientation == Orientation.portrait;
  }

  Size get _screenSize {
    return MediaQuery.of(context).size;
  }

  // initial Position
  Offset get _initialOffset {
    return isPortrait
        ? Offset(10, _screenSize.height / 2)
        : Offset(10, _screenSize.height / 6);
  }

  Size get _moveBlockSize {
    return isPortrait
        ? Size(_screenSize.height * 0.3, _screenSize.height * 0.4)
        : Size(_screenSize.width * 0.3, _screenSize.width * 0.35);
  }

  void clampMoveBlockOffset() {
    double clampedX =
        _moveBlockOffset.dx.clamp(0, _screenSize.width - _moveBlockSize.width);
    double clampedY = _moveBlockOffset.dy
        .clamp(0, _screenSize.height - _moveBlockSize.height);
    _moveBlockOffset = Offset(clampedX, clampedY);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    pickerColor = widget.initialColor;

    currentWidget = widget.onTargetWidget(pickerColor);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _moveBlockOffset = _initialOffset;
    });
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeMetrics() {
    final newOrientation = MediaQuery.of(context).orientation;
    if (newOrientation != _lastOrientation) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _moveBlockOffset = _initialOffset;
        });
      });

      _lastOrientation = newOrientation;
    }
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
                  _ColorLabelText(pickerColor: pickerColor),
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
                          child: _ShakeWidget(
                            isDrag: isDrag,
                            child: _ColorBoard(
                              size: _moveBlockSize,
                              pickerColor: pickerColor,
                              onColorChanged: (value) {
                                setState(
                                  () {
                                    pickerColor = value;
                                    currentWidget =
                                        widget.onTargetWidget(value);
                                  },
                                );
                              },
                            ),
                          ))),
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
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
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
            _Notch(),
            const SizedBox(
              height: 10,
              width: 10,
            ),
            ColorPicker(
                colorPickerWidth: isPortrait
                    ? MediaQuery.of(context).size.height * .2
                    : MediaQuery.of(context).size.width * .2,
                pickerColor: pickerColor,
                portraitOnly: true,
                labelTypes: const [],
                onColorChanged: onColorChanged ?? (_) {}),
          ],
        ),
      ),
    );
  }
}

class _Notch extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.height * 0.15,
      height: 5,
      decoration: const BoxDecoration(
          color: Colors.grey,
          borderRadius: BorderRadius.all(Radius.circular(12.0))),
    );
  }
}

// 揺れるアニメーション
class _ShakeWidget extends StatefulWidget {
  const _ShakeWidget({
    required this.child,
    required this.isDrag,
  });
  final Widget child;
  final bool isDrag;

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

class _ColorLabelText extends StatefulWidget {
  const _ColorLabelText({required this.pickerColor});

  final Color pickerColor;

  @override
  State<_ColorLabelText> createState() => _ColorLabelTextState();
}

class _ColorLabelTextState extends State<_ColorLabelText>
    with WidgetsBindingObserver {
  Offset _textOffset = Offset.zero;
  Orientation? _lastOrientation;
  bool isDrag = false;

  Size get _screenSize {
    return MediaQuery.of(context).size;
  }

  Size get _containerSize => const Size(210, 80);

  // initial Position
  Offset get _initialOffset {
    return Offset(_screenSize.width - _containerSize.width - 20,
        MediaQuery.of(context).size.height / 4);
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _textOffset = _initialOffset;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeMetrics() {
    final newOrientation = MediaQuery.of(context).orientation;
    if (newOrientation != _lastOrientation) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _textOffset = _initialOffset;
        });
      });

      _lastOrientation = newOrientation;
    }
  }

  Future<void> _saveClipboard(String colorText) async {
    final data = ClipboardData(text: colorText);
    await Clipboard.setData(data);
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: _textOffset.dy,
      left: _textOffset.dx,
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
            _textOffset = Offset(
              _textOffset.dx + details.delta.dx,
              _textOffset.dy + details.delta.dy,
            );
          });
        },
        child: _ShakeWidget(
          isDrag: isDrag,
          child: Container(
            width: _containerSize.width,
            height: _containerSize.height,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Theme.of(context).colorScheme.surfaceBright,
              ),
            ),
            child: Column(
              children: [
                _Notch(),
                GestureDetector(
                  onLongPress: () async {
                    await _saveClipboard(
                        widget.pickerColor.value.toRadixString(16));

                    if (context.mounted) {
                      // show SnackBar
                      final snackBar = SnackBar(
                        backgroundColor:
                            Theme.of(context).primaryIconTheme.color,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        behavior: SnackBarBehavior.floating,
                        padding: const EdgeInsetsDirectional.symmetric(
                            horizontal: 16),
                        // margin: const EdgeInsetsDirectional.all(16),
                        content: Text(
                          "Copy Color!!",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                        duration: const Duration(seconds: 2),
                      );

                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    }
                  },
                  child: Text(
                    widget.pickerColor.value.toRadixString(16),
                    style: Theme.of(context)
                        .textTheme
                        .displayMedium!
                        .copyWith(decoration: TextDecoration.underline),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
