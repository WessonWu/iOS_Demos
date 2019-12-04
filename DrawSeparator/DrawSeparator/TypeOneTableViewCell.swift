//
//  TypeOneTableViewCell.swift
//  DrawSeparator
//
//  Created by wuweixin on 2019/12/4.
//  Copyright © 2019 wuweixin. All rights reserved.
//

import UIKit

class TypeOneTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    
    lazy var borderView = BorderView()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
//        titleLabel.layer.masksToBounds = true
//        contentLabel.layer.masksToBounds = true
        borderView.frame = self.bounds
        borderView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        borderView.borderWidth = 1 / UIScreen.main.scale
        borderView.borderColor = UIColor.red
        borderView.borders = [.bottom]
        contentView.insertSubview(borderView, at: 0)
    }

}
