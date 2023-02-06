import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'device_manager_platform_interface.dart';
import 'device_manager.dart';

/// An implementation of [DeviceManagerPlatform] that uses method channels.
class MethodChannelDeviceManager extends DeviceManagerPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('device_manager');
  static const EventChannel _eventChannel =
      EventChannel('device_manager/event');
  StreamSubscription? events;

  @override
  Future<String?> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<String?> startDFU(
      {required String address,
      required String filePath,
      bool fileInAsset = false,
      FirmwareUpgradeMode mode = FirmwareUpgradeMode.testAndConfirm,
      int? estimatedSwapTime,
      bool? eraseAppSettings,
      int? pipelineDepth,
      int? reassemblyBufferSize,
      UpgradeCallback? upgradeDidStart,
      UpgradeCallback? upgradeDidComplete,
      UpgradeStateChangeCallback? upgradeStateDidChange,
      UpgradeStateCallback? upgradeDidCancel,
      UpgradeFailCallback? upgradeDidFail,
      UpgradeProgressCallback? uploadProgressDidChange}) async {
    events = _eventChannel.receiveBroadcastStream().listen((data) {
      data as Map;
      for (final key in data.keys) {
        print("key: $key, value: ${data[key]}");
        switch (key) {
          case "upgradeDidStart":
            upgradeDidStart?.call();
            break;
          case "upgradeDidComplete":
            upgradeDidComplete?.call();
            events?.cancel();
            break;
          case "upgradeStateDidChange":
            upgradeStateDidChange?.call(
                FirmwareUpgradeState.fromString(data[key]["previousState"])!,
                FirmwareUpgradeState.fromString(data[key]["newState"])!);
            break;
          case "upgradeDidCancel":
            upgradeDidCancel
                ?.call(FirmwareUpgradeState.fromString(data[key]["state"])!);
            events?.cancel();
            break;
          case "upgradeDidFail":
            upgradeDidFail?.call(
                FirmwareUpgradeState.fromString(data[key]["state"])!,
                data[key]["error"] as String?);
            events?.cancel();
            break;
          case "uploadProgressDidChange":
            uploadProgressDidChange?.call(
                data[key]["bytesSent"]!, data[key]["imageSize"]!);
            break;
        }
      }
    });

    final response = await methodChannel
        .invokeListMethod<String>('startDFU', <String, dynamic>{
      'uuid': address,
      'path': filePath,
      'fileInAsset': fileInAsset,
      'estimatedSwapTime': estimatedSwapTime,
      'firmwareUpgradeMode': mode.name,
      'eraseAppSettings': eraseAppSettings,
      'pipelineDepth': pipelineDepth,
      'reassemblyBufferSize': reassemblyBufferSize
    });
  }
}
