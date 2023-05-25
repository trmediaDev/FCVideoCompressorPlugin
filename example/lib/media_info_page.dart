// import 'package:ffmpeg_kit_flutter_full_gpl/ffprobe_kit.dart';
// import 'package:ffmpeg_kit_flutter_full_gpl/media_information.dart';
// import 'package:flutter/material.dart';
//
// class MediaInfoPage extends StatefulWidget {
//   final String filePath;
//
//   const MediaInfoPage({
//     Key? key,
//     required this.filePath,
//   }) : super(key: key);
//
//   @override
//   State<MediaInfoPage> createState() => _MediaInfoPageState();
// }
//
// class _MediaInfoPageState extends State<MediaInfoPage> {
//   MediaInformation? mediaInformation;
//
//   @override
//   void initState() {
//     _getMediaInfo();
//     super.initState();
//   }
//
//   Future<void> _getMediaInfo() async {
//     final session = await FFprobeKit.getMediaInformation(widget.filePath);
//     mediaInformation = session.getMediaInformation();
//     setState(() {});
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(),
//       body: ListView(
//         children: [
//           // Text("${mediaInformation?.getFilename()}"),
//           Text("getFormat: ${mediaInformation?.getFormat()}"),
//           Text("getBitrate: ${mediaInformation?.getBitrate()}"),
//           Text("getDuration: ${mediaInformation?.getDuration()}"),
//         ],
//       ),
//     );
//   }
// }
