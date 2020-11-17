//
//  AppNavigationController.swift
//  VideoNote
//
//  Created by 周伟克 on 2020/11/12.
//

import UIKit

class AppNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    
    override var shouldAutorotate: Bool {
        topViewController?.shouldAutorotate ?? false
    }
    
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        topViewController?.supportedInterfaceOrientations ?? .portrait
    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
         topViewController?.preferredInterfaceOrientationForPresentation ?? .portrait
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        topViewController?.preferredStatusBarStyle ?? .default
    }
}
