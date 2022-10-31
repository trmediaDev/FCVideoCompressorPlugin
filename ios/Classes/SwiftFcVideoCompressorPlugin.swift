import Flutter
import UIKit
import AVFoundation


//some of the code coppied form
//https://github.com/AbedElazizShe/LightCompressor_iOS
//and
//https://github.com/jonataslaw/VideoCompress


public class SwiftFcVideoCompressorPlugin: NSObject, FlutterPlugin {
    
    init(channel: FlutterMethodChannel) {
        self.channel = channel
    }
    private let channel: FlutterMethodChannel
    
    let avController = AvController()
    var videoWriter:AVAssetWriter?
    var videoReader: AVAssetReader!
    var audioReader: AVAssetReader?
    
    let progressQueue = DispatchQueue.init(label: "fc_video_compressor_pluginprogressQueue")
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "fc_video_compressor_plugin", binaryMessenger: registrar.messenger())
        let instance = SwiftFcVideoCompressorPlugin(channel: channel)
        
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        
        let args = call.arguments as? Dictionary<String, Any>
        
        //    result("iOS " + UIDevice.current.systemVersion)
        
        switch call.method {
            //          case "getByteThumbnail":
            //              let path = args!["path"] as! String
            //              let quality = args!["quality"] as! NSNumber
            //              let position = args!["position"] as! NSNumber
            //              getByteThumbnail(path, quality, position, result)
            //          case "getFileThumbnail":
            //              let path = args!["path"] as! String
            //              let quality = args!["quality"] as! NSNumber
            //              let position = args!["position"] as! NSNumber
            //              getFileThumbnail(path, quality, position, result)
            //          case "getMediaInfo":
            //              let path = args!["path"] as! String
            //              getMediaInfo(path, result)
            
        case "cancelCompression":
            cancelCompression(result)
        case "deleteAllCache":
            Utility.deleteFile(Utility.basePath(), clear: true)
            result(true)
        case "compressVideo":
            
            let path = args!["inputPath"] as! String
            let outputPath = args!["outputPath"] as! String
            let bitrate = args!["bitrate"] as! Int
            let deleteOrigin = args!["deleteOrigin"] as! Bool
            let startTime = args!["startTime"] as? Double
            let width = args!["width"] as? Int
            let height = args!["height"] as? Int
            let duration = args!["duration"] as? Double
            let includeAudio = args!["includeAudio"] as? Bool
            let frameRate = args!["frameRate"] as? Int
            let audioBitrate = args!["audioBitrate"] as? Int
            let audioSampleRate = args!["audioSampleRate"] as? Int
            compressVideo(
                path:path,
                outputPath:outputPath,
                bitrate:bitrate,
                deleteOrigin:deleteOrigin,
                startTime:startTime,
                duration:duration,
                includeAudio:includeAudio,
                
                frameRate:frameRate,
                width: width,
                height: height,
                audioBitrate:audioBitrate,
                audioSampleRate:audioSampleRate,
                result:result)
            
        case "setLogLevel":
            result(true)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func getMediaInfo(_ path: String,_ result: FlutterResult) {
        let json = getMediaInfoJson(path)
        let string = Utility.keyValueToJson(json)
        result(string)
    }
    
    
    
    //
    
    
    private func getOutputFormate(destination: URL) -> AVFileType {
        switch(destination.pathExtension){
        case "mov":
            return AVFileType.mov
            
        case "3gp":
            return AVFileType.mobile3GPP
            
        case "m4v":
            return AVFileType.m4v
            
        default:
            return AVFileType.mp4
        }
    }
    
    private func updateProgresss(progress:Progress,frameCount:Int64){
        progress.completedUnitCount  = frameCount
        
        //                        let progress = ( frameCount/totalUnits)*100
        let progressValue = progress.fractionCompleted * 100;
        self.channel.invokeMethod("updateProgress", arguments: "\(String(describing:   progressValue))")
        print("Progress: \(Int(progressValue))")
        
    }
    private func compressVideo(
        path: String,
        outputPath: String,
        bitrate: Int,
        deleteOrigin: Bool,
        startTime: Double?,
        duration: Double?,
        includeAudio: Bool?,
        frameRate: Int?,
        width: Int?,
        height: Int?,
        audioBitrate: Int?,
        audioSampleRate: Int?,
        result: @escaping FlutterResult
    ){
        
        
        let soruce =     Utility.getPathUrl(path)
        let destination = Utility.getPathUrl(outputPath)
        let videoAsset = AVURLAsset(url: soruce)
        var frameCount:Int64 = 0
        guard let videoTrack = videoAsset.tracks(withMediaType: AVMediaType.video).first else {
            
            
            
            var json = self.getMediaInfoJson(path)
            json["isCancel"]=true
            json["errorMessage"] = "Video track not found"
            let jsonString = Utility.keyValueToJson(json)
            return result(jsonString);
        }
        
        let newBitrate:Int = bitrate
        
        
        let videoSize = videoTrack.naturalSize
        let newWidth:Int = width ?? Int( videoSize.width);
        let newHeight:Int = height ?? Int(videoSize.height);
        
        // Total Frames
        let durationInSeconds = duration ?? videoAsset.duration.seconds
        let nominalFrameRate = videoTrack.nominalFrameRate
        let totalFrames = ceil(durationInSeconds * Double(nominalFrameRate))
        
        // Progress
        let totalUnits = Int64(totalFrames)
        let progress = Progress(totalUnitCount: totalUnits)
        
        
        
        let outputformate = getOutputFormate(destination:destination)
        
        // Setup video writer input
        let videoWriterInput = AVAssetWriterInput(mediaType: AVMediaType.video, outputSettings: getVideoWriterSettings(bitrate: newBitrate, width: newWidth, height: newHeight))
        videoWriterInput.expectsMediaDataInRealTime = true
        videoWriterInput.transform = videoTrack.preferredTransform
        
        let timeRange = duration == nil ? nil: CMTimeRange(start: CMTime.zero, end: CMTime.init(seconds: duration!, preferredTimescale: 1));
        
        videoWriter = try! AVAssetWriter(outputURL: destination, fileType: outputformate)
        videoWriter!.add(videoWriterInput)
        
        
        // Setup video reader output
        let videoReaderSettings:[String : AnyObject] = [
            kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange) as AnyObject
        ]
        let videoReaderOutput = AVAssetReaderTrackOutput(track: videoTrack, outputSettings: videoReaderSettings)
        
        
        do{
            videoReader = try AVAssetReader(asset: videoAsset)
            
            if(timeRange != nil){
                videoReader.timeRange = timeRange!
            }
           
        }
        catch {
            print(error.localizedDescription)
            //                return result(error.localizedDescription)
            
            
            var json = self.getMediaInfoJson(path)
            json["isCancel"]=true
            json["errorMessage"] = error.localizedDescription
            let jsonString = Utility.keyValueToJson(json)
            return result(jsonString);
        }
        
        videoReader?.add(videoReaderOutput)
        //setup audio writer
        
        let audioInputSettingsDict: [String:Any] = [
            AVFormatIDKey : kAudioFormatMPEG4AAC,
            AVNumberOfChannelsKey : 2,
            AVSampleRateKey :  audioSampleRate ?? 44100,
            AVEncoderBitRateKey: audioBitrate ?? 128000
        ]
        
        
        let audioWriterInput = AVAssetWriterInput(mediaType: AVMediaType.audio, outputSettings: audioInputSettingsDict)
        audioWriterInput.expectsMediaDataInRealTime = false
        videoWriter?.add(audioWriterInput)
        //setup audio reader
        let audioTrack = videoAsset.tracks(withMediaType: AVMediaType.audio).first
        
        var audioReaderOutput: AVAssetReaderTrackOutput?
        if(audioTrack != nil) {
            let audioOutputSettingsDict: [String : Any] = [
                AVFormatIDKey: kAudioFormatLinearPCM,
                AVSampleRateKey :  audioSampleRate ?? 44100,
            ]
            audioReaderOutput = AVAssetReaderTrackOutput(track: audioTrack!, outputSettings: audioOutputSettingsDict)
            audioReader = try! AVAssetReader(asset: videoAsset)
            
            if(timeRange != nil){
                audioReader?.timeRange = timeRange!
            }
          
            audioReader?.add(audioReaderOutput!)
        }
        videoWriter?.startWriting()
        
        //start writing from video reader
        videoReader?.startReading()
        videoWriter?.startSession(atSourceTime: CMTime.zero)
        let processingQueue = DispatchQueue(label: "processingQueue1")
        
        
        var isFirstBuffer = true
        videoWriterInput.requestMediaDataWhenReady(on: processingQueue, using: {() -> Void in
            while videoWriterInput.isReadyForMoreMediaData {
                
                print("videoReader status\( String(describing: self.videoReader?.status.rawValue))")
                print("videoWriter status\( String(describing: self.videoWriter?.status.rawValue))")
                // Update progress based on number of processed frames
                frameCount += 1
                self.updateProgresss(progress: progress,frameCount:frameCount)
                
                let sampleBuffer: CMSampleBuffer? = videoReaderOutput.copyNextSampleBuffer()
                
                print("is sampleBuffer == nil\(sampleBuffer == nil)")
                
                if self.videoReader.status == .reading && sampleBuffer != nil {
                    videoWriterInput.append(sampleBuffer!)
                } else {
                    videoWriterInput.markAsFinished()
                    if self.videoReader!.status == .completed  {
                        if(self.audioReader != nil){
                            if(!(self.audioReader!.status == .reading) || !(self.audioReader!.status == .completed)){
                                //start writing from audio reader
                                
                                let endTime = CMTime.init(seconds: 3.0, preferredTimescale: 1000)
                                self.audioReader?.startReading()
                                self.videoWriter?.startSession(atSourceTime: CMTime.zero)
                                //
                                let processingQueue2 = DispatchQueue(label: "processingQueue2")
                                
                                audioWriterInput.requestMediaDataWhenReady(on: processingQueue2, using: {() -> Void in
                                    
                                    while audioWriterInput.isReadyForMoreMediaData {
                                        let sampleBuffer: CMSampleBuffer? = audioReaderOutput?.copyNextSampleBuffer()
                                        if self.audioReader?.status == .reading && sampleBuffer != nil {
                                            if isFirstBuffer {
                                                let dict = CMTimeCopyAsDictionary(CMTimeMake(value: 1024, timescale: 44100), allocator: kCFAllocatorDefault);
                                                CMSetAttachment(sampleBuffer as CMAttachmentBearer, key: kCMSampleBufferAttachmentKey_TrimDurationAtStart, value: dict, attachmentMode: kCMAttachmentMode_ShouldNotPropagate);
                                                isFirstBuffer = false
                                            }
                                            audioWriterInput.append(sampleBuffer!)
                                        } else {
                                            audioWriterInput.markAsFinished()
                                            
                                            self.videoWriter?.finishWriting(completionHandler: {() -> Void in
                                                
                                                var json = self.getMediaInfoJson(destination.absoluteString)
                                                json["isCancel"]=false
                                                let jsonString = Utility.keyValueToJson(json)
                                                return result(jsonString);
                                            })
                                            
                                        }
                                    }
                                })
                            }
                        }
                        
                        
                        else if(self.videoWriter?.status == .cancelled){
                            var json = self.getMediaInfoJson(destination.absoluteString)
                            json["isCancel"]=true
                            json["errorMessage"] = "User canceled"
                            let jsonString = Utility.keyValueToJson(json)
                            return result(jsonString);
                        }
                        
                        else {
                            self.videoWriter?.finishWriting(completionHandler: {() -> Void in
                                //                                    result(destination)
                                //                                    print(destination)
                                var json = self.getMediaInfoJson(destination.absoluteString)
                                json["isCancel"]=false
                                let jsonString = Utility.keyValueToJson(json)
                                return result(jsonString);
                            })
                        }
                    }
                    else{
                        var json = self.getMediaInfoJson(destination.absoluteString)
                        json["isCancel"]=true
                        json["errorMessage"] = "Video is corrupted"
                        let jsonString = Utility.keyValueToJson(json)
                        return result(jsonString);
                    }
                    
                }
            }
        })
        
    }
    
    private func cancelCompression(_ result: FlutterResult) {
        videoWriter?.cancelWriting()
        videoReader?.cancelReading()
        audioReader?.cancelReading()
        
        result(true)
    }
    
    
    
    private func getVideoWriterSettings(bitrate: Int, width: Int, height: Int) -> [String : AnyObject] {
        
        let videoWriterCompressionSettings = [
            AVVideoAverageBitRateKey : bitrate
        ]
        
        let videoWriterSettings: [String : AnyObject] = [
            AVVideoCodecKey : AVVideoCodecType.h264 as AnyObject,
            AVVideoCompressionPropertiesKey : videoWriterCompressionSettings as AnyObject,
            AVVideoWidthKey : width as AnyObject,
            AVVideoHeightKey : height as AnyObject
        ]
        
        return videoWriterSettings
    }
    
    
    
    
    public func getMediaInfoJson(_ path: String)->[String : Any?] {
        let url = Utility.getPathUrl(path)
        let asset = avController.getVideoAsset(url)
        guard let track = avController.getTrack(asset) else { return [:] }
        
        let playerItem = AVPlayerItem(url: url)
        let metadataAsset = playerItem.asset
        
        let orientation = avController.getVideoOrientation(path)
        
        let title = avController.getMetaDataByTag(metadataAsset,key: "title")
        let author = avController.getMetaDataByTag(metadataAsset,key: "author")
        
        let duration = asset.duration.seconds * 1000
        let filesize = track.totalSampleDataLength
        
        let size = track.naturalSize.applying(track.preferredTransform)
        
        let width = abs(size.width)
        let height = abs(size.height)
        
        let dictionary = [
            "path":Utility.excludeFileProtocol(path),
            "title":title,
            "author":author,
            "width":width,
            "height":height,
            "duration":duration,
            "filesize":filesize,
            "orientation":orientation,
            "isCancle":false,
        ] as [String : Any?]
        return dictionary
    }
    
}
