import UIKit
import PlaygroundSupport

final class TestView: UIView {
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        guard let ctx = UIGraphicsGetCurrentContext() else {
            return
        }
        
        ctx.saveGState()
        let lines = UIBezierPath()
        // x
        lines.move(to: CGPoint(x: 0, y: self.bounds.midY))
        lines.addLine(to: CGPoint(x: self.bounds.maxX, y: self.bounds.midY))
        // y
        lines.move(to: CGPoint(x: self.bounds.midX, y: 0))
        lines.addLine(to: CGPoint(x: self.bounds.midX, y: self.bounds.maxY))
        
        UIColor.red.setStroke()
        lines.stroke()
        ctx.restoreGState()
        
        ctx.saveGState()
        let path = UIBezierPath(rect: CGRect(x: self.bounds.midX - 20, y: self.bounds.midY - 20, width: 40, height: 40))
        path.usesEvenOddFillRule = true
        applys(path: path)
        UIColor.green.setFill()
        path.fill()
        ctx.restoreGState()
    }
    
    func alpha(formAngle angle: CGFloat) -> CGFloat {
        return angle / 180 * CGFloat.pi
    }
    
    
    func applys(path: UIBezierPath) {
        // rotation (以原点作为旋转)
        path.applyScale(anchorPoint: path.bounds.center,
                        scaleX: 2,
                        scaleY: 2)
            .applyRotation(anchorPoint: path.bounds.center,
                           angle: 45)
    }
}


extension CGRect {
    var center: CGPoint {
        return CGPoint(x: midX, y: midY)
    }
}

extension UIBezierPath {
    
    @discardableResult
    func applyRotation(anchorPoint: CGPoint, angle: CGFloat) -> UIBezierPath {
        // 1. 将anchorPoint变换到原点
        apply(CGAffineTransform(translationX: -anchorPoint.x, y: -anchorPoint.y))
        // 2. 执行旋转变换
        apply(CGAffineTransform(rotationAngle: angle))
        // 3. 将anchorPoint变换回原处
        apply(CGAffineTransform(translationX: anchorPoint.x, y: anchorPoint.y))
        return self
    }
    
    @discardableResult
    func applyTranslation(x: CGFloat, y: CGFloat) -> UIBezierPath {
        apply(CGAffineTransform(translationX: x, y: y))
        return self
    }
    
    @discardableResult
    func applyScale(anchorPoint: CGPoint, scaleX: CGFloat, scaleY: CGFloat) -> UIBezierPath {
        apply(CGAffineTransform(translationX: -anchorPoint.x, y: -anchorPoint.y))
        apply(CGAffineTransform(scaleX: scaleX, y: scaleY))
        apply(CGAffineTransform(translationX: anchorPoint.x, y: anchorPoint.y))
        return self
    }
}

let testView = TestView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
testView.backgroundColor = UIColor.white

PlaygroundPage.current.liveView = testView
