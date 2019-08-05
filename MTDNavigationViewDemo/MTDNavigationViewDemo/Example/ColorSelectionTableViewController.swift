//
//  ColorSelectionTableViewController.swift
//  MTDNavigationViewDemo
//
//  Created by wuweixin on 2019/8/5.
//  Copyright © 2019 wuweixin. All rights reserved.
//

import UIKit

struct ColorTuple {
    let title: String
    let color: UIColor
}

class ColorSelectionTableViewController: UITableViewController {
    let colors: [ColorTuple] = [ColorTuple(title: "white", color: UIColor.white),
                                ColorTuple(title: "black", color: UIColor.black),
                                ColorTuple(title: "red", color: UIColor.red),
                                ColorTuple(title: "green", color: UIColor.green),
                                ColorTuple(title: "blue", color: UIColor.blue),
                                ColorTuple(title: "orange", color: UIColor.orange),
                                ColorTuple(title: "cyan", color: UIColor.cyan),
                                ColorTuple(title: "purple", color: UIColor.purple),
                                ColorTuple(title: "brown", color: UIColor.brown),
                                ColorTuple(title: "clear", color: UIColor.clear)]
    
    var selectedColor: ColorTuple? {
        guard let row = tableView.indexPathForSelectedRow?.row else {
            return nil
        }
        
        return colors[row]
    }
    
    var selectionCallback: ((ColorTuple) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return colors.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        // Configure the cell...
        cell.textLabel?.text = colors[indexPath.item].title

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectionCallback?(colors[indexPath.row])
        self.navigationController?.popViewController(animated: true)
    }

}
