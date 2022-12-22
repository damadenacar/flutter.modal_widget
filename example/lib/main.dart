import 'package:flutter/material.dart';
import 'package:overlay_widget/overlay_widget.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: OverlayWidgetDemo(),
    );
  }
}

class OverlayWidgetDemo extends StatefulWidget {
  const OverlayWidgetDemo({super.key});

  @override
  State<OverlayWidgetDemo> createState() => _OverlayWidgetDemoState();
}

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
