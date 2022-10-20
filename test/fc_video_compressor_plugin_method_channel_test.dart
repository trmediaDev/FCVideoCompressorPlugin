import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fc_video_compressor_plugin/fc_video_compressor_plugin_method_channel.dart';

void main() {
  MethodChannelFcVideoCompressorPlugin platform = MethodChannelFcVideoCompressorPlugin();
  const MethodChannel channel = MethodChannel('fc_video_compressor_plugin');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  // test('getPlatformVersion', () async {
  //   expect(await platform.getPlatformVersion(), '42');
  // });
}
