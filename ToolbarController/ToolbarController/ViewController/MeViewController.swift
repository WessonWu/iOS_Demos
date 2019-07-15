//
//  MeViewController.swift
//  ToolbarController
//
//  Created by wuweixin on 2019/7/11.
//  Copyright © 2019 cn.wessonwu. All rights reserved.
//

import UIKit

class MeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    @IBAction func toggleTabbar(_ sender: Any) {
        guard let tabBarVC = self.tabBarController else {
            return
        }
        tabBarVC.setTabBarHidden(!tabBarVC.tabBar.isHidden, animated: true)
    }
    
    @available(iOS 11.0, *)
    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        print(#function, self.view.safeAreaInsets)
    }
    
    @IBAction func pushAudioController(_ sender: Any) {
        let audioVC = AudioPlayerViewController()
        self.navigationController?.delegate = audioVC
        self.navigationController?.pushViewController(audioVC, animated: true)
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
