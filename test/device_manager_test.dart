import 'package:flutter_test/flutter_test.dart';
import 'package:device_manager/device_manager.dart';
import 'package:device_manager/device_manager_platform_interface.dart';
import 'package:device_manager/device_manager_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockDeviceManagerPlatform
    with MockPlatformInterfaceMixin
    implements DeviceManagerPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  Future<String?> startDFU(String uuid, String filePath, bool? fileInAsset) {
    throw UnimplementedError();
  }
}

void main() {
  final DeviceManagerPlatform initialPlatform = DeviceManagerPlatform.instance;

  test('$MethodChannelDeviceManager is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelDeviceManager>());
  });

  test('getPlatformVersion', () async {
    DeviceManager deviceManagerPlugin = DeviceManager();
    MockDeviceManagerPlatform fakePlatform = MockDeviceManagerPlatform();
    DeviceManagerPlatform.instance = fakePlatform;

    expect(await deviceManagerPlugin.getPlatformVersion(), '42');
  });
}
