import 'package:flutter/material.dart';
import 'package:modal_widget/modal_widget.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: ModalWidgetDemo(),
    );
  }
}

class ModalWidgetDemo extends StatefulWidget {
  const ModalWidgetDemo({super.key});

  @override
  State<ModalWidgetDemo> createState() => _ModalWidgetDemoState();
}

class _ModalWidgetDemoState extends State<ModalWidgetDemo> with ModalWidget{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: buildWithModalWidget(child: Center(
        child: ElevatedButton(
                onPressed: () => showModalWidgetWhile(
                  () async => await Future.delayed(
                    const Duration(seconds: 3)
                  )
                ),
                child: const Text("show overlay")
              ),
        ),
        modalWidget: const Center(child: Text("processing", style: TextStyle(fontSize: 50),))
      ),
    );
  }
}
