import 'package:fc_video_compressor_plugin/data/media_info.dart';
import 'package:fc_video_compressor_plugin/observable_builder.dart';

import 'fc_video_compressor_plugin_platform_interface.dart';

class FcVideoCompressorPlugin {
  static ObservableBuilder<double> get compressProgress =>
      FcVideoCompressorPluginPlatform.instance.compressProgress;

  // Future<String?> getPlatformVersion() {
  //   return FcVideoCompressorPluginPlatform.instance.getPlatformVersion();
  // }

  static void initProcessCallback()=> FcVideoCompressorPluginPlatform.instance.initProcessCallback();
  static bool get isCompressing =>
      FcVideoCompressorPluginPlatform.instance.isCompressing;

  static Future<MediaInfo?> compressVideo({
    required String inputPath,
    required String outputPath,
    required int bitrate,
    bool deleteOrigin = false,
    int? startTime,
    int? duration,
    int? width,
    int? height,
    bool? includeAudio,
    int frameRate = 30,
  }) async {
    return FcVideoCompressorPluginPlatform.instance.compressVideo(
      inputPath: inputPath,
      outputPath: outputPath,
      bitrate: bitrate,
      deleteOrigin: deleteOrigin,
      startTime: startTime,
      duration: duration,
      width: width,
      height: height,
      includeAudio: includeAudio,
      frameRate: frameRate,
    );
  }

  static Future<void> cancelCompression() async {
    return FcVideoCompressorPluginPlatform.instance.cancelCompression();
  }

  // static Future<bool?> deleteAllCache() async {
  //   return FcVideoCompressorPluginPlatform.instance.deleteAllCache();
  // }

}
