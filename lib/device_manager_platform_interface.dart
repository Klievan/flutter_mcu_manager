import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'device_manager.dart';
import 'device_manager_method_channel.dart';

abstract class DeviceManagerPlatform extends PlatformInterface {
  /// Constructs a DeviceManagerPlatform.
  DeviceManagerPlatform() : super(token: _token);

  static final Object _token = Object();

  static DeviceManagerPlatform _instance = MethodChannelDeviceManager();

  /// The default instance of [DeviceManagerPlatform] to use.
  ///
  /// Defaults to [MethodChannelDeviceManager].
  static DeviceManagerPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [DeviceManagerPlatform] when
  /// they register themselves.
  static set instance(DeviceManagerPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

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
    throw UnimplementedError('startDFU() has not been implemented');
  }
}
