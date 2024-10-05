import 'package:color_preview/color_preview.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  final title = 'Color Preview Demo';

  @override
  Widget build(BuildContext context) {
    ModeStuff modeNotifier = ModeStuff.instance;

    return ValueListenableBuilder(
      valueListenable: modeNotifier.theme,
      builder: (context, ThemeMode mode, _) {
        return MaterialApp(
          title: title,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          darkTheme: ThemeData.dark(),
          themeMode: mode,
          home: MyHomePage(title: title),
        );
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _space = 20.0;
  final _boxOneColor = Colors.red;
  final _boxTwoColor = Colors.green;
  final _boxThreeColor = Colors.blue;

  bool get isPortrait =>
      MediaQuery.of(context).orientation == Orientation.portrait;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          Switch.adaptive(
            activeColor: Theme.of(context).colorScheme.primary,
            value: ModeStuff.instance.theme.value == ThemeMode.dark,
            onChanged: (value) {
              ModeStuff.instance
                  .updateValue(value ? ThemeMode.dark : ThemeMode.light);
            },
          )
        ],
      ),
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: SingleChildScrollView(
          scrollDirection: isPortrait ? Axis.vertical : Axis.horizontal,
          child: Flex(
            direction: isPortrait ? Axis.vertical : Axis.horizontal,
            children: [
              SizedBox(
                height: _space,
                width: _space,
              ),
              ColorPreview(
                initialColor: _boxOneColor,
                onTargetWidget: (preview) {
                  return _SampleBox(color: preview);
                },
              ),
              SizedBox(
                height: _space,
                width: _space,
              ),
              ColorPreview(
                initialColor: _boxTwoColor,
                onTargetWidget: (preview) {
                  return _SampleBox(color: preview);
                },
              ),
              SizedBox(
                height: _space,
                width: _space,
              ),
              ColorPreview(
                initialColor: _boxThreeColor,
                onTargetWidget: (preview) {
                  return _SampleBox(color: preview);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SampleBox extends StatelessWidget {
  const _SampleBox({required this.color});

  final Color color;
  final double widgetSize = 200;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widgetSize,
      width: widgetSize,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }
}

class ModeStuff {
  static ModeStuff? _instance;

  static ModeStuff get instance {
    _instance ??= ModeStuff._init();

    return _instance!;
  }

  ModeStuff._init();

  ValueNotifier<ThemeMode> theme = ValueNotifier<ThemeMode>(ThemeMode.light);

  void updateValue(ThemeMode mode) {
    theme.value = mode;
  }
}
