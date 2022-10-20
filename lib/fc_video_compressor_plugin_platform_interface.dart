import 'package:fc_video_compressor_plugin/data/media_info.dart';
import 'package:fc_video_compressor_plugin/observable_builder.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'fc_video_compressor_plugin_method_channel.dart';

abstract class FcVideoCompressorPluginPlatform extends PlatformInterface {
  /// Constructs a FcVideoCompressorPluginPlatform.
  FcVideoCompressorPluginPlatform() : super(token: _token);
  static const methodChannelName = "fc_video_compressor_plugin";

  final compressProgress = ObservableBuilder<double>();
  final _channel = const MethodChannel(methodChannelName);

  @protected
  void initProcessCallback() {
    _channel.setMethodCallHandler(_progressCallback);
  }


  MethodChannel get channel => _channel;

  bool _isCompressing = false;

  bool get isCompressing => _isCompressing;

  @protected
  void setProcessingStatus(bool status) {
    _isCompressing = status;
  }

  Future<void> _progressCallback(MethodCall call) async {
    switch (call.method) {
      case 'updateProgress':
        final progress = double.tryParse(call.arguments.toString());
        if (progress != null) compressProgress.next(progress);
        break;
    }
  }
  static final Object _token = Object();

  static FcVideoCompressorPluginPlatform _instance =
      MethodChannelFcVideoCompressorPlugin();

  /// The default instance of [FcVideoCompressorPluginPlatform] to use.
  ///
  /// Defaults to [MethodChannelFcVideoCompressorPlugin].
  static FcVideoCompressorPluginPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FcVideoCompressorPluginPlatform] when
  /// they register themselves.
  static set instance(FcVideoCompressorPluginPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }
  //
  // Future<String?> getPlatformVersion() {
  //   throw UnimplementedError('platformVersion() has not been implemented.');
  // }

  Future<MediaInfo?> compressVideo({
  required   String inputPath,
    required  String outputPath,
    required  int bitrate,
        required   bool deleteOrigin,
        required  int? startTime,
        required  int? duration,
        required  int? width,
        required  int? height,
        required  bool? includeAudio,
  required  int frameRate,
  }) {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<void> cancelCompression() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  /// delete the cache folder, please do not put other things
  /// in the folder of this plugin, it will be cleared
  Future<bool?> deleteAllCache() async {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }


}
