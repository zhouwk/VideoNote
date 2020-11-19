//
//  PiePanel.swift
//  VideoNote
//
//  Created by 周伟克 on 2020/11/19.
//


import UIKit

class PiePanel: UIView {
    
    var progress: Float = 0 {
        didSet {
            progress = min(max(0, progress), 1)
            setNeedsDisplay()
        }
    }
    override func draw(_ rect: CGRect) {
        
        let selfCenter = CGPoint(x: frame.width * 0.5, y: frame.height * 0.5)
        let radius = min(rect.width, rect.height) * 0.5
        let ctx = UIGraphicsGetCurrentContext()
    
        ctx?.move(to: selfCenter)
        let start = -CGFloat.pi * 0.5
        let end = start + CGFloat(progress) * CGFloat.pi * 2
        ctx?.addArc(center: selfCenter,
                    radius: radius,
                    startAngle: start,
                    endAngle: end,
                    clockwise: false)
        ctx?.closePath()
        ctx?.setFillColor(UIColor.green.cgColor)
        ctx?.fillPath()
        
        
        ctx?.addArc(center: selfCenter, radius: radius - 1, startAngle: 0, endAngle: CGFloat.pi * 2, clockwise: true)
        ctx?.setLineWidth(2)
        ctx?.setStrokeColor(UIColor.green.cgColor)
        ctx?.strokePath()
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        backgroundColor = .clear
    }
}
