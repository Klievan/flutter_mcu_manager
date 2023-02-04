import 'device_manager_platform_interface.dart';

typedef UpgradeCallback = void Function();

typedef UpgradeProgressCallback = void Function(int bytesSent, int imageSize);
typedef UpgradeStateCallback = void Function(FirmwareUpgradeState state);
typedef UpgradeFailCallback = void Function(
    FirmwareUpgradeState state, String? error);
typedef UpgradeStateChangeCallback = void Function(
    FirmwareUpgradeState previousState, FirmwareUpgradeState newState);

enum FirmwareUpgradeMode { testOnly, confirmOnly, testAndConfirm }

enum FirmwareUpgradeState {
  none,
  requestMcuMgrParameters,
  validate,
  upload,
  test,
  reset,
  confirm,
  success;

  static FirmwareUpgradeState? fromString(String name) {
    for (FirmwareUpgradeState state in values) {
      if (name.toLowerCase() == state.name.toLowerCase()) return state;
    }
    return null;
  }
}

class DeviceManager {
  Future<String?> getPlatformVersion() {
    return DeviceManagerPlatform.instance.getPlatformVersion();
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
    return DeviceManagerPlatform.instance.startDFU(
        address: address,
        filePath: filePath,
        fileInAsset: fileInAsset,
        mode: mode,
        estimatedSwapTime: estimatedSwapTime,
        eraseAppSettings: eraseAppSettings,
        pipelineDepth: pipelineDepth,
        reassemblyBufferSize: reassemblyBufferSize,
        upgradeDidStart: upgradeDidStart,
        upgradeDidComplete: upgradeDidComplete,
        upgradeStateDidChange: upgradeStateDidChange,
        upgradeDidCancel: upgradeDidCancel,
        upgradeDidFail: upgradeDidFail,
        uploadProgressDidChange: uploadProgressDidChange);
  }
}
