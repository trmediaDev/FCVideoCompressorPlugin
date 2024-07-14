//
//  Generated file. Do not edit.
//

import FlutterMacOS
import Foundation

import fc_video_compressor_plugin
import file_selector_macos
import path_provider_foundation
import photo_manager
import video_player_avfoundation

func RegisterGeneratedPlugins(registry: FlutterPluginRegistry) {
  FcVideoCompressorPlugin.register(with: registry.registrar(forPlugin: "FcVideoCompressorPlugin"))
  FileSelectorPlugin.register(with: registry.registrar(forPlugin: "FileSelectorPlugin"))
  PathProviderPlugin.register(with: registry.registrar(forPlugin: "PathProviderPlugin"))
  PhotoManagerPlugin.register(with: registry.registrar(forPlugin: "PhotoManagerPlugin"))
  FVPVideoPlayerPlugin.register(with: registry.registrar(forPlugin: "FVPVideoPlayerPlugin"))
}
