//
//  RDVSecondViewController.swift
//  RDVTabBarController-Swift
//
//  Created by wuweixin on 2019/7/17.
//  Copyright © 2019 cn.wessonwu. All rights reserved.
//

import UIKit

class SecondViewController: UITableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        self.mtd.navigationView.backButton.isHidden = true
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
        tableView.deselectRow(at: indexPath, animated: true)
        guard let tabBarVC = self.mm_tabBarController else {
            return
        }
        
        let bottomBar = tabBarVC.bottomBar
        tabBarVC.setTabBarHidden(!bottomBar.isTabBarHidden, animated: true)
    }
}

extension SecondViewController: MMToolBarDisplayble, MMTabBarDisplayble {}
