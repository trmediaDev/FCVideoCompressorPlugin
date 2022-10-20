import 'dart:convert';

import 'package:fc_video_compressor_plugin/data/media_info.dart';
import 'package:fc_video_compressor_plugin/observable_builder.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'fc_video_compressor_plugin_platform_interface.dart';

/// An implementation of [FcVideoCompressorPluginPlatform] that uses method channels.
class MethodChannelFcVideoCompressorPlugin extends FcVideoCompressorPluginPlatform {



  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel(FcVideoCompressorPluginPlatform.methodChannelName);

  Future<T?> _invoke<T>(String name, [Map<String, dynamic>? params]) async {
    T? result;
    try {
      result = params != null
          ? await methodChannel.invokeMethod(name, params)
          : await methodChannel.invokeMethod(name);
    } on PlatformException catch (e) {
      debugPrint('''Error from VideoCompress: 
      Method: $name
      $e''');
    }
    return result;
  }


  @override
  Future<MediaInfo?> compressVideo(
       {
        required   String inputPath,
        required  String outputPath,
         required  int bitrate,
        bool deleteOrigin = false,
        int? startTime,
        int? duration,
         int? width,
         int? height,
        bool? includeAudio,
        int frameRate = 30,
      }) async {
    if (isCompressing) {
      throw StateError('''VideoCompress Error: 
      Method: compressVideo
      Already have a compression process, you need to wait for the process to finish or stop it''');
    }

    if (compressProgress.notSubscribed) {
      debugPrint('''VideoCompress: You can try to subscribe to the 
      compressProgress\$ stream to know the compressing state.''');
    }

    // ignore: invalid_use_of_protected_member
    setProcessingStatus(true);
    final jsonStr = await _invoke<String>('compressVideo', {
      'inputPath': inputPath,
      'outputPath': outputPath,
      'bitrate': bitrate,
      'width': width,
      'height': height,
      'deleteOrigin': deleteOrigin,
      'startTime': startTime,
      'duration': duration,
      'includeAudio': includeAudio,
      'frameRate': frameRate,
    });

    // debugPrint(jsonStr);

    // ignore: invalid_use_of_protected_member
    setProcessingStatus(false);

    if (jsonStr != null) {
      final jsonMap = json.decode(jsonStr);
      return MediaInfo.fromJson(jsonMap);
    } else {
      return null;
    }
  }

  /// stop compressing the file that is currently being compressed.
  /// If there is no compression process, nothing will happen.
  @override
  Future<void> cancelCompression() async {
    await _invoke<void>('cancelCompression');
  }

  /// delete the cache folder, please do not put other things
  /// in the folder of this plugin, it will be cleared
  @override
  Future<bool?> deleteAllCache() async {
    return await _invoke<bool>('deleteAllCache');
  }




}


