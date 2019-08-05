//
//  TranslucentTableViewController.swift
//  MTDNavigationViewDemo
//
//  Created by wuweixin on 2019/8/3.
//  Copyright © 2019 wuweixin. All rights reserved.
//

import UIKit

class TranslucentTableViewController: UITableViewController {
    @IBOutlet weak var translucentSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        let mtd_self = self.mtd
        self.title = "Translucent"
        
        let navigationView = mtd_self.navigationView
        navigationView.isTranslucent = true
        navigationView.titleLabel.textColor = UIColor.orange
        navigationView.backButton.tintColor = UIColor.orange
        navigationView.backgroundColor = UIColor.blue.withAlphaComponent(0)
        
        translucentSwitch.isOn = navigationView.isTranslucent
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 30
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        // Configure the cell...
        cell.textLabel?.text = "Row: \(indexPath.row)"
        return cell
    }

    @IBAction func translucentValueChanged(_ sender: UISwitch) {
        self.mtd.navigationView.isTranslucent = sender.isOn
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        var offsetY = scrollView.contentOffset.y
        if #available(iOS 11.0, *) {
            offsetY += scrollView.adjustedContentInset.top
        }
        let alpha: CGFloat = min(max(0, (offsetY / 64)), 1)
        self.mtd.navigationView.backgroundColor = UIColor.blue.withAlphaComponent(alpha)
    }
}
