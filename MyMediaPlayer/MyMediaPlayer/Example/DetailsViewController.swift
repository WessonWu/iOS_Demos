//
//  RDVDetailsViewController.swift
//  RDVTabBarController-Swift
//
//  Created by wuweixin on 2019/7/17.
//  Copyright © 2019 cn.wessonwu. All rights reserved.
//

import UIKit

struct HiddenData {
    let isSongViewHidden: Bool
    let isTabBarHidden: Bool
    let navigationBarHidden: Bool
}

class DetailsViewController: UIViewController {
    
    @IBOutlet weak var tabBarHiddenSwitch: UISwitch!
    @IBOutlet weak var songViewHiddenSwitch: UISwitch!
    @IBOutlet weak var navigationBarHidden: UISwitch!
    
    
    class func newInstance(data: HiddenData = HiddenData(isSongViewHidden: false, isTabBarHidden: true, navigationBarHidden: true)) -> DetailsViewController {
        let sb = UIStoryboard(name: "DetailsSB", bundle: Bundle.main)
        let vc = sb.instantiateInitialViewController() as! DetailsViewController
        vc.data = data
        return vc
    }
    

    var data: HiddenData = HiddenData(isSongViewHidden: false, isTabBarHidden: true, navigationBarHidden: false)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        songViewHiddenSwitch.isOn = data.isSongViewHidden
        tabBarHiddenSwitch.isOn = data.isTabBarHidden
        navigationBarHidden.isOn = data.navigationBarHidden
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
        self.navigationController?.setNavigationBarHidden(data.navigationBarHidden, animated: animated)
        self.mm_tabBarController?.setBottomBarHidden(isSongViewHidden: data.isSongViewHidden, isTabBarHidden: data.isTabBarHidden, animated: animated)
    }
    
    
    @IBAction func goToNext(_ sender: Any) {
        let vc = DetailsViewController.newInstance(data: HiddenData(isSongViewHidden: songViewHiddenSwitch.isOn, isTabBarHidden: tabBarHiddenSwitch.isOn, navigationBarHidden: navigationBarHidden.isOn))
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}
