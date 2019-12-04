//
//  TypeTwoTableViewCell.swift
//  DrawSeparator
//
//  Created by wuweixin on 2019/12/4.
//  Copyright © 2019 wuweixin. All rights reserved.
//

import UIKit

class TypeTwoTableViewCell: UITableViewCell, BoundViewType {
    public private(set) lazy var configuration = BoundViewConfiguration(owner: self)
    
    open override class var layerClass: AnyClass {
        return CAShapeLayer.self
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updatePath()
    }
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        configuration.updateItemValues { (values) in
            values.bounds = [.bottom]
            values.lineWidth = 1 / UIScreen.main.scale
            values.strokeColor = UIColor.red
        }
        
        titleLabel.layer.masksToBounds = true
        contentLabel.layer.masksToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
