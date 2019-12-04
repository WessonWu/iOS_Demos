//
//  ViewController.swift
//  DrawSeparator
//
//  Created by wuweixin on 2019/12/4.
//  Copyright © 2019 wuweixin. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }


}


extension ViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TypeOne", for: indexPath) as! TypeOneTableViewCell
            cell.contentLabel.text = indexPath.item.description
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TypeTwo", for: indexPath) as! TypeTwoTableViewCell
        cell.contentLabel.text = indexPath.item.description
        return cell
    }
}

