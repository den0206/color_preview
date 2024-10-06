<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/tools/pub/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/to/develop-packages).
-->

# Color Preview

### Packages for easy confirmation of widget colors, Intuitive design.


<img src="gif/color_preview.gif" alt="demo" width="300" />


## Features
- Real-time color adjustment for design
- Orientation support
- DarkMode support

Recommendation: Do not include this package in production distributions due to the possibility of unexpected behavior.

## Installation
```yaml
dependencies:
  color_preview: latest
```

You can install packages from the command line:

```bash
$ flutter pub get
```

## Usage

- Wrap Target Widget.

``` dart
import 'package:color_preview/color_preview.dart';
...
// Wrap Widget
ColorPreview(
  // initial Color
  initialColor: Colors.red,
  onTargetWidget: (preview) {
    // preview is Picked Color
     return Container(
      height: 100,
      width: 100,
      decoration: BoxDecoration(
        // Specify a color for the property
        color: preview,
      ),
    );
  },
),
```

#### arguments

| name           | required          | Default |mean | 
| :---           |:--- |:---         | :--- |
|`onTargetWidget`| ⚪︎  |              |Set the target widget|
|`initialColor`  | ⚪︎  | Colors.white |Initial color value |
|`isEnable`      |     |true        |Enable package feature |
|`buttonOffset`  |     |             | Offset of the button to display Elements |



- At that time a color selectable button will be overlaid on the widget.
  - Default position is shown in the upper right.
<img width="203" alt="target button" src="https://github.com/user-attachments/assets/49c9c125-81c8-4eff-9457-f919652afa6f">

- Tap to display the **Color Picker** & **Color Label** on the screen.
  - These elements can be placed anywhere on the screen by **DragAndDrop**(Long Tap).

- **Picked Color!**
- The color value is copied to the clipboard by Long Tap on the Color Label.
<img width="348" alt="qYm5gnjwIQnX7KU1728176819_1728176969 (1)" src="https://github.com/user-attachments/assets/d82131fa-ab8a-4d8d-8a47-c0c384c48599">


##  Bugs/Requests

If you encounter any problems feel free to open an issue. If you feel the library is
missing a feature, please raise a ticket on Github and I'll look into it.
Pull request are also welcome.

## Notes
- This package uses the wonderful ColorPicker [flutter_colorpicker](https://pub.dev/packages/flutter_colorpicker).
   - Thanks to the Developers.
