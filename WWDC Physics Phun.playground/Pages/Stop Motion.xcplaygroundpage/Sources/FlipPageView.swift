import UIKit

public class FlipPageView: UIView {
    public var touchCount = 0
    public var drawPath: UIBezierPath!
    public var points: [CGPoint] = [.zero, .zero, .zero, .zero, .zero]
    public var drawnImg: UIImage?
    public var erasing = false
    public var erasePaths: [UIBezierPath] = []
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        isMultipleTouchEnabled = false
        
        backgroundColor = .white
        
        //prepare our drawing path
        drawPath = UIBezierPath()
        drawPath.lineWidth = 2
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // called when we need to render a new image from old draw input
    public override func draw(_ rect: CGRect) {
        //draw the most recent image containing old paths
        drawnImg?.draw(in: rect)
        
        //draw the new path that has yet to be completed
        drawPath.stroke()
        
        // draw our white erase marks
        UIColor.white.setFill()
        for p in erasePaths {
            p.fill()
        }
        
        if drawnImg == nil {
            UIGraphicsBeginImageContextWithOptions(frame.size, true, 0)
            let imagePath = UIBezierPath(rect: CGRect(origin: .zero, size: frame.size))
            
            UIColor.white.setFill()
            imagePath.fill()
            drawnImg = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            setNeedsDisplay()
        }
    }
    
    // take touch and begin counting
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if (!erasing) {
            touchCount = 0
            points[0] = touches.first!.location(in: self)
        }
    }
    
    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !(erasing) {
            touchCount += 1
            points[touchCount] = touches.first!.location(in: self)
            if touchCount == 4 {
                //if we have more than 3 points, we are able to create a bezier-path-based drawing
                points[3] = CGPoint(x: (points[2].x + points[4].x) / 2, y: (points[2].y + points[4].y) / 2)
                drawPath.move(to: points[0])
                drawPath.addCurve(to: points[3], controlPoint1: points[1], controlPoint2: points[2])
                
                points[0] = points[3]
                points[1] = points[4]
                touchCount = 1
                
                //draw this newly created path with drawRect
                setNeedsDisplay()
            }
        } else {
            let whiteCircle = UIBezierPath(arcCenter: touches.first!.location(in: self), radius: 4, startAngle: 0, endAngle: CGFloat(2 * Double.pi), clockwise: true)
            erasePaths.append(whiteCircle)
            setNeedsDisplay()
        }
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        //reset state for new path recording and draw to image
        drawImage()
        setNeedsDisplay()
        drawPath.removeAllPoints()
        touchCount = 0
    }
    
    public override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesEnded(touches, with: event)
    }
    
    // drawing to layer and saving image permanently
    public func drawImage() {
        UIGraphicsBeginImageContextWithOptions(frame.size, true, 0)
        
        // if we haven't created an image, get one from an empty context with a white background
        if drawnImg == nil {
            let imagePath = UIBezierPath(rect: CGRect(origin: .zero, size: frame.size))
            UIColor.white.setFill()
            imagePath.fill()
            drawnImg = UIGraphicsGetImageFromCurrentImageContext()
        }
        
        //draw our bezier path
        drawnImg?.draw(in: CGRect(origin: .zero, size: frame.size))
        UIColor.black.setStroke()
        drawPath.stroke()
        
        // draw our white eraser marks
        UIColor.white.setFill()
        for p in erasePaths {
            p.fill()
        }
        erasePaths.removeAll()
        
        //save image from contents of view
        drawnImg = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }
}
