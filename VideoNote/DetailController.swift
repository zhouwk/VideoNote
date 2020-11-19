//
//  DetailController.swift
//  VideoNote
//
//  Created by 周伟克 on 2020/11/12.
//

import UIKit

// 通过xib创建控制器，viewDidLoad 的时候frame 依然是xib中大小，而不是实际大小

class DetailController: UIViewController {
    
    
    var video: VideoViewModel!
    
    @IBOutlet weak var playerView: FullPlayerView!
    @IBOutlet weak var playerTop: NSLayoutConstraint!
    @IBOutlet weak var playerHeight: NSLayoutConstraint!
    
    
    var didDeinit: (() -> ())?
    
    var orientationLocked = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        adjustLayouts()
        observeOrientation()
        
        playerView.title = video.name
        playerView.playUrl(video.url)
        
        playerView.requestLockOrientation = { [ weak self] in
            self?.orientationLocked = true
        }
        playerView.requestUnLockOrientation = { [weak self] in
            self?.orientationLocked = false
        }
        
    }
    
//    override var shouldAutorotate: Bool {
//        !orientationLocked
//    }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        orientationLocked ? .landscape : [.landscape, .portrait]
    }
    
    func adjustLayouts() {
        playerTop.constant = IsIphoneX && IsPorital ? 44 : 0
        playerHeight.constant = IsPorital ? KeyWindow!.frame.width * 9 / 16 : KeyWindow!.frame.height
        view.layoutIfNeeded()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    
    deinit {
        playerView.saveProgress()
        didDeinit?()
    }
}



extension DetailController {
    func observeOrientation() {
        NotificationCenter.default.addObserver(self, selector: #selector(orientationDidChange(_:)), name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    @objc func orientationDidChange(_ notification: Notification) {
        adjustLayouts()
    }
}


