//
//  AppViewController.swift
//  VideoNote
//
//  Created by 周伟克 on 2020/11/12.
//

import UIKit

class AppViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    override var shouldAutorotate: Bool {
        false
    }
    
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
         .portrait
    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        .portrait
    }

    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
