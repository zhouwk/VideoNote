//
//  VideoModel.swift
//  VideoNote
//
//  Created by 周伟克 on 2020/11/11.
//

import Foundation


struct VideoModel {
    let name: String
    let path: String
}



import UIKit
class VideoViewModel {
    
    private let model: VideoModel
    
    var name: String { model.name }
    var url: URL { URL(fileURLWithPath: model.path) }
    var preview: UIImage?
    
    
    init(model: VideoModel) {
        self.model = model
    }
}
