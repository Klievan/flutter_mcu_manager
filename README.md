# Device Manager

Device Manager is the Flutter implementation of Nordic's Device Manager. It allows users to perform firmware updates over Bluetooth to devices running MCUBoot and MCUM Manager (commonly used in ZephyrRTOS projects using Bluetooth Low Energy).

## Supported Platforms

| Feature        | iOS      | Android  |
| -------------- | -------- | -------- |
| Basic commands | ❌       | ❌       |
| Images         | only DFU | only DFU |
| Stats          | ❌       | ❌       |
| Logs           | ❌       | ❌       |
| Filesystem     | ❌       | ❌       |
| Shell          | ❌       | ❌       |

## Getting Starting using the example

1. Add your DFU .bin file to example/assets/file.bin
2. Replace the target address in example/lib/main.dart with the device's target address
3. Build and run the project
4. Observe the DFU in the debug console.

## Usage

### Importing the package

```dart
import 'package:device_manager/device_manager.dart';
```

### Performing a DFU

```dart
      _deviceManagerPlugin.startDFU(
        address: "C2:48:1A:45:2F:6E", // Target device address
        filePath: "assets/app_update.bin", // Path to the DFU file
        fileInAsset: true, // Whether the file is in the assets folder or within the app's storage
        estimatedSwapTime: 37000, // Estimated time for the device to swap to the new firmware. Important when using "testAndConfirm" mode.
        mode: FirmwareUpgradeMode.testAndConfirm,  // Firmware upgrade mode. Can be "confirmOnly", "testAndConfirm", or "testOnly". Defaults to "testAndConfirm".
        uploadProgressDidChange: (bytesSent, totalImageSize) =>  // Callback for upload progress
            print("Upload progress did change: $bytesSent / $totalImageSize"),
        upgradeDidComplete: () => print("Upgrade completed"), // Callback for when the upgrade completes
        upgradeDidFail: (state, error) => // Callback for when the upgrade fails
            print("Upgrade failed with state $state and error $error"),
        upgradeStateDidChange: (previousState, newState) => // Callback for when the upgrade state changes. Possible states are  none, requestMcuMgrParameters, validate, upload, test, reset, confirm, success;
            print("State changed from $previousState to $newState"),
      );
```
