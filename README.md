# Overlay Widget

Showing interactivity is important for apps, even while executing blocking tasks like logging in, reading from the internet, etc. During these periods it is convenient to block access to the interface and show a notice (e.g. "Reading Data") or a fancy widget like [Flutter Spinkit](https://pub.dev/packages/flutter_spinkit).

Although it is easy to show build and show the overlay depending on the state of a _StatefulWidget_, it is easier not to have to build it ;)

This package provides a mixin that eases the task of overlaying an arbitrary widget over another widget, to show activity during the execution of long tasks.

## Features

The basic features of this mixing, where used in a widget are:

1. Show a widget for a limited time (e.g. 2 seconds)
1. Show a widget during the execution of a function
1. Show a widget and later hide it programmatically

The effect is the one in the images:

![Overlay widget](https://github.com/damadenacar/flutter.modal_widget/img/overlay_widget_text.gif)
![Overlay widget](https://github.com/damadenacar/flutter.modal_widget/img/overlay_widget_spinkit.gif)

## Getting started

To start using this package, add it to your `pubspec.yaml` file:

```yaml
dependencies:
    overlay_widget:
```

Then get the dependencies (e.g. `flutter pub get`) and import them into your application:

```dart
import 'package:overlay_widget/overlay_widget.dart';
```

## Usage

You need to add the mixin to your `StatefulWidget`, and then use the function `buildWithOverlayWidget` in your `build` override:

```dart
class _OverlayWidgetDemoState extends State<OverlayWidgetDemo> with OverlayWidget{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: buildWithOverlayWidget(child: Center(
        child: ElevatedButton(
                onPressed: () => showOverlayWidgetWhile(
                  () async => await Future.delayed(
                    const Duration(seconds: 3)
                  )
                ),
                child: const Text("show overlay")
              ),
        ),
        overlayWidget: const Center(child: Text("processing", style: TextStyle(fontSize: 50),))
      ),
    );
  }
}
```

## Additional information

There are different mechanisms and options to control how and when to show the overlay: showing the widget until it is programmatically hidden (i.e. `showOverlayWidget` ... `hideOverlayWidget`), showing the widget while a function is being run, or showing the widget during a period.

The interface of the function to build the overlay is the next:

```dart
Widget buildWithOverlayWidget({ 
    required Widget child, 
    Widget? overlayWidget, 
    bool blurContent = false, 
    double opacity = 0.8, 
    VoidCallback? onHide 
})
```

The function somehow defines the default values for the process, but some of them may be overridden when showing the animation.

- __`child`:__ the content to show under the overlay.
- __`overlayWidget`:__ the widget that is being overlayed to the content while waiting.
- __`blurContent` (defaults to false):__ If set to `true`, the child widget will be blurred (to give the feeling of being non-interactive).
- __`opacity` (defaults to 0.8):__ If set to a value different than 1, the child widget will be set to semi-transparent by this factor.
- __`onHide`:__ Callback to call whenever the animation is hidden (whether auto-closed or closed using `hideOverlayWidget` function)

### Showing the overlay

There are multiple functions to show the overlay:

```dart
Future<bool> showOverlayWidget({bool force = false, VoidCallback? onHide}) async {
```

This is the basic function that shows the `overlayWidget`, and calls the function `onHide` when the animation is hidden. If `onHide` is not provided, it defaults to the value provided in the call to `buildWithOverlayWidget`.

If the animation was already being shown, the state of the widget will not change, and `onHide` will not be called. This happens unless the parameter `force` is set to `true`.

It is set as a `Future<bool>` to enable chaining function execution (e.g. using `then`). The result that receives the future refers to wether the animation has been shown or not (i.e. `true`) or it was already being shown (i.e. `false`).

```dart
void hideOverlayWidget([bool force = false]) {
```

This function hides the overlay and enables the usage of the child widget again. The function is intended to be called after `showOverlayWidget` is called, but it is advisable to use the _auto-close_ feature.

If the widget was already hidden, the state of the widget will not change, unless the parameter `force` is set to `true`.

```dart
Future<bool> showOverlayWidgetWhile(Function callback, {Duration? timeout, VoidCallback? onTimeout, VoidCallback? onHide})
```

This function shows the overlay widget during the execution of `callback`. It is possible to set a `timeout` for the execution. If the time for the execution exceeds that time, the execution of the `callback` is aborted, and the function `onTimeout` is called.

If `onHide` is not provided, it defaults to the value provided in the call to `buildWithOverlayWidget`.

The function returns a `Future<bool>` that is resolved after the callback is executed (or aborted). So it is possible to chain it with other functions using `await` or `then` procedures. This procedure is independent from the `onHide` callback, and so both `onHide` may be called and the chain to `then` may be executed.

The `bool` result is set to `true` if the widget has been shown and hidden. If the widget was already shown when calling `showOverlayWidgetWhile` the result of the _future_ will be set to `false`.

```dart
Future<bool> showOverlayWidgetDuring(Duration period, {VoidCallback? onHide}) {
```

This function shows the widget during the period `period`. If `onHide` is not provided, it defaults to the value provided in the call to `buildWithOverlayWidget`.

At the end, this is a shortcut for `return showOverlayWidgetWhile(() async => await Future.delayed(period), onHide: onHide)`.

