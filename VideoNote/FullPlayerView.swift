//
//  FullPlayerView.swift
//  VideoNote
//
//  Created by 周伟克 on 2020/11/12.
//

import UIKit
import SnapKit
import MediaPlayer


// notification 不移除后果如何
// kvo 在iOS11+ 可以不用移除
// 自定义kvo https://www.ctolib.com/yhangeline-YHKVOController.html

// 在iPhone 6s: 横屏top bar的高度 增加了状态栏高度

// 需要确定在iOS？开始横屏默认不显示状态栏

// 使用dispathworkItem 隐藏bars

//https://www.jianshu.com/p/555cc5b88f6b?_t=1513858823

class FullPlayerView: PlayerView {
    
    
    enum FingerEventMode {
        case none, volume, progress, brightness
    }
    
    var eventModel = FingerEventMode.none
    
    
    var startLoc = CGPoint.zero

    
    var title: String?
    lazy var topBar = addControlBar()
    lazy var bottomBar = addControlBar()
    var isControlShowing = false
    
    var requestLockOrientation: (() -> ())?
    var requestUnLockOrientation: (() -> ())?
    
    
    var progressWhenGragging = Float(0)
    
    
    lazy var volumeSlider: UISlider = {
        let volumeView = MPVolumeView()
        volumeView.showsVolumeSlider = false
        volumeView.showsRouteButton = false
        addSubview(volumeView)
        return volumeView.subviews.first { $0 is UISlider } as! UISlider
    }()

    
    lazy var panGesture: UIPanGestureRecognizer = {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        pan.isEnabled = false
        addGestureRecognizer(pan)
        return pan
    }()
    
    
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
        bottomBar.addSubview(progressView)
        return progressView
    }()
    
    
    var rateBtn: UIButton?
    
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
                        
        topBar.frame.size.width = frame.width
        topBar.frame.size.height = IsIphoneX && IsPorital ? 44 : 64
        
        bottomBar.frame.size.width = frame.width
        bottomBar.frame.size.height = 50
        if #available(iOS 11.0, *) {
            bottomBar.frame.size.height += safeAreaInsets.bottom
        }
        bottomBar.frame.origin.y = frame.size.height - bottomBar.frame.height
        
        
        layoutTopBarContents()
        layoutBottomBarContents()
        
        topBar.alpha = 0
        bottomBar.alpha = 0
        UIView.animate(withDuration: 0.25) {
            self.topBar.alpha = 1
            self.bottomBar.alpha = 1
        }
    }
    
    func layoutTopBarContents() {
        popBtn.frame.origin.y = IsPorital && !IsIphoneX ? 20 : 0
        titleLabel.frame.origin.x = popBtn.frame.maxX
        titleLabel.frame.size.width = topBar.frame.width - titleLabel.frame.origin.x
        titleLabel.frame.size.height = popBtn.frame.height
        titleLabel.text = title
        titleLabel.center.y = popBtn.center.y
    }
    
    func layoutBottomBarContents() {
        if IsPorital {
            playBtn.frame.origin.x = 10
            playBtn.center.y = bottomBar.frame.height * 0.5
            
            orientationBtn.frame.origin.x = bottomBar.frame.width - orientationBtn.frame.width - 10
            
            durationLabel.sizeToFit()
            durationLabel.frame.origin.x = orientationBtn.frame.origin.x - durationLabel.frame.width - 10
            
            progressView.frame.origin.x = playBtn.frame.maxX + 10
            progressView.frame.size.width = durationLabel.frame.origin.x - progressView.frame.origin.x - 10
            progressView.center.y = playBtn.center.y
            
            
            rateBtn?.isHidden = true
            
        } else {
            progressView.frame.origin = CGPoint(x: 10, y: 5)
            progressView.frame.size.width = frame.width - progressView.frame.origin.x * 2
            
            playBtn.frame.origin.x = 10
            playBtn.center.y = progressView.frame.maxY + 20
            
            
            durationLabel.sizeToFit()
            durationLabel.frame.origin.x = playBtn.frame.maxX + 10
            
            orientationBtn.frame.origin.x = frame.width - orientationBtn.frame.width - 10
            
            createRateBtnIfNeeded()
            rateBtn?.isHidden = false
            rateBtn?.frame.origin.x = orientationBtn.frame.origin.x - rateBtn!.frame.width - 20
            rateBtn?.center.y = playBtn.center.y
            
        }
        durationLabel.center.y = playBtn.center.y
        orientationBtn.center.y = playBtn.center.y
    }
    
    
    
    func createRateBtnIfNeeded() {
        guard rateBtn == nil else {
            return
        }
        rateBtn = UIButton(type: .custom)
        rateBtn!.setTitle("倍速", for: .normal)
        rateBtn!.titleLabel?.font = .systemFont(ofSize: 14)
        rateBtn!.addTarget(self, action: #selector(rateBtnDidClick(_:)), for: .touchUpInside)
        rateBtn!.sizeToFit()
        bottomBar.addSubview(rateBtn!)
    }
    
    
    
    
    override func didGetDuration() {
        guard isControlShowing else {
            return
        }
        durationLabel.text = timeStrOf(played) + "/" + timeStrOf(duration)
        layoutBottomBarContents()
    }
    
    override func didPlay() {
        guard isControlShowing, eventModel != .progress else {
            return
        }
        durationLabel.text = timeStrOf(played) + "/" + timeStrOf(duration)
        if duration != 0 {
            progressView.progress = Float(played) / Float(duration)
        }
        layoutBottomBarContents()
    }
    
    @objc func playBtnDidClick(_ sender: UIButton) {
        if sender.isSelected {
            pause()
        } else {
            resume()
        }
    }
    
    @objc func rateBtnDidClick(_ sender: UIButton) {
        weak var ws = self
        requestLockOrientation?()
        let rateView = RateView(frame: bounds, current: player?.rate) { (rate) in
            ws?.player?.rate = rate
            sender.setTitle("\(rate)X", for: .normal)
            ws?.layoutBottomBarContents()
        } onRemoved: {
            ws?.requestUnLockOrientation?()
        }
        addSubview(rateView)
    }
    
    
    override func controlStatusDidChange() {
        playBtn.isSelected = controlStatus == .playing
    }
    
    override func itemStatusDidChange() {
        panGesture.isEnabled = itemStatus == .readyToPlay
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
    
    @objc func handlePanGesture(_ pan: UIPanGestureRecognizer) {
        let translation = pan.translation(in: pan.view)
        switch pan.state {
        case .began:
            eventModel = .none
            startLoc = pan.location(in: pan.view)
        case .changed:
            if eventModel == .none {
                if abs(translation.x) > 10 {
                    eventModel = .progress
                    progressWhenGragging = Float(played) / Float(duration)
                } else if abs(translation.y) > 10 {
                    if startLoc.x < pan.view!.frame.width * 0.5 {
                        eventModel = .brightness
                    } else {
                        eventModel = .volume
                    }
                } else {
                    return
                }
            }
            if eventModel == .progress {
                let deltaX = translation.x / pan.view!.frame.width
                if isControlShowing {
                    progressView.progress += Float(deltaX)
                }
            } else {
                let deltaY = translation.y / pan.view!.frame.height
                if eventModel == .brightness {
                    UIScreen.main.brightness -= deltaY
                } else {
                    let volume = volumeSlider.value - Float(deltaY)
                    volumeSlider.setValue(volume, animated: true)
                }
            }
            pan.setTranslation(.zero, in: self)
        default:
            
            if eventModel == .progress {
                let time = CMTime(value: Int64(progressView.progress * Float(duration)),
                                  timescale: 1)
                player?.seek(to: time, completionHandler: { (_) in
                    self.eventModel = .none
                })
            } else {
                self.eventModel = .none
            }
        }
    }
    
    func hideControls() {
        UIView.animate(withDuration: 0.25) {
            self.topBar.alpha = 0
            self.bottomBar.alpha = 0
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
            topBar.alpha = 0
            bottomBar.alpha = 0
            isControlShowing = false
            currentOrientation = orientation
        }
    }
}
