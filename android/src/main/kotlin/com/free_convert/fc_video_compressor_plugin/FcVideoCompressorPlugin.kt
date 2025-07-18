package com.free_convert.fc_video_compressor_plugin


import android.content.Context
import android.net.Uri
import android.util.Log
import com.otaliastudios.transcoder.Transcoder
import com.otaliastudios.transcoder.TranscoderListener
import com.otaliastudios.transcoder.common.*
import com.otaliastudios.transcoder.internal.utils.Logger
import com.otaliastudios.transcoder.resize.ExactResizer
import com.otaliastudios.transcoder.source.ClipDataSource
import com.otaliastudios.transcoder.source.UriDataSource
import com.otaliastudios.transcoder.strategy.DefaultAudioStrategy
import com.otaliastudios.transcoder.strategy.DefaultVideoStrategy
import com.otaliastudios.transcoder.strategy.RemoveTrackStrategy
import com.otaliastudios.transcoder.strategy.TrackStrategy
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import org.json.JSONObject
import java.io.File
import java.util.concurrent.Future

/**
 * VideoCompressPlugin
 */
class FcVideoCompressorPlugin : MethodCallHandler, FlutterPlugin {


    private var _context: Context? = null
    private var _channel: MethodChannel? = null
    private val TAG = "FcVideoCompressorPlugin"
    private val LOG = Logger(TAG)
    private var transcodeFuture: Future<Void>? = null
    var channelName = "fc_video_compressor_plugin"

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        val context = _context;
        val channel = _channel;

        if (context == null || channel == null) {
            Log.w(TAG, "Calling VideoCompress plugin before initialization")
            return
        }

        when (call.method) {
            "getByteThumbnail" -> {
                val path = call.argument<String>("path")
                val quality = call.argument<Int>("quality")!!
                val position = call.argument<Int>("position")!! // to long
                ThumbnailUtility(channelName).getByteThumbnail(
                    path!!,
                    quality,
                    position.toLong(),
                    result
                )
            }
            "getFileThumbnail" -> {
                val path = call.argument<String>("path")
                val quality = call.argument<Int>("quality")!!
                val position = call.argument<Int>("position")!! // to long
                ThumbnailUtility("video_compress").getFileThumbnail(
                    context, path!!, quality,
                    position.toLong(), result
                )
            }
            "getMediaInfo" -> {
                val path = call.argument<String>("path")
                result.success(Utility(channelName).getMediaInfoJson(context, path!!).toString())
            }
            "deleteAllCache" -> {
                result.success(Utility(channelName).deleteAllCache(context, result));
            }
            "setLogLevel" -> {
                val logLevel = call.argument<Int>("logLevel")!!
                Logger.setLogLevel(logLevel)
                result.success(true);
            }
            "cancelCompression" -> {
                transcodeFuture?.cancel(true)
                result.success(false);
            }
            "compressVideo" -> {
                val path = call.argument<String>("inputPath")!!
                val outputPath = call.argument<String>("outputPath")!!
                val bitrate = call.argument<Int>("bitrate")!!
                val height = call.argument<Int?>("height")
                val width = call.argument<Int?>("width")
                val deleteOrigin = call.argument<Boolean>("deleteOrigin") ?: false
                val startTime = call.argument<Int?>("startTime")
                val endTime = call.argument<Int?>("duration")
                var audioBitrate = call.argument<Int?>("audioBitrate")?.toLong()
                var audioSampleRate = call.argument<Int?>("audioSampleRate")
                val includeAudio = call.argument<Boolean>("includeAudio") ?: true
                val frameRate =
                        if (call.argument<Int>("frameRate") == null) 30 else call.argument<Int>("frameRate")

//                val tempDir: String = context.getExternalFilesDir("video_compress")!!.absolutePath
//                val out = SimpleDateFormat("yyyy-MM-dd hh-mm-ss").format(Date())
//                val destPath: String =
//                    tempDir + File.separator + "VID_" + out + path.hashCode() + ".mp4"

                if (audioSampleRate == null) {
                    audioSampleRate = DefaultAudioStrategy.SAMPLE_RATE_AS_INPUT
                }


                if (audioBitrate == null) {
                    audioBitrate = 128000
                }

                val videoTrackStrategyBuilder = DefaultVideoStrategy.Builder();

                if (height != null && width != null) {
                    videoTrackStrategyBuilder.addResizer(ExactResizer(Size(width, height)))
                }

                var videoTrackStrategy: TrackStrategy =
                        videoTrackStrategyBuilder
                                .keyFrameInterval(3f)
                        .bitRate(bitrate.toLong())
                        .build()


                val audioTrackStrategy: TrackStrategy = if (includeAudio) {
//                    val sampleRate = audioSampleRate ?? DefaultAudioStrategy.SAMPLE_RATE_AS_INPUT
                    val channels = DefaultAudioStrategy.CHANNELS_AS_INPUT

                    DefaultAudioStrategy.builder()
                            .channels(channels)
                            .sampleRate(audioSampleRate)
                            .bitRate(audioBitrate)
                            .build()
                } else {
                    RemoveTrackStrategy()
                }


                val dataSource = if (startTime != null || endTime != null) {
//                    Log.d(TAG, "onMethodCall: startTime: ${startTime} endTime: $endTime")
                    val source = UriDataSource(context, Uri.parse(path))
                    ClipDataSource(
                            source,
                            (1000 * 1000 * (startTime ?: 0)).toLong(),
                            (1000 * 1000 * (endTime ?: 0)).toLong()
                    )
                } else {
                    UriDataSource(context, Uri.parse(path))
                }


                transcodeFuture = Transcoder.into(outputPath)
                    .addDataSource(dataSource)
                    .setAudioTrackStrategy(audioTrackStrategy)
                    .setVideoTrackStrategy(videoTrackStrategy)
                    .setListener(object : TranscoderListener {
                        override fun onTranscodeProgress(progress: Double) {
                            channel.invokeMethod("updateProgress", progress * 100.00)
                        }

                        override fun onTranscodeCompleted(successCode: Int) {
                            channel.invokeMethod("updateProgress", 100.00)
                            val json = Utility(channelName).getMediaInfoJson(context, outputPath)
                            json.put("isCancel", false)
                            result.success(json.toString())
                            Log.d("VideoCompressorPlugin", "$result")

                            if (deleteOrigin) {
                                File(path).delete()
                            }
                        }

                        override fun onTranscodeCanceled() {
                            val json = JSONObject()
                            json.put("isCancel", true)
                            json.put("errorMessage", "User canceled")
                            Log.d(TAG, "onTranscodeCanceled: ")
                            result.success(json.toString())


                        }

                        override fun onTranscodeFailed(exception: Throwable) {
                            val json = JSONObject()
                            json.put("errorMessage", exception.message)
                            json.put("isCancel", true)
                            Log.d(TAG, "onTranscodeFailed: ")
                            result.success(json.toString())
                        }


                    })
                    .transcode()

            }
            else -> {
                result.notImplemented()
            }
        }
    }

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        init(binding.applicationContext, binding.binaryMessenger)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        _channel?.setMethodCallHandler(null)
        _context = null
        _channel = null
    }

    private fun init(context: Context, messenger: BinaryMessenger) {
        val channel = MethodChannel(messenger, channelName)
        channel.setMethodCallHandler(this)
        _context = context
        _channel = channel
    }
}
