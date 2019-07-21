//
//  RDVDetailsViewController.swift
//  RDVTabBarController-Swift
//
//  Created by wuweixin on 2019/7/17.
//  Copyright © 2019 cn.wessonwu. All rights reserved.
//

import UIKit

struct Properties {
    let preferredNavigationHidden: Bool
    let preferredToolBarHidden: Bool
    let preferredTabBarHidden: Bool
}

class DetailsViewController: UITableViewController {
    
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
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(properties.preferredNavigationHidden, animated: animated)
    }
    
    
    @IBAction func goToNext(_ sender: Any) {
        let properties = Properties(preferredNavigationHidden: navigationHiddenSwitch.isOn,
                                    preferredToolBarHidden: toolBarHiddenSwitch.isOn,
                                    preferredTabBarHidden: tabBarHiddenSwitch.isOn)
        let vc = DetailsViewController.newInstance(properties: properties)
        self.navigationController?.pushViewController(vc, animated: true)
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

