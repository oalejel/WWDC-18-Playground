//: [Previous](@previous)




//: ## Stop-Motion 🏃‍♀️🚶‍♀️🕴💨
//: Stop-motion is an essential genre artistic animation, and the illusion of motion is completely based on the way our minds interpret sequences of visual inputs! To trick the brain into seeing something move, we just take advantage of ∆position over ∆time.


//SEQUENCE:
// you are shown example 1: a hello animation
// you have to follow the code to give your book a name and then uncomment the part that puts it on the desk. from this point, the playgroudns has a conversation with the person as they fill out

//then you are shown a sequnce of sketch-like WWDC text being drawn with a few geometric items drawn near the word once you press a BUTTON that says done!

import UIKit
import AVFoundation
import PlaygroundSupport

public class FlipPageView: UIView {
    var touchCount = 0
    var bPath: UIBezierPath!
    var points: [CGPoint] = [.zero, .zero, .zero, .zero, .zero]
    var tempImg: UIImage?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        isMultipleTouchEnabled = false
        
        backgroundColor = .white
        
        //prepare our drawing path
        bPath = UIBezierPath()
        bPath.lineWidth = 1
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // called when we need to render a new image from old draw input
    public override func draw(_ rect: CGRect) {
        //draw the most recent image containing old paths
        tempImg?.draw(in: rect)
        //draw the new path that has yet to be completed
        bPath.stroke()
    }
    
    // take touch and begin counting
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchCount = 0
        points[0] = touches.first!.location(in: self)
    }
    
    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchCount += 1
        points[touchCount] = touches.first!.location(in: self)
        if touchCount == 4 {
            //if we have more than 3 points, we are able to create a bezier-path-based drawing
            points[3] = CGPoint(x: (points[2].x + points[4].x) / 2, y: (points[2].y + points[4].y) / 2)
            bPath.move(to: points[0])
            bPath.addCurve(to: points[3], controlPoint1: points[1], controlPoint2: points[2])
            
            points[0] = points[3]
            points[1] = points[4]
            touchCount = 1
            
            //draw this newly created path
            setNeedsDisplay()
        }
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        //reset state for new path recording and draw to image
        drawImage()
        setNeedsDisplay()
        bPath.removeAllPoints()
        touchCount = 0
    }
    
    public override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesEnded(touches, with: event)
    }
    
    func drawImage() {
    UIGraphicsBeginImageContextWithOptions(frame.size, true, 0)
        
        if tempImg == nil {
            let imagePath = UIBezierPath(rect: CGRect(origin: .zero, size: frame.size))
            UIColor.white.setFill()
            imagePath.fill()
            tempImg = UIGraphicsGetImageFromCurrentImageContext()
        }
        tempImg?.draw(at: .zero)
        UIColor.black.setStroke()
        bPath.stroke()
        
        //save image from contents of view
        tempImg = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }
}

public class BookController: UIViewController {
    var images: [UIImage]!
    var soundPlayer: AVAudioPlayer!
    var coverView: UIImageView!
    var backView: UIImageView!
    var pageView: FlipPageView!
    var watermarkView: UIView!
    var bookTitle = "MY STORY I"
    
    public init(frame: CGRect) {
        super.init(nibName: nil, bundle: nil)
        view.frame = frame
        let xOffsetFactor: CGFloat = 0.05
        let yOffsetFactor: CGFloat = 0.02
        pageView = FlipPageView(frame: CGRect(x: frame.size.width * xOffsetFactor, y: frame.size.height * yOffsetFactor, width: frame.size.width - (frame.size.width * xOffsetFactor * 2), height: frame.size.height - (frame.size.height * yOffsetFactor * 2)))
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override func viewDidLoad() {
        
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        let backImg = UIImage(named: "back.png")
        let backImgView = UIImageView(image: backImg)
        backImgView.contentMode = .scaleAspectFill
        backImgView.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height)
        view.addSubview(backImgView)
        backImgView.layer.shadowOpacity = 0.3
        backImgView.layer.shadowColor = UIColor.black.cgColor
        backImgView.layer.shadowRadius = 3
        //add the view that takes touch input
        view.addSubview(pageView)
        
        let coverImg = UIImage(named: "cover.png")
        let coverImgView = UIImageView(image: coverImg)
        
        coverImgView.contentMode = .scaleAspectFill
        coverImgView.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height)
        view.addSubview(coverImgView)
        
        var rotationAnimation = CABasicAnimation()
        rotationAnimation = CABasicAnimation.init(keyPath: "transform.rotation.z")
        rotationAnimation.toValue = NSNumber(value: (Double.pi))
        rotationAnimation.duration = 1.0
        rotationAnimation.isCumulative = true
        rotationAnimation.repeatCount = 100.0
        coverImgView.layer.add(rotationAnimation, forKey: "rotationAnimation")
        
        
//        UIView.animate(withDuration: 2, delay: 5, options: .curveEaseIn, animations: {
//            coverImgView.layer.transform = CGAffineTransform(
//        }) { (done) in
//
//        }
    }
}

//this viewcontroller controls the main simulation
public class StopMotionController: UIViewController {
    let bookSize = CGSize(width: 240, height: 150)
    let bookCenter = CGPoint(x: 160, y: 240)
    var book: FlipPageView!
    
    public override func viewDidLoad() {
//        book = FlipPageView(frame: CGRect(x: 0, y: 0, width: bookSize.width, height: bookSize.height))
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        //setup the background
        let img = UIImage(named: "desk.jpg")
        let bgImageView = UIImageView(image: img)
        bgImageView.contentMode = .scaleAspectFill
        bgImageView.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height)
        view.addSubview(bgImageView)
        
        let newBook = BookController(frame: CGRect(x: 0, y: 0, width: bookSize.width, height: bookSize.height))
        newBook.view.center = bookCenter
        view.addSubview(newBook.view)
    
    }
}


let viewController = StopMotionController()
viewController.view.frame = CGRect(x: 0, y: 0, width: 640, height: 480)
//let book = FlipPageView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
PlaygroundSupport.PlaygroundPage.current.liveView = viewController.view



//: [Next](@next)
