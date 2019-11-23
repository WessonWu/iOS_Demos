//
//  ItemsViewController.swift
//  TestAppStore
//
//  Created by wuweixin on 2019/11/13.
//  Copyright © 2019 wuweixin. All rights reserved.
//

import UIKit

class ItemsViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        IAPService.shared.getProducts()
    }


}

