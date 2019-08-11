//
//  StickyHeaderViewController.swift
//  StickyHeaderViewDemo
//
//  Created by wuweixin on 2019/8/11.
//  Copyright © 2019 wuweixin. All rights reserved.
//

import UIKit

class StickyHeaderViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var headerView: UIImageView!
    @IBOutlet weak var navigationView: UIView!
    
    lazy var stickyBinder = StickyHeaderViewBinder(contentInsetTopForHeaderView: 160)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let binder = self.stickyBinder
        binder.bind(tableView, headerView: headerView) { [weak self] (percent) in
            guard let navigationView = self?.navigationView else {
                return
            }
            navigationView.backgroundColor = navigationView.backgroundColor?.withAlphaComponent(percent)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        stickyBinder.scrollUpwardEdgeInsetTop = navigationView.frame.height
    }

    
    deinit {
        print(#file, #function)
    }
}

extension StickyHeaderViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 40
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = "Row: \(indexPath.row)"
        return cell
    }
}
