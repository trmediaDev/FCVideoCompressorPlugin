# fc_video_compressor_plugin

Compress videos, remove audio, manipulate thumbnails, and make your video compatible with all platforms through this lightweight and efficient library.
100% native code was used, we do not use FFMPEG as it is very slow, bloated and the GNU license is an obstacle for commercial applications.
In addition, google chrome uses VP8/VP9, safari uses h264, and most of the time, it is necessary to encode the video in two formats, but not with this library.
All video files are encoded in an MP4 container with AAC audio that allows 100% compatibility with safari, mozila, chrome, android and iOS.

Works on ANDROID, IOS and desktop (just MacOS for now).



# Table of Contents
- [Installing](#lets-get-started)
- [How to use](#how-to-use)
    * [Imports](#imports)
    * [Video compression](#video-compression)
    * [Check compress state](#check-compress-state)

[//]: # (    * [Get memory thumbnail from VideoPath]&#40;#get-memory-thumbnail-from-videopath&#41;)
[//]: # (    * [Get File thumbnail from VideoPath]&#40;#get-file-thumbnail-from-videopath&#41;)
[//]: # (    * [Get media information]&#40;#get-media-information&#41;)
[//]: # (    * [delete all cache files]&#40;#delete-all-cache-files&#41;)
    * [Listen the compression progress](#listen-the-compression-progress)
- [TODO](#todo)

# Lets Get Started

### 1. Depend on it
Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  fc_video_compressor_plugin: 
   git:
     url: https://github.com/trmediaDev/FCVideoCompressorPlugin.git
```

### 2. Install it

You can install packages from the command line:

with `pub`:

```css
$  pub get
```

### 3. Import it

Now in your `Dart` code, you can use:

````dart
import 'package:video_compress/fc_video_compressor_plugin.dart';
````

# How to use

### Imports

````dart
import 'package:video_compress/fc_video_compressor_plugin.dart';
    
````

## Video compression

```dart
MediaInfo mediaInfo = await FcVideoCompressorPlugin.compressVideo(
inputPath: inputPath,
outputPath: outputPath,
bitrate: bitrate,
);
```

## Check compress state
```dart
VideoQuality.isCompressing
```
<!-- ## Cancel compression
```dart
await videoCompress.cancelCompression()
``` -->




## Listen the compression progress
```dart
class _Compress extends State<Compress> {

  Subscription _subscription;

  @override
  void initState() {
    super.initState();
    _subscription =
        VideoCompress.compressProgress$.subscribe((progress) {
      debugPrint('progress: $progress');
    });
  }

  @override
  void dispose() {
    super.dispose();
    _subscription.unsubscribe();
  }
}
```

### TODO
- Add the trim video function
- Add cancel function to Android


## Subscriptions
| Subscriptions     | Description                              | Stream            |
| ----------------- | ---------------------------------------- | ----------------- |
| compressProgress$ | Subscribe the compression progress steam | double `progress` |

## Contribute

Contributions are always welcome!
<!-- Please read the [contribution guidelines](contributing.md) first. -->

## acknowledgment

Inspired by the flutter_ffmpeg library.
https://github.com/rurico/flutter_video_compress

