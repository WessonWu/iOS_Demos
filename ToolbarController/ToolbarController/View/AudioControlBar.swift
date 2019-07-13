//
//  AudioControlBar.swift
//  ToolbarController
//
//  Created by wuweixin on 2019/7/11.
//  Copyright © 2019 cn.wessonwu. All rights reserved.
//

import UIKit

class AudioControlBar: UIControl {
    
    static let shared = AudioControlBar()
    
    let contentHeight: CGFloat = 40
    
    lazy var contentView: UIView = {
       let view = UIView()
        view.backgroundColor = UIColor.cyan
        return view
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    
    func setup() {
        self.backgroundColor = UIColor.orange
        self.addSubview(contentView)
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.heightAnchor.constraint(equalToConstant: contentHeight).isActive = true
        contentView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        contentView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        contentView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
    }
}
