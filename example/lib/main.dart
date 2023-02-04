import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:device_manager/device_manager.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _deviceManagerPlugin = DeviceManager();

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      debugPrint("Starting DFU");
      _deviceManagerPlugin.startDFU(
        address: "C2:48:1A:45:2F:6E",
        filePath: "assets/app_update.bin",
        fileInAsset: true,
        estimatedSwapTime: 37000,
        mode: FirmwareUpgradeMode.testAndConfirm,
        uploadProgressDidChange: (bytesSent, totalImageSize) =>
            print("Upload progress did change: $bytesSent / $totalImageSize"),
        upgradeDidComplete: () => print("Upgrade completed"),
        upgradeDidFail: (state, error) =>
            print("Upgrade failed with state $state and error $error"),
        upgradeStateDidChange: (previousState, newState) =>
            print("State changed from $previousState to $newState"),
      );
    } on PlatformException {
      debugPrint("DFU failed");
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Row(children: [
          Center(
            child: Text('Running on: $_platformVersion\n'),
          ),
          TextButton(
              onPressed: (() async {}), child: const Text("This is a test"))
        ]),
      ),
    );
  }
}
