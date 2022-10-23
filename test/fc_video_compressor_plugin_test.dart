import 'package:fc_video_compressor_plugin/data/media_info.dart';
import 'package:fc_video_compressor_plugin/observable_builder.dart';
import 'package:flutter/src/services/platform_channel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fc_video_compressor_plugin/fc_video_compressor_plugin.dart';
import 'package:fc_video_compressor_plugin/fc_video_compressor_plugin_platform_interface.dart';
import 'package:fc_video_compressor_plugin/fc_video_compressor_plugin_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFcVideoCompressorPluginPlatform
    with MockPlatformInterfaceMixin
    implements FcVideoCompressorPluginPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  Future<void> cancelCompression() {
    // TODO: implement cancelCompression
    throw UnimplementedError();
  }



  @override
  Future<bool?> deleteAllCache() {
    // TODO: implement deleteAllCache
    throw UnimplementedError();
  }

  @override
  Future<void> setLogLevel(int logLevel) {
    // TODO: implement setLogLevel
    throw UnimplementedError();
  }

  @override
  // TODO: implement channel
  MethodChannel get channel => throw UnimplementedError();

  @override
  // TODO: implement compressProgress$
  ObservableBuilder<double> get compressProgress => throw UnimplementedError();

  @override
  void initProcessCallback() {
    // TODO: implement initProcessCallback
  }

  @override
  // TODO: implement isCompressing
  bool get isCompressing => throw UnimplementedError();

  @override
  void setProcessingStatus(bool status) {
    // TODO: implement setProcessingStatus
  }

  @override
  Future<MediaInfo?> compressVideo({required String inputPath, required String outputPath, required int bitrate, required bool deleteOrigin, required int? startTime, required int? duration, required int? width, required int? height, required bool? includeAudio, required int? audioSampleRate, required int? audioBitrate, required int frameRate}) {
    // TODO: implement compressVideo
    throw UnimplementedError();
  }



}

void main() {
  final FcVideoCompressorPluginPlatform initialPlatform = FcVideoCompressorPluginPlatform.instance;

  test('$MethodChannelFcVideoCompressorPlugin is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFcVideoCompressorPlugin>());
  });

  test('getPlatformVersion', () async {
    FcVideoCompressorPlugin fcVideoCompressorPlugin = FcVideoCompressorPlugin();
    MockFcVideoCompressorPluginPlatform fakePlatform = MockFcVideoCompressorPluginPlatform();
    FcVideoCompressorPluginPlatform.instance = fakePlatform;

    // expect(await fcVideoCompressorPlugin.getPlatformVersion(), '42');
  });
}
