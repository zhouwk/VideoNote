//
//  SimplifiedPlayerView.swift
//  VideoNote
//
//  Created by 周伟克 on 2020/11/11.
//

import UIKit

class SimplifiedPlayerView: PlayerView {

    let volumeBtn = UIButton(type: .custom)
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        volumeBtn.setImage(UIImage(named: "volume_off"), for: .normal)
        volumeBtn.setImage(UIImage(named: "volume_on"), for: .selected)
        volumeBtn.addTarget(self,
                            action: #selector(volumeBtnDidClick(_:)),
                            for: .touchUpInside)
        addSubview(volumeBtn)
        backgroundColor = UIColor.black.withAlphaComponent(0.2)
    }
    
    @objc func volumeBtnDidClick(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        player?.isMuted = !sender.isSelected
    }
    
    override func didGetDuration() {
        print("播放时长： \(duration)")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        volumeBtn.frame = CGRect(x: frame.width - 44,
                                 y: frame.height - 44,
                                 width: 44,
                                 height: 44)
    }
    
    
    required init?(coder: NSCoder) {
        fatalError()
    }
}
