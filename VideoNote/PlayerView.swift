//
//  PlayerView.swift
//  VideoNote
//
//  Created by 周伟克 on 2020/11/11.
//

import UIKit
import AVKit

/**
 * 需要监听: rate, status, bound
 *
 */

class PlayerView: UIView {
    
    private(set) var currentUrl: URL?
    
    var played = 0
    var duration = 0
    var itemStatus = AVPlayerItem.Status.unknown
    var controlStatus = AVPlayer.TimeControlStatus.waitingToPlayAtSpecifiedRate

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
        currentUrl = url
        if let player = player {
            pause()
            player.currentItem?.removeObserver(self, forKeyPath: "status")
        } else {
            initPlayer()
        }
        let playerItem = AVPlayerItem(url: url)
        playerItem.addObserver(self, forKeyPath: "status", options: .new, context: nil)
        playerItem.addObserver(self, forKeyPath: "duration", options: .new, context: nil)
        player!.replaceCurrentItem(with: playerItem)
        resume()
    }
    
    
    func initPlayer() {
        player = AVPlayer()
//        player!.isMuted = true
        if #available(iOS 12.0, *) {
            player!.preventsDisplaySleepDuringVideoPlayback = true
        } else {
            // Fallback on earlier versions
        }
        // 尝试弱引用是不是就可以及时释放，是否弱引用之后还需要removeTimeObserve
        player?.addPeriodicTimeObserver(forInterval: CMTime(value: 1, timescale: 1), queue: .main, using: { (time) in
            self.played = Int(time.seconds)
            self.didPlay()
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
    
    func didGetDuration() {}
    
    
    func controlStatusDidChange() {}
    
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        // 监听的处理
        if superview != nil {
//            player.removeObserver(<#T##observer: NSObject##NSObject#>, forKeyPath: <#T##String#>)
        }
    }
    
    
    func timeStrOf(_ seconds: Int) -> String {
        var str = ""
        let mins = seconds / 60
        str += mins < 10 ? "0\(mins)" : "\(mins)"
        
        str += ":"
        
        let secs = seconds % 60
        str += secs < 10 ? "0\(secs)" : "\(secs)"
        return str
    }

        
    deinit {
        print("player deinit")
    }
}
