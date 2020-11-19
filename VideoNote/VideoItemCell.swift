//
//  VideoItemCell.swift
//  VideoNote
//
//  Created by 周伟克 on 2020/11/11.
//

import UIKit

class VideoItemCell: UITableViewCell {

    
    static let reuseId = "VideoItemCell"
    
    @IBOutlet weak var videoContainer: UIView!
    @IBOutlet weak var preview: UIImageView!
    @IBOutlet weak var progressView: PiePanel!
    @IBOutlet weak var nameLabel: UILabel!
    
    
    var video: VideoViewModel? {
        didSet {
            preview.image = video?.preview
            nameLabel.text = video?.name
        }
    }
        
    override func awakeFromNib() {
        super.awakeFromNib()
        videoContainer.layer.cornerRadius = 10
        videoContainer.clipsToBounds = true
    }
    
    func playerFrameRelatedToView(_ view: UIView) -> CGRect {
        videoContainer.convert(videoContainer.bounds, to: view)
    }
    
    /// 插入播放器
    func insertPlayerView(_ playerView: PlayerView) {
        playerView.frame = videoContainer.bounds
        playerView.isHidden = false
        videoContainer.addSubview(playerView)
    }
    
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        progressView.layer.cornerRadius = progressView.frame.width * 0.5
    }
    
    
    
    static func reuseForTableView(_ tableView: UITableView) -> VideoItemCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "VideoItemCell") {
            return cell as! VideoItemCell
        }
        let nib = UINib(nibName: reuseId, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: reuseId)
        return tableView.dequeueReusableCell(withIdentifier: reuseId) as! VideoItemCell
    }
}
