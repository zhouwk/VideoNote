//
//  ListPageViewModel.swift
//  VideoNote
//
//  Created by 周伟克 on 2020/11/11.
//

import Foundation
import AVKit

class ListPageViewModel {

    let fmts = [".mp4", ".MP4", ".rmvb", ".RMVB"]
    lazy var fm = FileManager.default
    lazy var videos = [VideoViewModel]()
    
    
    var onLoadData: (() -> ())?
    
    
    /// 加载文件
    func detectVideos() {
        let path = Bundle.main.bundlePath
        let files = (try? fm.contentsOfDirectory(atPath: path)) ?? []
        
        videos.removeAll()
        
        var model: VideoModel
        var viewModel: VideoViewModel
        
        for file in files {
            if fmts.contains(where: { file.hasSuffix($0) }) {
                model = VideoModel(name: file, path: path + "/" + file)
                viewModel = VideoViewModel(model: model)
                videos.append(viewModel)
            }
        }
        
        
        files.forEach { (file) in
            print(file)
        }

        
        
        
        
        onLoadData?()
        
        generatePreviews()
    }
    
    /// 加载预览图片
    func generatePreviews() {
        var time: NSValue
        var asset: AVAsset
        var generator: AVAssetImageGenerator
        
        for video in videos {
            time = NSValue(time: CMTime(value: 1, timescale: 1))
            asset = AVAsset(url: video.url)
            generator = AVAssetImageGenerator(asset: asset)
//            if let cgImage = try? generator.copyCGImage(at: time, actualTime: nil) {
//                video.preview = UIImage(cgImage: cgImage)
//            }
            generator.generateCGImagesAsynchronously(forTimes: [time]) { (_, preview, _, _, _) in
                if let preview = preview {
                    video.preview = UIImage(cgImage: preview)
                    DispatchQueue.main.async { [weak self] in
                        self?.onLoadData?()
                    }
                }
            }
        }
//        onLoadData?()
    }
}
