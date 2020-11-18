//
//  LinearProgressView.swift
//  VideoNote
//
//  Created by 周伟克 on 2020/11/18.
//

import UIKit

class LinearProgressView: UIView {
    var progress: Float = 0 {
        didSet {
            if progress > 1 {
                progress = 1
            } else if progress < 0 {
                progress = 0
            }
            layoutUI()
        }
    }
    
    
    override var frame: CGRect {
        didSet {
            super.frame.size.height = 6
        }
    }
    
    
    
    let progressLayer = CALayer()
    let ballLayer = CALayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initUI()
    }
    
    func initUI() {
        
        backgroundColor = UIColor.white.withAlphaComponent(0.2)
        
        progressLayer.backgroundColor = UIColor.orange.cgColor
        layer.addSublayer(progressLayer)
        
        
        ballLayer.backgroundColor = UIColor.white.cgColor
        layer.addSublayer(ballLayer)

    }
    
    
    
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutUI()
    }
    
    func layoutUI() {
        layer.cornerRadius = frame.height * 0.5
        
        
        let ballSize = frame.height + 4
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        ballLayer.frame = CGRect(x: frame.size.width * CGFloat(progress) - ballSize * 0.5,
                                 y: (frame.height - ballSize) * 0.5,
                                 width: ballSize,
                                 height: ballSize)
        
        progressLayer.frame = CGRect(x: 0, y: 0,
                                     width: ballLayer.position.x,
                                     height: frame.height)
        CATransaction.commit()
        
        ballLayer.cornerRadius = ballSize * 0.5
        progressLayer.cornerRadius = frame.height * 0.5
        
        
        
    }
}

