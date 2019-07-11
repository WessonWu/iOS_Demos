//: A UIKit based Playground for presenting user interface
  
import UIKit
import PlaygroundSupport


/*
 UILayoutGuide是iOS9中增加的帮助开发者在使用AutoLayout布局时的一个虚拟占位对象。
 场景：
 两个View横向排列居中，使用UILayoutGuide，而不使用创建容器view的方式
 */

class MyViewController : UIViewController {
    override func loadView() {
        let view = UIView()
        view.backgroundColor = .white
        
        // v1 & v2
        let v1 = UIView()
        v1.backgroundColor = UIColor.green
        let v2 = UIView()
        v2.backgroundColor = UIColor.orange
        view.addSubview(v1)
        view.addSubview(v2)
        
        
        v1.translatesAutoresizingMaskIntoConstraints = false
        v2.translatesAutoresizingMaskIntoConstraints = false
        
        let container = UILayoutGuide()
        view.addLayoutGuide(container)
        
        container.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        container.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        container.heightAnchor.constraint(equalToConstant: 10).isActive = true
        
        v1.widthAnchor.constraint(equalToConstant: 100).isActive = true
        v1.heightAnchor.constraint(equalToConstant: 50).isActive = true
        v1.leadingAnchor.constraint(equalTo: container.leadingAnchor).isActive = true
        v1.centerYAnchor.constraint(equalTo: container.centerYAnchor).isActive = true
        
        v2.widthAnchor.constraint(equalToConstant: 100).isActive = true
        v2.heightAnchor.constraint(equalToConstant: 50).isActive = true
        v2.leadingAnchor.constraint(equalTo: v1.trailingAnchor, constant: 20).isActive = true
        v2.trailingAnchor.constraint(equalTo: container.trailingAnchor).isActive = true
        v2.centerYAnchor.constraint(equalTo: container.centerYAnchor).isActive = true
        
        self.view = view
    }
}
// Present the view controller in the Live View window
PlaygroundPage.current.liveView = MyViewController()
