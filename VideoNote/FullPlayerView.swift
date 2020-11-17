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
    
    var requestLockOrientation: (() -> ())?
    var requestUnLockOrientation: (() -> ())?
    
    
    
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
            progressView.frame.origin = CGPoint(x: 0, y: 5)
            progressView.frame.size.width = frame.width
            
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
        durationLabel.text = timeStrOf(played) + "/" + timeStrOf(duration)
        layoutBottomBarContents()
    }
    
    override func didPlay() {
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
        progressLayer.backgroundColor = UIColor.orange.cgColor
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




class RateView: UIView {
    
    private let rates: [Float] = [0.5, 1, 1.5, 2]
    private let tableView: UITableView
    private var current: Float?
    private let onConfirmed: (Float) -> ()
    private let onRemoved: () -> ()
    private let reuseId = "UITableViewCell"
    
    
    init(frame: CGRect,
         current: Float?,
         onConfirmed: @escaping (Float) -> (),
         onRemoved: @escaping () -> ()) {
        
        self.current = current
        tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        tableView.separatorStyle = .none
        tableView.rowHeight = 50
        defer {
            tableView.delegate = self
            tableView.dataSource = self
            addSubview(tableView)
        }
        self.onConfirmed = onConfirmed
        self.onRemoved = onRemoved
        super.init(frame: frame)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        let loc = touch.location(in: self)
        if !tableView.frame.contains(loc) {
            dismissAnimated()
        }
    }
    
    
    private func showAnimated() {
        tableView.frame = CGRect(x: frame.width, y: 0, width: 150, height: frame.height)
        let insetY = (tableView.frame.height - CGFloat(rates.count) * tableView.rowHeight) * 0.5
        if insetY > 0 {
            tableView.contentInset.top = insetY
        }
        UIView.animate(withDuration: 0.25) {
            self.tableView.frame.origin.x = self.frame.width - self.tableView.frame.width
        } completion: { (_) in
        }
    }
    
    private func dismissAnimated(rate: Float? = nil) {
        UIView.animate(withDuration: 0.25) {
            self.tableView.frame.origin.x = self.frame.width
        } completion: { (_) in
            if let rate = rate {
                self.onConfirmed(rate)
            }
            self.onRemoved()
            self.removeFromSuperview()
        }
    }
    
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        if superview != nil {
            showAnimated()
        }
    }
    
    
    required init?(coder: NSCoder) {
        fatalError()
    }
}
//MARK: UITableViewDelegate, UITableViewDataSource
extension RateView: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rates.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: reuseId) {
            return cell
        }
        let cell = UITableViewCell(style: .default, reuseIdentifier: reuseId)
        cell.textLabel?.font = .boldSystemFont(ofSize: 16)
        cell.textLabel?.frame = cell.contentView.bounds
        cell.backgroundColor = .clear
        cell.textLabel?.textAlignment = .center
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let rate = rates[indexPath.row]
        cell.textLabel?.text = "\(rate)X"
        cell.textLabel?.textColor = rate == current ? .orange : .white
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let rate = rates[indexPath.row]
        if rate == current {
            return
        }
        current = rate
        tableView.reloadData()
        dismissAnimated(rate: rate)
    }
}

