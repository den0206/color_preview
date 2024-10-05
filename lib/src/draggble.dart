import 'package:color_preview/src/animation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

final class ColorBoard extends StatefulWidget {
  const ColorBoard({super.key, required this.pickerColor, this.onColorChanged});

  final Color pickerColor;

  final Function(Color)? onColorChanged;

  @override
  State<ColorBoard> createState() => _ColorBoardState();
}

class _ColorBoardState extends State<ColorBoard> {
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

  @override
  Widget build(BuildContext context) {
    return _CommonDraggbleWidget(
      initialOffset: _initialOffset,
      size: _moveBlockSize,
      child: Container(
        height: _moveBlockSize.height,
        width: _moveBlockSize.width,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: _boxDecoration(context),
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
                      ? _screenSize.height * .23
                      : _screenSize.width * .23,
                  pickerColor: widget.pickerColor,
                  portraitOnly: true,
                  labelTypes: const [],
                  onColorChanged: widget.onColorChanged ?? (_) {}),
            ],
          ),
        ),
      ),
    );
  }
}

final class ColorLabelText extends StatefulWidget {
  const ColorLabelText({super.key, required this.pickerColor});

  final Color pickerColor;

  @override
  State<ColorLabelText> createState() => ColorLabelTextState();
}

class ColorLabelTextState extends State<ColorLabelText> {
  Size get _screenSize {
    return MediaQuery.of(context).size;
  }

  Size get _containerSize => const Size(210, 80);

  // initial Position
  Offset get _initialOffset {
    return Offset(_screenSize.width - _containerSize.width - 20,
        MediaQuery.of(context).size.height / 4);
  }

  Future<void> _saveClipboard(String colorText) async {
    final data = ClipboardData(text: colorText);
    await Clipboard.setData(data);
  }

  String get colorValue {
    return "0x${widget.pickerColor.value.toRadixString(16).padLeft(8, '0')}";
  }

  Future<void> _showMessage(BuildContext context, String colorText) async {
    final snackBar = SnackBar(
      backgroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20)), // 角を丸くする
      behavior: SnackBarBehavior.floating,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      content: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, // コンテンツを左右に配置
        children: [
          RichText(
            text: TextSpan(
              text: 'Color($colorText) ',
              style: DefaultTextStyle.of(context).style.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Color(int.parse(colorValue))),
              children: <TextSpan>[
                TextSpan(
                  text: "Copied !",
                  style: TextStyle(color: Theme.of(context).canvasColor),
                )
              ],
            ),
          ),
          Icon(
            Icons.check,
            color: Theme.of(context).colorScheme.inversePrimary,
          ), // アイコンを追加
        ],
      ),
      duration: const Duration(seconds: 3), // 表示時間を変更
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return _CommonDraggbleWidget(
      initialOffset: _initialOffset,
      size: _containerSize,
      child: Container(
        width: _containerSize.width,
        height: _containerSize.height,
        padding: const EdgeInsets.all(10),
        decoration: _boxDecoration(context),
        child: Column(
          children: [
            _Notch(),
            GestureDetector(
              onLongPress: () async {
                await _saveClipboard("Color($colorValue)");

                if (context.mounted) {
                  // show SnackBar
                  _showMessage(
                      context, widget.pickerColor.value.toRadixString(16));
                }
              },
              child: FittedBox(
                fit: BoxFit.fitWidth,
                child: Text(
                  colorValue,
                  style: Theme.of(context).textTheme.displaySmall!.copyWith(
                        decoration: TextDecoration.underline,
                        // color: Color(int.parse(colorValue)),
                      ),
                  textScaler: TextScaler.noScaling,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

BoxDecoration _boxDecoration(BuildContext context) {
  return BoxDecoration(
    color: Theme.of(context).colorScheme.surface,
    borderRadius: BorderRadius.circular(10),
    border: Border.all(
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    ),
  );
}

class _CommonDraggbleWidget extends StatefulWidget {
  const _CommonDraggbleWidget({
    required this.child,
    required this.size,
    required this.initialOffset,
  });

  final Widget child;
  final Size size;
  final Offset initialOffset;

  @override
  State<_CommonDraggbleWidget> createState() => _CommonDraggbleWidgetState();
}

class _CommonDraggbleWidgetState extends State<_CommonDraggbleWidget>
    with WidgetsBindingObserver {
  Offset _moveBlockOffset = Offset.zero;
  Orientation? _lastOrientation;
  bool isDrag = false;
  Size get _screenSize {
    return MediaQuery.of(context).size;
  }

  void clampMoveBlockOffset() {
    double clampedX =
        _moveBlockOffset.dx.clamp(0, _screenSize.width - widget.size.width);
    double clampedY =
        _moveBlockOffset.dy.clamp(0, _screenSize.height - widget.size.height);
    _moveBlockOffset = Offset(clampedX, clampedY);
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _moveBlockOffset = widget.initialOffset;
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
          _moveBlockOffset = widget.initialOffset;
        });
      });

      _lastOrientation = newOrientation;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
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
        child: FadeinWidget(
          child: ShakeWidget(
            isDrag: isDrag,
            child: widget.child,
          ),
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
