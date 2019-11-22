//
//  ImagePlaceholderManager.swift
//  KingfisherBestPractice
//
//  Created by wuweixin on 2019/11/22.
//  Copyright © 2019 wuweixin. All rights reserved.
//

import UIKit
import Kingfisher

final class ImagePlaceholder: UIView, Placeholder {
    
    private lazy var iconImageView: UIImageView = UIImageView(image: UIImage(named: "common_placeholder_radish_ic"))

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInitilization()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInitilization()
    }
    
    private func commonInitilization() {
        self.addSubview(iconImageView)
    }
    
    func add(to imageView: ImageView) {
        imageView.image = nil
        self.frame = imageView.bounds
        self.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        imageView.insertSubview(self, at: 0)
    }
    
    func remove(from imageView: ImageView) {
        self.removeFromSuperview()
    }
    
    override func layoutSubviews() {
        let size = self.bounds.size
        let showIcon: Bool = min(size.width, size.height) >= 64
        self.iconImageView.isHidden = !showIcon
        super.layoutSubviews()
        
        self.iconImageView.frame = CGRect(x: (size.width - 36) / 2, y: (size.height - 36) / 2, width: 36, height: 36)
    }
}


final class ImagePlaceholderManager {
    static let shared = ImagePlaceholderManager()
    
    //Memory
    fileprivate let memoryCache = NSCache<NSString, UIImage>()
    
    var maxMemoryCost: UInt = 0 {
        didSet {
            self.memoryCache.totalCostLimit = Int(maxMemoryCost)
        }
    }
    
    private init() {
        maxMemoryCost = 1024 * 1024 * 10
    }
    
    func placeholderImage(size: CGSize) -> UIImage? {
        let cacheKey = size.cacheKey
        if let image = memoryCache.object(forKey: cacheKey as NSString) {
            return image
        }
        
        var resultImage: UIImage? = nil
        func drawRadishIfNeeded() {
            guard min(size.width, size.height) >= 64,
                let radish = UIImage(named: "common_placeholder_radish_ic") else {
                return
            }
            let radishSize = radish.size
            let radishRect = CGRect(origin: CGPoint(x: (size.width - radishSize.width) / 2,
                                                    y: (size.height - radishSize.height) / 2),
                                    size: radishSize)
            radish.draw(in: radishRect)
        }
        if #available(iOS 10.0, *) {
            resultImage = UIGraphicsImageRenderer(size: size).image { (context) in
                UIColor.valueOf(rgb: 0xf5f5f5).setFill()
                context.fill(context.format.bounds)
                
                drawRadishIfNeeded()
            }
        } else {
            UIGraphicsBeginImageContextWithOptions(size, false, 0)
            
            if let context = UIGraphicsGetCurrentContext() {
                UIColor.valueOf(rgb: 0xf5f5f5).setFill()
                context.fill(CGRect(origin: .zero, size: size))
                drawRadishIfNeeded()
                
                resultImage = UIGraphicsGetImageFromCurrentImageContext()
            }
            
            UIGraphicsEndImageContext()
        }
        
        if let image = resultImage {
            memoryCache.setObject(image, forKey: cacheKey as NSString, cost: image.imageCost)
        }
        
        return resultImage
    }
}

extension CGSize {
    fileprivate var cacheKey: String {
        return "\(width)x\(height)"
    }
}

extension UIColor {
    static let MASK_ALPHA: UInt32 = 0xFF000000
    
    // argb example: 0xFF494949
    static func valueOf(argb: UInt32) -> UIColor {
        let alpha = (argb >> 24) & 0xFF
        let red = (argb >> 16) & 0xFF
        let green = (argb >> 8) & 0xFF
        let blue = argb & 0xFF
        
        return UIColor(red: CGFloat(red) / 255,
                       green: CGFloat(green) / 255,
                       blue: CGFloat(blue) / 255,
                       alpha: CGFloat(alpha) / 255)
    }
    
    // rgb example: 0x494949   (实际上被转为0xFF494949)
    static func valueOf(rgb: UInt32) -> UIColor {
        return valueOf(argb: (rgb | MASK_ALPHA))
    }
}

extension UIImage {
    fileprivate var imageCost: Int {
        return images == nil ?
            Int(size.height * size.width * scale * scale) :
            Int(size.height * size.width * scale * scale) * images!.count
    }
}
