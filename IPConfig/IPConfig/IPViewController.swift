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
    var text: String? { get }
}

class IPViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textView: UITextView!
    
    var items: [IPItem] = []
    var fetcher: IPFetcher?
    
    class func newInstanceWithFetcher(_ fetcher: IPFetcher) -> IPViewController {
        let sb = UIStoryboard(name: "Main", bundle: Bundle.main)
        let vc = sb.instantiateInitialViewController() as! IPViewController
        vc.fetcher = fetcher
        return vc
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = fetcher?.title
        reloadData()
    }
    
    
    @IBAction func reloadData() {
        if let items = fetcher?.fetch() {
            self.items = items
            self.textView.text = fetcher?.text
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
