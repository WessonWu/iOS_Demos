import UIKit
import PlaygroundSupport


let testView = MaskedGradientView()
testView.backgroundColor = UIColor.white
testView.frame = CGRect(x: 0, y: 0, width: 200, height: 80)

// mask
testView.maskedRadius = 40
testView.maskedCorners = [.topRight, .bottomRight]

struct GradientDirection {
    let startPoint: CGPoint
    let endPoint: CGPoint
    
    static let left_to_right = GradientDirection(startPoint: CGPoint(x: 0, y: 0), endPoint: CGPoint(x: 1, y: 0))
    static let right_to_left = GradientDirection(startPoint: CGPoint(x: 1, y: 0), endPoint: CGPoint(x: 0, y: 0))
    static let top_to_bttom = GradientDirection(startPoint: CGPoint(x: 0, y: 0), endPoint: CGPoint(x: 0, y: 1))
    static let bottom_to_top = GradientDirection(startPoint: CGPoint(x: 0, y: 1), endPoint: CGPoint(x: 0, y: 0))
}

func gradient(view: MaskedGradientView = testView, direction: GradientDirection, config: (MaskedGradientView) -> Void) {
    view.startPoint = direction.startPoint
    view.endPoint = direction.endPoint
    config(view)
    // 必须调用
    view.setNeedsDisplay()
}


// 单色渐变
gradient(direction: .left_to_right) { (view) in
    view.colors = [UIColor.red.cgColor]
    view.locations = nil // 无任何效果
    view.locations = [0, 0.5] //在[0, 0.5]区间内从红色渐变成透明
    view.locations = [0, 1] //在[0, 1]区间内从红色渐变成透明
}

// 多色渐变
gradient(direction: .left_to_right) { (view) in
    view.colors = [UIColor.red.cgColor, UIColor.green.cgColor]
    view.locations = nil //无任何效果
    view.locations = [0.3, 0.8] // [0, 0.3]：纯红色；[0.3, 0.8]：红色到绿色渐变；[0.8, 1]：纯绿色
    view.locations = [0, 1] // [0, 1]：红色到绿色渐变
}

gradient(direction: .left_to_right) { (view) in
    view.colors = [UIColor.red.cgColor, UIColor.green.cgColor, UIColor.blue.cgColor]
    view.locations = [0, 0.5, 1] // [0, 0.5]：红色到绿色渐变；[0.5, 1]：绿色到蓝色渐变
}


// 对角线渐变
gradient(direction: .init(startPoint: CGPoint(x: 0, y: 0), endPoint: CGPoint(x: 1, y: 1))) { (view) in
    view.colors = [UIColor.red.cgColor, UIColor.green.cgColor, UIColor.blue.cgColor]
    view.locations = [0, 0.5, 1] // [0, 0.5]：红色到绿色渐变；[0.5, 1]：绿色到蓝色渐变
}

PlaygroundPage.current.liveView = testView
