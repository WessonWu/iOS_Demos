//
//  RDVDetailsViewController.swift
//  RDVTabBarController-Swift
//
//  Created by wuweixin on 2019/7/17.
//  Copyright © 2019 cn.wessonwu. All rights reserved.
//

import UIKit
import MTDNavigationView

struct Properties {
    let preferredNavigationHidden: Bool
    let preferredToolBarHidden: Bool
    let preferredTabBarHidden: Bool
}

class DetailsViewController: CompatibleTableViewController {
    
    @IBOutlet weak var navigationHiddenSwitch: UISwitch!
    @IBOutlet weak var toolBarHiddenSwitch: UISwitch!
    @IBOutlet weak var tabBarHiddenSwitch: UISwitch!
    
    
    class func newInstance(properties: Properties = Properties(preferredNavigationHidden: false,
                                                               preferredToolBarHidden: false,
                                                               preferredTabBarHidden: false)) -> DetailsViewController {
        let sb = UIStoryboard(name: "DetailsSB", bundle: Bundle.main)
        let vc = sb.instantiateInitialViewController() as! DetailsViewController
        vc.properties = properties
        return vc
    }
    

    var properties: Properties = Properties(preferredNavigationHidden: false,
                                            preferredToolBarHidden: false,
                                            preferredTabBarHidden: false)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Hello"

        // Do any additional setup after loading the view.
        navigationHiddenSwitch.isOn = properties.preferredNavigationHidden
        toolBarHiddenSwitch.isOn = properties.preferredToolBarHidden
        tabBarHiddenSwitch.isOn = properties.preferredTabBarHidden
        
        self.mtd.navigationView.isHidden = properties.preferredNavigationHidden
        self.mtd.disableInteractivePop = false
        
        let navigationView = self.mtd.navigationView
        navigationView.backButton.isHidden = true
        navigationView.leftNavigationItemViews = [MTDImageItemView(image: #imageLiteral(resourceName: "nav_share_ic"), target: self, action: #selector(onShare)),
                                                  MTDImageItemView(image: #imageLiteral(resourceName: "nav_share_ic"), target: self, action: #selector(onShare))]
        navigationView.rightNavigationItemViews = [MTDImageItemView(image: #imageLiteral(resourceName: "nav_share_ic"), target: self, action: #selector(onShare)),
                                                   MTDTitleItemView(title: "Next", target: self, action: #selector(goToNext(_:)))]
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    @IBAction func goToNext(_ sender: Any) {
        let properties = Properties(preferredNavigationHidden: navigationHiddenSwitch.isOn,
                                    preferredToolBarHidden: toolBarHiddenSwitch.isOn,
                                    preferredTabBarHidden: tabBarHiddenSwitch.isOn)
        let vc = DetailsViewController.newInstance(properties: properties)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func onShare() {
        self.title = "Detail" + arc4random_uniform(100).description
    }
    
    
    @IBAction func presentMediaPlayer(_ sender: Any) {
        
//        self.present(MyMediaPlayerViewController.newInstance(), animated: true, completion: nil)
        self.present(AudioPlayerController.shared, animated: true, completion: nil)
    }
    
    deinit {
        print(#file, #function)
    }
    
}

extension DetailsViewController: MMToolBarDisplayble, MMTabBarDisplayble {
    var preferredToolBarHidden: Bool {
        return properties.preferredToolBarHidden
    }
    
    var preferredTabBarHidden: Bool {
        return properties.preferredTabBarHidden
    }
}

