import 'dart:io';

import 'package:fc_video_compressor_plugin/data/media_info.dart';
import 'package:fc_video_compressor_plugin/fc_video_compressor_plugin.dart';
import 'package:file_sizes/file_sizes.dart' as file_sizes;
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:open_file/open_file.dart' as open_file;
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

final logger = Logger();
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool compressing = false;
  MediaInfo? mediaInfo;
  File? originalFile;
  int progress = 0;

  @override
  void initState() {
    super.initState();

    FcVideoCompressorPlugin.initProcessCallback();

    FcVideoCompressorPlugin.compressProgress.subscribe((event) {
      logger.d("Progress: $event");
      progress = event.toInt();
      setState(() {});
    });
  }

  Future<void> _compressVideo(BuildContext context) async {
    await AssetPicker.permissionCheck();
    final List<AssetEntity>? result = await AssetPicker.pickAssets(context,
        pickerConfig: AssetPickerConfig(
          requestType: RequestType.video,
        ));

    if (result != null) {
      for (var element in result) {
        await _compressASingleVideo(element);
      }
    }
  }

  Future<void> _compressASingleVideo(AssetEntity assetEntity) async {
    final outputPath =
        "${(await path_provider.getTemporaryDirectory()).path}/${DateTime.now().microsecondsSinceEpoch}_compressed.mov";

    originalFile = await assetEntity.file;

    if (originalFile == null) {
      return;
    }

    setState(() {
      compressing = true;
    });
    final filseSize = await originalFile!.length();

    final int width = (assetEntity!.width ~/ 1).toInt();
    int nearestEvenWidth = (width ~/ 2) * 2;
    final int height = (assetEntity.height ~/ 1).toInt();
    final int nearestEvenHeight = (height ~/ 2) * 2;
    // ignore: non_constant_identifier_names
    final int new_area = nearestEvenWidth * nearestEvenHeight;
    // ignore: non_constant_identifier_names
    int old_area = assetEntity.width * assetEntity.height;
    // ignore: non_constant_identifier_names
    final int video_duration = assetEntity.duration.toInt();
    // ignore: non_constant_identifier_names
    final double original_size_in_kBit = 8 * (filseSize) / 1000;
    // ignore: division_optimization
    final int kBitrate = (new_area / old_area) * original_size_in_kBit ~/ video_duration;


    // Custom File size
    // const targetFileSizeInMB = 16;
    //
    // final int width = (assetEntity!.size.width~/ 1.2 );
    // int nearestEvenWidth = (width ~/ 2) * 2;
    // final int height = (assetEntity.size.height~/ 1.2);
    // final int nearestEvenHeight = (height ~/ 2) * 2;
    // final int videoDuration = assetEntity.duration;
    // const num targetSizeInKBit = targetFileSizeInMB * 8000;
    // final int kBitrate = (targetSizeInKBit ~/ videoDuration);


    // FcVideoCompressorPlugin.setLogLevel(0);

    final int bitrate = kBitrate *1000;
    // final int bitrate = (1991 * 1000)~/2;
    logger.d({
      "": "Start Compression",
      "Input": originalFile!.path,
      "OutputPath": outputPath,
      "original size": "${assetEntity.size.width} X ${assetEntity.size.height}",
      "target size": "$width X $height",
      "target bitrate": bitrate,
      "duration": assetEntity.duration,
    });

    final startedAt = DateTime.now();
    mediaInfo = await FcVideoCompressorPlugin.compressVideo(
      inputPath: originalFile!.path,
      outputPath: outputPath,
      height: nearestEvenHeight,
      width: nearestEvenWidth,
      bitrate: bitrate,
      duration: 4,
    );
    debugPrint("End Compression");
    debugPrint("$mediaInfo");
    final endedAt = DateTime.now();
    logger.d({
      "start": startedAt.toString(),
      "endedAt": endedAt.toString(),
      "diff": endedAt.difference(startedAt).inSeconds,
      "fileSize": mediaInfo?.filesize?.toFileSize(),
      "size": "${mediaInfo?.width} * ${mediaInfo?.height}",
    });

    if(mediaInfo?.isCancel ?? false){
      logger.e("Canceled: ${mediaInfo?.errorMessage}");
    }
    setState(() {
      compressing = false;
    });
  }
  num _reduceTargetFileSize(num targetFileSize) {
    if (targetFileSize < 10) {
      return targetFileSize - (targetFileSize * 20) / 100;
    } else if (targetFileSize < 100) {
      return targetFileSize - (targetFileSize * 15) / 100;
    } else {
      return targetFileSize - (targetFileSize * 12) / 100;
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title!),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Column(
              children: [
                const Text("Original"),
                Text("File Size: ${originalFile?.path}"),
                FutureBuilder<int>(
                    future: originalFile?.length(),
                    builder: (context, snapshot) {
                      return Text("${snapshot.data?.toFileSize()}");
                    }),
              ],
            ),

            Text("Progress: $progress %",style: Theme.of(context).textTheme.headline6,),

            Column(
              children: [
                const Text("Compressed: "),
                Text("${mediaInfo?.path}"),
                Text("${mediaInfo?.width} X ${mediaInfo?.height} "),
                Text("${mediaInfo?.filesize?.toFileSize()}"),
              ],
            ),

            if (compressing) const Text("Compressing ..."),

            if (compressing)
              InkWell(
                  child: const Icon(
                    Icons.cancel,
                    size: 55,
                  ),
                  onTap: () async {
                    await FcVideoCompressorPlugin.cancelCompression();
                    compressing = FcVideoCompressorPlugin.isCompressing;
                    setState(() {});
                  }),
            if(mediaInfo?.path != null)
              ElevatedButton(
                onPressed: () {
                  open_file.OpenFile.open(mediaInfo?.path!);
                },
                child: const Text('Open File'),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async => _compressVideo(context),
        tooltip: 'Start Compress',
        child: const Icon(Icons.add),
      ),
    );
  }
}

extension IntExt on int{
  String toFileSize() {
    return file_sizes.FileSize.getSize(this);
  }
}
