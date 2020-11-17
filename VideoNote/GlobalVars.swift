//
//  GlobalVars.swift
//  VideoNote
//
//  Created by 周伟克 on 2020/11/12.
//

import Foundation
import UIKit


var KeyWindow = UIApplication.shared.keyWindow


var IsIphoneX: Bool {
    if #available(iOS 11.0, *) {
        return KeyWindow!.safeAreaInsets.bottom != 0
    }
    return false
}


var IsPorital: Bool {
    KeyWindow!.frame.width < KeyWindow!.frame.height
}



