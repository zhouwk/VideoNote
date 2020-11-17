//
//  FullPlayerView.swift
//  VideoNote
//
//  Created by 周伟克 on 2020/11/12.
//

import UIKit
import SnapKit


// notification 不移除后果如何
// kvo 在iOS11+ 可以不用移除
// 自定义kvo https://www.ctolib.com/yhangeline-YHKVOController.html

// 在iPhone 6s: 横屏top bar的高度 增加了状态栏高度

// 需要确定在iOS？开始横屏默认不显示状态栏

// 使用dispathworkItem 隐藏bars

//https://www.jianshu.com/p/555cc5b88f6b?_t=1513858823

class FullPlayerView: PlayerView {
    
    
    var title: String?
    
    lazy var topBar = addControlBar()
    lazy var bottomBar = addControlBar()

    
    
    var isControlShowing = false
    
    
    lazy var popBtn: UIButton = {
        let popBtn = UIButton(type: .custom)
        popBtn.setImage(UIImage(named: "back_white"), for: .normal)
        popBtn.frame.size = CGSize(width: 44, height: 44)
        popBtn.addTarget(self, action: #selector(popBtnDidClick(_:)), for: .touchUpInside)
        topBar.addSubview(popBtn)
        return popBtn
    }()
    
    
    lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.font = .boldSystemFont(ofSize: 14)
        titleLabel.textColor = .white
        topBar.addSubview(titleLabel)
        return titleLabel
    }()
    
    lazy var playBtn: UIButton = {
        let playBtn = UIButton(type: .custom)
        playBtn.addTarget(self, action: #selector(playBtnDidClick(_:)), for: .touchUpInside)
        playBtn.setImage(UIImage(named: "movie_play"), for: .normal)
        playBtn.setImage(UIImage(named: "movie_pause"), for: .selected)
        playBtn.frame.size = CGSize(width: 30, height: 30)
        bottomBar.addSubview(playBtn)
        return playBtn
    }()
    
    
    lazy var orientationBtn: UIButton = {
        let orientationBtn = UIButton(type: .custom)
        orientationBtn.addTarget(self, action: #selector(orientationBtnDidClick(_:)),
                                 for: .touchUpInside)
        orientationBtn.setImage(UIImage(named: "orientation"), for: .normal)
        orientationBtn.frame.size = CGSize(width: 30, height: 30)
        bottomBar.addSubview(orientationBtn)
        return orientationBtn
    }()
    
    
    lazy var durationLabel: UILabel = {
        let durationLabel = UILabel()
        durationLabel.font = .systemFont(ofSize: 14)
        durationLabel.textColor = .white
        durationLabel.text = "00:00"
        bottomBar.addSubview(durationLabel)
        return durationLabel
    }()
    
    
    lazy var progressView: LinearProgressView = {
        let progressView = LinearProgressView()
        progressView.frame.size.height = 2
        bottomBar.addSubview(progressView)
        return progressView
    }()
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isControlShowing {
            hideControls()
        } else {
            showControls()
        }
        isControlShowing = !isControlShowing
    }
    func showControls() {
        
        // topBar 刘海屏 & 垂直 才可以44， 其他都是64
        // bottomBar 固定高度 + safeArea.bottom
        
        clipsToBounds = true
                
        topBar.frame.size.width = frame.width
        bottomBar.frame.size.width = frame.width
        
        topBar.frame.size.height = IsIphoneX && IsPorital ? 44 : 64
        bottomBar.frame.size.height = 50
        if #available(iOS 11.0, *) {
            bottomBar.frame.size.height += safeAreaInsets.bottom
        }
    
        topBar.frame.origin.y = -topBar.frame.size.height
        bottomBar.frame.origin.y = frame.size.height
        
