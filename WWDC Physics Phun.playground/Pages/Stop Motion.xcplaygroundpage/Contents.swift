//: [Previous](@previous)


//: ## Stop-Motion 🏃‍♀️🚶‍♀️🕴💨
//: Stop-motion is an essential genre artistic animation, and the illusion of motion is completely based on the way our minds interpret sequences of visual inputs! To trick the brain into seeing something move, we just take advantage of ∆position over ∆time.

//SEQUENCE:
// you are shown example 1: a hello animation
// you have to follow the code to give your book a name and then uncomment the part that puts it on the desk. from this point, the playgroudns has a conversation with the person as they fill out

//then you are shown a sequnce of sketch-like WWDC text being drawn with a few geometric items drawn near the word once you press a BUTTON that says done!



/*
 Notes:
 – the next button only creates a new page if there is no next image. we must check if there is an image to draw!!!
 
 */

import UIKit
import AVFoundation
import PlaygroundSupport

public class FlipPageView: UIView {
    var touchCount = 0
    var drawPath: UIBezierPath!
    var points: [CGPoint] = [.zero, .zero, .zero, .zero, .zero]
    var drawnImg: UIImage?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        isMultipleTouchEnabled = false
        
        backgroundColor = .white
        
        //prepare our drawing path
        drawPath = UIBezierPath()
        drawPath.lineWidth = 1
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
            drawPath.move(to: points[0])
            drawPath.addCurve(to: points[3], controlPoint1: points[1], controlPoint2: points[2])
            
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
        drawPath.removeAllPoints()
        touchCount = 0
    }
    
    public override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesEnded(touches, with: event)
    }
    
    func drawImage() {
    UIGraphicsBeginImageContextWithOptions(frame.size, true, 0)
        if drawnImg == nil {
            let imagePath = UIBezierPath(rect: CGRect(origin: .zero, size: frame.size))
            UIColor.white.setFill()
            imagePath.fill()
            drawnImg = UIGraphicsGetImageFromCurrentImageContext()
        }
        drawnImg?.draw(at: .zero)
        UIColor.black.setStroke()
        drawPath.stroke()
        
        //save image from contents of view
        drawnImg = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }
    
    //this is to be called right before we prepare for a next/prev page
    func saveImage() {
        UIGraphicsBeginImageContextWithOptions(frame.size, true, 0)
        drawnImg = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }
}

public class BookController: UIViewController {
    var images: [UIImage] = []
    var pageIndex = 0
    var soundPlayer: AVAudioPlayer!
    var coverView: UIImageView!
    var backView: UIImageView!
    var pageView: FlipPageView!
    var watermarkView: UIView!
    var bookTitle = "MY STORY I"
    var pageXOffset: CGFloat!
    var coverImgView: UIImageView!
    var extraPages: [UIView] = []
    
    public init(frame: CGRect) {
        super.init(nibName: nil, bundle: nil)
        view.frame = frame
        let xOffsetFactor: CGFloat = 0.05
        let yOffsetFactor: CGFloat = 0.02
        //pageXOffset to be used for book cover
        pageXOffset = frame.size.width * xOffsetFactor
        pageView = FlipPageView(frame: CGRect(x: pageXOffset, y: frame.size.height * yOffsetFactor, width: frame.size.width - (frame.size.width * xOffsetFactor * 2), height: frame.size.height - (frame.size.height * yOffsetFactor * 2)))
    }
    
    public required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
    
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
        coverImgView = UIImageView(image: coverImg)
        coverImgView.contentMode = .scaleAspectFill
        //must offset by spine and -width/2 since we shift anchor point
        let scaledSpineW = (100 / 1971) * view.frame.size.width
        let coverWidth = view.frame.size.width - scaledSpineW
        coverImgView.frame = CGRect(x: -0.5 * coverWidth + scaledSpineW, y: 0, width: coverWidth, height: view.frame.size.height)
        view.addSubview(coverImgView)
        
        //change anchorpoint for flip animation
        coverImgView.layer.anchorPoint = CGPoint(x: 0, y: 0.5)
        
        rotateCover(opening: true)
    }
    
    func rotateCover(opening: Bool) {
        var rotationAnimation = CABasicAnimation()
        rotationAnimation = CABasicAnimation.init(keyPath: "transform.rotation.y")
        rotationAnimation.toValue = NSNumber(value: (opening ? -1 : 1) * Double.pi)
        rotationAnimation.duration = 1.5
        // these must be set to avoid a certain error with removal on completion
        rotationAnimation.isRemovedOnCompletion = false
        rotationAnimation.autoreverses = false
        rotationAnimation.repeatCount = 0
        rotationAnimation.fillMode = kCAFillModeForwards
        coverImgView.layer.add(rotationAnimation, forKey: "rotationAnimation")
    }
    
    // take current page and put it on left side
    func animateFlipLeft() {
        let dummyView = UIImageView(image: images[pageIndex])
        dummyView.frame = inputView!.frame
        view.addSubview(dummyView)
        dummyView.backgroundColor = .red
    }
    
    // take old page and cover current one
    func animateFlipRight() {
        
    }
    
    func prev() {
        //save image in case it was cleared before
        pageView.saveImage()
        
        if (pageIndex > 0) {
            animateFlipRight()
        }
        pageIndex -= 1
    }
    
    func next() {
        //save image in case it was cleared before
        //if nothing was drawn, accept the frame and
        pageView.saveImage()
        if let img = pageView.drawnImg {
            
            images.append(img)
            pageIndex += 1
        }
        
    
    }
    
    func clear() {
        pageView.drawnImg = nil
        pageView.drawImage()
        pageView.setNeedsDisplay()
    }
    
    func animate() {
        
    }
    
    func copyPage() {
        
    }
}

