//
//  RDVFirstViewController.swift
//  RDVTabBarController-Swift
//
//  Created by wuweixin on 2019/7/17.
//  Copyright © 2019 cn.wessonwu. All rights reserved.
//

import UIKit
import MTDNavigationView

class FirstViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "First"
        
        self.mm_tabBarItem?.badgeValue = "3"
        self.extendedLayoutIncludesOpaqueBars = true
        self.edgesForExtendedLayout = [.bottom]
        
        self.mtd.navigationView.backButton.isHidden = true
        
        
//        if let tabBarController = self.rdv_tabBarController, tabBarController.tabBar.isTranslucent {
//            let tabBar = tabBarController.tabBar
//            let insets = UIEdgeInsets(top: 0,
//                                      left: 0,
//                                      bottom: tabBar.frame.height,
//                                      right: 0)
//
//            self.tableView.contentInset = insets;
//            self.tableView.scrollIndicatorInsets = insets
//        }
    }
    
    
    func configureCell(_ cell: UITableViewCell, for indexPath: IndexPath) {
        cell.textLabel?.text = "\(title ?? "") Controller Cell \(indexPath.row)"
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 30
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reuseIdentifier = "Cell"
        
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) ?? UITableViewCell(style: .default, reuseIdentifier: reuseIdentifier)
        configureCell(cell, for: indexPath)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.mm_tabBarItem?.badgeValue = (indexPath.row + 1).description
    }
}

extension FirstViewController: MMToolBarDisplayble, MMTabBarDisplayble {}