        if IsPorital {
            popBtn.frame.origin.y = IsIphoneX ? 0 : 20
            
            playBtn.frame.origin.x = 10
            playBtn.center.y = bottomBar.frame.height * 0.5
            
            orientationBtn.frame.origin.x = bottomBar.frame.width - orientationBtn.frame.width - 10
            
            durationLabel.sizeToFit()
            durationLabel.frame.origin.x = orientationBtn.frame.origin.x - durationLabel.frame.width - 10
            
            progressView.frame.origin.x = playBtn.frame.maxX + 10
            progressView.frame.size.width = durationLabel.frame.origin.x - progressView.frame.origin.x - 10
            progressView.center.y = playBtn.center.y
            
        } else {
            popBtn.frame.origin.y = 20
            progressView.frame.origin = CGPoint(x: 0, y: 5)
            progressView.frame.size.width = frame.width
            
            playBtn.frame.origin.x = 10
            playBtn.center.y = progressView.frame.maxY + 20
            
            
            durationLabel.sizeToFit()
            durationLabel.frame.origin.x = playBtn.frame.maxX + 10
            orientationBtn.frame.origin.x = frame.width - orientationBtn.frame.width - 10
        }
        
        titleLabel.frame.origin.x = popBtn.frame.maxX
        titleLabel.frame.size.width = topBar.frame.width - titleLabel.frame.origin.x
        titleLabel.frame.size.height = popBtn.frame.height
        titleLabel.text = title
        titleLabel.center.y = popBtn.center.y
        
        durationLabel.center.y = playBtn.center.y
        orientationBtn.center.y = playBtn.center.y

        
        topBar.isHidden = false
        bottomBar.isHidden = false
        UIView.animate(withDuration: 0.25) {
            self.topBar.frame.origin.y = 0
            self.bottomBar.frame.origin.y = self.frame.height - self.bottomBar.frame.height
        }
    }
    
    
    override func didGetDuration() {
        durationLabel.text = timeStrOf(played) + "/" + timeStrOf(duration)
        durationLabel.sizeToFit()
    }
    
    override func didPlay() {
        durationLabel.text = timeStrOf(played) + "/" + timeStrOf(duration)
    }
    
    
    func timeLabelDidChange() {
        guard isControlShowing else {
            return
        }
        durationLabel.sizeToFit()
        
    }
    
    
    @objc func playBtnDidClick(_ sender: UIButton) {
        
    }
    
    @objc func orientationBtnDidClick(_ sender: UIButton) {
        let orientation: UIDeviceOrientation = IsPorital ? .landscapeLeft : . portrait
        UIDevice.current.setValue(orientation.rawValue, forKey: "orientation")
    }
    
    
    @objc func popBtnDidClick(_ sender: UIButton) {
        if IsPorital {
            // 执行pop
        } else {
            let porital = UIDeviceOrientation.portrait.rawValue
            UIDevice.current.setValue(porital, forKey: "orientation")
        }
    }
    
    func hideControls() {
        UIView.animate(withDuration: 0.25) {
            self.topBar.frame.origin.y = -self.topBar.frame.height
            self.bottomBar.frame.origin.y = self.frame.height
        }
    }
    
    
    func addControlBar() -> UIView {
        let bar = UIView()
        bar.backgroundColor = UIColor.black.withAlphaComponent(0.1)
        addSubview(bar)
        return bar
    }
    
    
    
    override func removeFromSuperview() {
        super.removeFromSuperview()
        NotificationCenter.default.removeObserver(self)
    }
    
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        if superview != nil {
            observeOrientation()
        }
    }

    var currentOrientation = UIDevice.current.orientation
}

extension FullPlayerView {
    
    func observeOrientation() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(orientationDidChange(_:)),
                                               name: UIDevice.orientationDidChangeNotification,
                                               object: nil)
    }
    
    @objc func orientationDidChange(_ notification: Notification) {
        let orientation = UIDevice.current.orientation
        if currentOrientation == orientation {
            return
        }
        if orientation.isPortrait || orientation.isLandscape {
            topBar.isHidden = true
            bottomBar.isHidden = true
            isControlShowing = false
            currentOrientation = orientation
        }
    }
}





class LinearProgressView: UIView {
    var progress: Float = 0.5 {
        didSet {
            if progress > 1 {
                progress = 1
            } else if progress < 0 {
                progress = 0
            }
            layoutUI()
        }
    }
    
    
    let progressLayer = CALayer()
    
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
        progressLayer.contents = UIColor.orange.cgColor
        layer.addSublayer(progressLayer)
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutUI()
    }
    
    func layoutUI() {
        layer.cornerRadius = frame.height * 0.5
        progressLayer.frame = CGRect(x: 0, y: 0,
                                     width: CGFloat(progress) * frame.width,
                                     height: frame.height)
        progressLayer.cornerRadius = frame.height * 0.5
        
    }
}