//this viewcontroller controls the main simulation
public class StopMotionController: UIViewController {
    
    let bookSize = CGSize(width: 240, height: 150)
    let bookCenter = CGPoint(x: 160, y: 240)
    var book: BookController!
    
    //buttons for editing
    
    var prevPageButton: SqueezeButton!
    var nextPageButton: SqueezeButton!
    var clearButton: SqueezeButton!
    var animateButton: SqueezeButton!
    var copyButton: SqueezeButton!

    
    func newButton(imageName: String) -> SqueezeButton {
        let buttonRadius: CGFloat = 25
        let lightLightGray = UIColor(white: 0.9, alpha: 1)
        let button = SqueezeButton(frame: CGRect(x: 0, y: 0, width: 2 * buttonRadius, height: 2 * buttonRadius))
        button.layer.cornerRadius = buttonRadius
        button.backgroundColor = lightLightGray
        let copyImage = UIImage(named: imageName)
        button.setImage(copyImage, for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.adjustsImageWhenHighlighted = false
        return button
    }
    
    public override func viewDidLoad() {
//        book = FlipPageView(frame: CGRect(x: 0, y: 0, width: bookSize.width, height: bookSize.height))
        
        copyButton = newButton(imageName: "copy.png")
        prevPageButton = newButton(imageName: "previous.png")
        nextPageButton = newButton(imageName: "next.png")
        animateButton = newButton(imageName: "animate.png")
        clearButton = newButton(imageName: "clear.png")
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        //setup the background
        let img = UIImage(named: "desk.jpg")
        let bgImageView = UIImageView(image: img)
        bgImageView.contentMode = .scaleAspectFill
        bgImageView.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height)
        view.addSubview(bgImageView)
        
        
        //CHANGE TO ANIMATE IN: we add our main book
        book = BookController(frame: CGRect(x: 0, y: 0, width: bookSize.width, height: bookSize.height))
        book.view.center = bookCenter
        view.addSubview(book.view)

        
        //REMOVE WHEN DONE
        let x1 = book.view.frame.origin.x + 40
        let y1 = book.view.frame.origin.y + book.view.frame.size.height + 40
        
        prevPageButton.center = CGPoint(x: x1, y: y1)
        nextPageButton.center = CGPoint(x: x1 + animateButton.frame.size.width + 8, y: y1)
        copyButton.center = CGPoint(x: x1, y: y1 + 8 + copyButton.frame.size.height)
        clearButton.center = CGPoint(x: x1 + clearButton.frame.size.width + 8, y: y1 + 8 + clearButton.frame.size.height)
        animateButton.center = CGPoint(x: x1 + (animateButton.frame.size.width + 8) * 2, y: y1)

        
        prevPageButton.addTarget(self, action: #selector(prevPressed), for: .touchUpInside)
        nextPageButton.addTarget(self, action: #selector(nextPressed), for: .touchUpInside)
        copyButton.addTarget(self, action: #selector(copyPressed), for: .touchUpInside)
        animateButton.addTarget(self, action: #selector(animatePressed), for: .touchUpInside)
        clearButton.addTarget(self, action: #selector(clearPressed), for: .touchUpInside)
    
        
        view.addSubview(prevPageButton)
        view.addSubview(nextPageButton)
        view.addSubview(copyButton)
        view.addSubview(animateButton)
        view.addSubview(clearButton)
    }
    
    @objc func prevPressed() {
        //if we are at page index 0, then do nothing
        //no need to show watermark in this case.. just make sure you handle the watermark view
        
    }
    
    @objc func nextPressed() {
        //store last drawn image in book's images array and
        //animate a new clear page in along with a watermak of last image
        book.next()
    }
    @objc func copyPressed() {
        //take watermark image and combine it with what has been drawn so far
        //note the challenge of combining two UIImages. We need to only read the black from one of the images...
        //UNLESS we make the graphics context read a clear color, in which case we would not have this issue...
        //technically no need to hide last watermark since black-gray overlap will not show
        book.copyPage()
    }
    @objc func animatePressed() {
        //animate the closing of the book followed by opening and animating through images
        // ensure that watermark no longer visible
        book.animate()
    }
    @objc func clearPressed() {
        book.clear()
    }
    
    
}


let viewController = StopMotionController()
viewController.view.frame = CGRect(x: 0, y: 0, width: 640, height: 480)
//let book = FlipPageView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
PlaygroundSupport.PlaygroundPage.current.liveView = viewController.view



//: [Next](@next)
