//
//  VideoRecorder.swift
//  VideoNote
//
//  Created by 周伟克 on 2020/11/18.
//

import Foundation

class VideoRecorder {
    static let `default` = VideoRecorder()
    let path = NSSearchPathForDirectoriesInDomains(.documentDirectory,
                                                   .userDomainMask, true)[0] + "/video_record.plist"
    
    
    let finishedKey = "isFinished"
    let playedKey = "played"
    private init() {
        if !FileManager.default.fileExists(atPath: path) {
            NSDictionary().write(toFile: path, atomically: true)
        }
    }
    
    func query(_ key: String) -> (isFinished: Bool, played: Float) {
        guard let info = queueryAll()?[key] else {
            return (false, 0)
        }
        return (info[finishedKey] as? Bool ?? false,
                info[playedKey] as? Float ?? 0)
    }
    
    func set(_ played: Float, for key: String) {
        let played = min(1, max(0, played))
        var all = queueryAll() ?? [:]
        var info = all[key] ?? [:]
        info[playedKey] = played
        if played == 1 {
            info[finishedKey] = true
        }
        all[key] = info
        (all as NSDictionary).write(toFile: path, atomically: true)
    }
    
    func queueryAll() -> [String: [String: Any]]? {
        NSDictionary(contentsOfFile: path) as? [String: [String: Any]]
    }
}
