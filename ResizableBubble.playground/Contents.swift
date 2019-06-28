import UIKit
import PlaygroundSupport

class MyViewController : UIViewController {
    lazy var imageView = UIImageView()
    lazy var textLabel = UILabel()
    
    
    let insets = UIEdgeInsets(top: 23, left: 12, bottom: 12, right: 35)
    let preferredMaxWidth: CGFloat = 300
    
    override func loadView() {
        let view = UIView()
        view.backgroundColor = .white
        imageView.contentMode = .scaleToFill
        view.addSubview(imageView)
        self.view = view
        
        imageView.addSubview(textLabel)
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        let top = textLabel.topAnchor.constraint(equalTo: imageView.topAnchor, constant: insets.top)
        let left = textLabel.leftAnchor.constraint(equalTo: imageView.leftAnchor, constant: insets.left)
        let right = textLabel.rightAnchor.constraint(equalTo: imageView.rightAnchor, constant: -insets.left)
        let bottom = textLabel.bottomAnchor.constraint(equalTo: imageView.bottomAnchor, constant: -insets.bottom)
        NSLayoutConstraint.activate([top, left, right, bottom])
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        let width = imageView.widthAnchor.constraint(lessThanOrEqualToConstant: preferredMaxWidth)
        let centerX = imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        let centerY = imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        NSLayoutConstraint.activate([width, centerX, centerY])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        setupBubble1()
        setupBubble2()
        
        textLabel.numberOfLines = 0
        textLabel.font = UIFont.systemFont(ofSize: 14)
        textLabel.preferredMaxLayoutWidth = preferredMaxWidth - 2 * insets.left
        textLabel.textColor = UIColor.white
        
        textLabel.text = "测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测是"
    }
    
    
    /* 方法一(弃用)：
     iOS 5.0以前使用(弃用)这个方法会自动计算出偏向中间的一个
     1*1的方格也就是被拉伸的地方(默认使用拉伸),
     一般传入的值为图片大小的一半.
     */
    func setupBubble1() {
        let midX = bubble.size.width / 2
        let midY = bubble.size.height / 2
        imageView.image = bubble.stretchableImage(withLeftCapWidth: Int(midX.rounded(.down)),
                                                  topCapHeight: Int(midY.rounded(.down)))
    }
    
    /* 方法二(常用)：
     将图片没有保护的部分进行拉伸。
     上下左右的值定义了受保护区域，
     能被拉伸的地方是中间区域，
     一般我们都设成中心点为了安全。
     */
    func setupBubble2() {
        // stretch: 拉伸，通过拉伸UIEdgeInsets指定的矩形区域来填充图片
        // tile: 平铺, 通过重复显示UIEdgeInsets指定的矩形区域来填充图片
        imageView.image = bubble.resizableImage(withCapInsets: insets,
                                                resizingMode: .stretch)
    }
    
    
    var bubble: UIImage {
        return #imageLiteral(resourceName: "bubble@2x.png")
    }
}
// Present the view controller in the Live View window
PlaygroundPage.current.liveView = MyViewController()
