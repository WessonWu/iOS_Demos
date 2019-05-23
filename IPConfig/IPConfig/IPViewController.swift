//
//  IPViewController.swift
//  IPConfig
//
//  Created by wuweixin on 2019/5/23.
//  Copyright © 2019 cn.wessonwu. All rights reserved.
//

import UIKit

protocol IPFetcher {
    var title: String? { get }
    func fetch() -> [IPItem]
}

class IPViewController: UIViewController {
    
    lazy var tableView: UITableView = UITableView(frame: UIScreen.main.bounds, style: .plain)
    var items: [IPItem] = []
    var fetcher: IPFetcher?
    
    convenience init(fetcher: IPFetcher) {
        self.init()
        self.fetcher = fetcher
    }
    
    override func loadView() {
        super.loadView()
        self.view.backgroundColor = UIColor.groupTableViewBackground
        tableView.backgroundColor = UIColor.groupTableViewBackground
        tableView.frame = self.view.bounds
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.addSubview(tableView)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = fetcher?.title
        tableView.dataSource = self
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh,
                                                                 target: self,
                                                                 action: #selector(reloadData))
        reloadData()
    }
    
    
    @objc
    private func reloadData() {
        if let items = fetcher?.fetch() {
            self.items = items
            self.tableView.reloadData()
        }
    }
}

extension IPViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") ?? UITableViewCell(style: .value1, reuseIdentifier: "Cell")
        let item = self.items[indexPath.row]
        cell.textLabel?.text = item.title
        cell.detailTextLabel?.text = item.detail
        return cell
    }
}
