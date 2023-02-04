import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:device_manager/device_manager_method_channel.dart';

void main() {
  MethodChannelDeviceManager platform = MethodChannelDeviceManager();
  const MethodChannel channel = MethodChannel('device_manager');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
