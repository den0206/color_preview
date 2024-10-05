import 'package:color_preview/src/draggble.dart';
import 'package:flutter/material.dart';
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

class _ColorPreviewState extends State<ColorPreview> {
  final OverlayPortalController _tooltipController = OverlayPortalController();
  late Widget currentWidget;
  late Color pickerColor;

  @override
  void initState() {
    super.initState();

    pickerColor = widget.initialColor;

    currentWidget = widget.onTargetWidget(pickerColor);
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
            child: GestureDetector(
              onTap: () {
                _tooltipController.show();
              },
              child: _RepaintIndicator(
                HSVColor.fromColor(pickerColor),
                height: 30,
                width: 30,
              ),
            ),
            overlayChildBuilder: (context) {
              return Stack(
                children: [
                  GestureDetector(
                    onTap: () {
                      _tooltipController.hide();
                    },
                    child: Container(
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width,
                      // 透明にする
                      color: Colors.transparent,
                    ),
                  ),
                  ColorBoard(
                    pickerColor: pickerColor,
                    onColorChanged: (value) {
                      setState(
                        () {
                          pickerColor = value;
                          currentWidget = widget.onTargetWidget(value);
                        },
                      );
                    },
                  ),
                  ColorLabelText(pickerColor: pickerColor),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class _RepaintIndicator extends StatelessWidget {
  const _RepaintIndicator(
    this.hsvColor, {
    required this.width,
    required this.height,
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
