//: A UIKit based Playground for presenting user interface
  
import UIKit
import PlaygroundSupport

class MyViewController : UIViewController {
    weak var label: UILabel?
    weak var flexibleSwitch: FlexibleSwitch?
    
    override func loadView() {
        let view = UIView()
        view.backgroundColor = .white
        
        
        let otherView = UIView()
        otherView.backgroundColor = UIColor.orange
        otherView.frame = CGRect(x: 150, y: 200, width: 200, height: 20)

        let label = UILabel()
        label.frame = CGRect(x: 150, y: 200, width: 200, height: 20)
        label.text = "Hello World!"
        label.textColor = .black
        
        let maskView = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 20))
        maskView.backgroundColor = UIColor.red
        label.mask = maskView
        self.label = label
        
//        self.maskView = maskView
        
        view.addSubview(otherView)
        view.addSubview(label)
        self.view = view
        
        let button = UIButton(frame: CGRect(x: 100, y: 100, width: 80, height: 40))
        button.setTitle("click", for: .normal)
        button.setTitleColor(UIColor.blue, for: .normal)
        button.addTarget(self, action: #selector(onButtonClick), for: .touchUpInside)
        view.addSubview(button)
        
        let flexibileSwitch = FlexibleSwitch()
        view.addSubview(flexibileSwitch)
        self.flexibleSwitch = flexibileSwitch
        
        flexibileSwitch.translatesAutoresizingMaskIntoConstraints = false
        flexibileSwitch.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        flexibileSwitch.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
    }
    
    @objc
    private func onButtonClick() {
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
            self.label?.mask?.frame = CGRect(x: 0, y: 0, width: 200, height: 20)
        }) { (_) in
            self.label?.mask?.frame = CGRect(x: 0, y: 0, width: 50, height: 20)
        }
        
        
    }
}
// Present the view controller in the Live View window
PlaygroundPage.current.liveView = MyViewController()
