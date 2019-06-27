import UIKit
import PlaygroundSupport

/*
Quartz2D可以用来绘制渐变图形,即图形向外或向内发散，会变得越来越模糊。

渐变分为线性渐变和径向渐变，所谓线性渐变，就是图形以线的方式发散，发散后一般呈现出矩形的样子；而径向渐变，就是以半径的大小往外或往内发散，发散后呈现出圆形的样子。

渐变系数：0.0~1.0
渐变模式：可以进行与操作

drawsBeforeStartLocation = (1 << 0),  //向内渐变
drawsAfterEndLocation = (1 << 1)      //向外渐变
*/

class DrawGradientView: UIView {
    var startPoint: CGPoint = .zero
    var endPoint: CGPoint = .zero
    
    var locations: [CGFloat]?
    var colors: [UIColor] = []
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        guard let ctx = UIGraphicsGetCurrentContext(), needsDraw() else {
            return
        }
        
        ctx.saveGState()
        defer {
            ctx.restoreGState()
        }
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let colorComponents = colors.flatMap { return $0.cgColor.components ?? [] }
        let locations = self.locations
        let startPoint = self.startPoint.applying(CGAffineTransform(scaleX: bounds.width, y: bounds.height))
        let endPoint = self.endPoint.applying(CGAffineTransform(scaleX: bounds.width, y: bounds.height))
        guard let gradient = CGGradient(colorSpace: colorSpace,
                                        colorComponents: colorComponents,
                                        locations: locations,
                                        count: locations?.count ?? 0) else {
            return
        }
        
        ctx.drawLinearGradient(gradient,
                               start: startPoint,
                               end: endPoint,
                               options: .drawsAfterEndLocation)
    }
    
    
    func needsDraw() -> Bool {
        return startPoint != endPoint && !colors.isEmpty
    }
}



let testView = DrawGradientView()
testView.backgroundColor = UIColor.white
testView.frame = CGRect(x: 0, y: 0, width: 200, height: 80)

struct GradientDirection {
    let startPoint: CGPoint
    let endPoint: CGPoint
    
    static let left_to_right = GradientDirection(startPoint: CGPoint(x: 0, y: 0), endPoint: CGPoint(x: 1, y: 0))
    static let right_to_left = GradientDirection(startPoint: CGPoint(x: 1, y: 0), endPoint: CGPoint(x: 0, y: 0))
    static let top_to_bttom = GradientDirection(startPoint: CGPoint(x: 0, y: 0), endPoint: CGPoint(x: 0, y: 1))
    static let bottom_to_top = GradientDirection(startPoint: CGPoint(x: 0, y: 1), endPoint: CGPoint(x: 0, y: 0))
}

func gradient(view: DrawGradientView = testView, direction: GradientDirection, config: (DrawGradientView) -> Void) {
    view.startPoint = direction.startPoint
    view.endPoint = direction.endPoint
    config(view)
    // 必须调用
    view.setNeedsDisplay()
}


// 单色渐变
gradient(direction: .left_to_right) { (view) in
    view.colors = [UIColor.red]
    view.locations = nil // 无任何效果
    view.locations = [0, 0.5] //在[0, 0.5]区间内从红色渐变成透明
    view.locations = [0, 1] //在[0, 1]区间内从红色渐变成透明
}

// 多色渐变
gradient(direction: .left_to_right) { (view) in
    view.colors = [UIColor.red, UIColor.green]
    view.locations = nil //无任何效果
    view.locations = [0.3, 0.8] // [0, 0.3]：纯红色；[0.3, 0.8]：红色到绿色渐变；[0.8, 1]：纯绿色
    view.locations = [0, 1] // [0, 1]：红色到绿色渐变
}

gradient(direction: .left_to_right) { (view) in
    view.colors = [UIColor.red, UIColor.green, UIColor.blue]
    view.locations = [0, 0.5, 1] // [0, 0.5]：红色到绿色渐变；[0.5, 1]：绿色到蓝色渐变
}


// 对角线渐变
gradient(direction: .init(startPoint: CGPoint(x: 0, y: 0), endPoint: CGPoint(x: 1, y: 1))) { (view) in
    view.colors = [UIColor.red, UIColor.green, UIColor.blue]
    view.locations = [0, 0.5, 1] // [0, 0.5]：红色到绿色渐变；[0.5, 1]：绿色到蓝色渐变
}

PlaygroundPage.current.liveView = testView
