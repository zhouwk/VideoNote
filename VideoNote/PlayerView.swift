//
//  PlayerView.swift
//  VideoNote
//
//  Created by 周伟克 on 2020/11/11.
//

import UIKit
import AVKit

/**
 * 保存进度时机： 切换URL， deinit ,termiate
 */

class PlayerView: UIView {
    
    private(set) var currentUrl: URL?
    
    var played = 0
    var duration = 0
    var itemStatus = AVPlayerItem.Status.unknown
    var controlStatus = AVPlayer.TimeControlStatus.waitingToPlayAtSpecifiedRate

    var shouldRecordPlayed = true
    
    
    
    var isMuted: Bool = false {
        didSet {
            player?.isMuted = isMuted
        }
    }
    
    
    var timeUnit: CMTime {
        CMTime(value: 1, timescale: 1)
    }
    
    override class var layerClass: AnyClass {
        AVPlayerLayer.self
    }
    
    var player: AVPlayer?
    
    func pause() {
        player?.pause()
    }
    
    func resume() {
        player?.play()
    }
    
    func playUrl(_ url: URL) {
        if url == currentUrl {
            return
        }
        saveProgress()
        currentUrl = url
        if player != nil {
            pause()
            currentItemRemoveKVO()
        } else {
            initPlayer()
        }
        let playerItem = AVPlayerItem(url: url)
        player!.replaceCurrentItem(with: playerItem)
        currentItemAddKVO()
        resume()
    }
    
    
    func seekAndPlay() {
        seekToLatest()
        resume()
    }
    
    
    func seekToLatest() {
        if let fileName = currentUrl?.absoluteString.split(separator: "/").last {
            var ratio = VideoRecorder.default.query(String(fileName)).played
            if ratio == 1 {
                ratio = 0
            }
            let seconds = Int64(Float(duration) * ratio)
            player?.seek(to: CMTime(value: seconds, timescale: 1))
        }
    }
    
    
    func initPlayer() {
        player = AVPlayer()
        player?.isMuted = isMuted
//        player!.isMuted = true
        if #available(iOS 12.0, *) {
            player!.preventsDisplaySleepDuringVideoPlayback = true
        } else {
            // Fallback on earlier versions
        }
        player?.addPeriodicTimeObserver(forInterval: timeUnit,
                                        queue: .main,
                                        using: { [weak self] (time) in
            self?.played = Int(time.seconds)
            self?.didPlay()
        })
        player?.addObserver(self, forKeyPath: "timeControlStatus", options: [.initial, .new], context: nil)
        (layer as! AVPlayerLayer).player = player
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "status" {
            itemStatus = AVPlayerItem.Status(rawValue: change![.newKey] as! Int)!
            itemStatusDidChange()
            if itemStatus == .readyToPlay {
                // player.currentItem!.duration 有可能是 CMTime(0,0)，从而倒是nan
                duration = Int(player!.currentItem!.asset.duration.seconds)
                didGetDuration()
            }
        } else if keyPath == "timeControlStatus" {
            let value = change![.newKey] as! Int
            controlStatus = AVPlayer.TimeControlStatus(rawValue: value)!
            controlStatusDidChange()
        }
    }
    
    
    func didPlay() {}

    /// 播放状态发生改变
    func itemStatusDidChange() {}
    
    func didGetDuration() {
        seekToLatest()
    }
    
    
    func controlStatusDidChange() {}
    
    func timeStrOf(_ seconds: Int) -> String {
        var str = ""
        let mins = seconds / 60
        str += mins < 10 ? "0\(mins)" : "\(mins)"
        
        str += ":"
        
        let secs = seconds % 60
        str += secs < 10 ? "0\(secs)" : "\(secs)"
        return str
    }
    
    
    override func removeFromSuperview() {
        super.removeFromSuperview()
        saveProgress()
    }
    
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        if superview != nil {
            observeAppWillTerminate()
        }
    }
    
    
    func saveProgress() {
        if let url = currentUrl,
           let fileName = url.absoluteString.split(separator: "/").last,
           shouldRecordPlayed,
           itemStatus == .readyToPlay,
           played != 0,
           duration != 0
        {
            VideoRecorder.default.set(Float(played) / Float(duration),
                                      for: String(fileName))
        }
    }

    
    func currentItemRemoveKVO() {
        player?.currentItem?.removeObserver(self, forKeyPath: "status")
        player?.currentItem?.removeObserver(self, forKeyPath: "duration")
    }
    
    func currentItemAddKVO() {
        player?.currentItem?.addObserver(self,
                                         forKeyPath: "status",
                                         options: .new,
                                         context: nil)
        player?.currentItem?.addObserver(self,
                                         forKeyPath: "duration",
                                         options: .new,
                                         context: nil)
    }
        
    deinit {
        currentItemRemoveKVO()
        NotificationCenter.default.removeObserver(self)
    }
}


extension PlayerView {
    func observeAppWillTerminate() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(appWillTerminate(_:)),
                                               name: UIApplication.willTerminateNotification,
                                               object: nil)
    }
    
    @objc func appWillTerminate(_ notification: Notification) {
        saveProgress()
    }
}
