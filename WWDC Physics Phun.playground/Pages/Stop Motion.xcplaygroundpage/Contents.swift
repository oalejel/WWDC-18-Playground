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
    var erasing = false
    var erasePaths: [UIBezierPath] = []
    
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
                
                //draw this newly created path
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
        
        UIColor.white.setFill()
        for p in erasePaths {
            p.fill()
        }
        erasePaths.removeAll()
        
        //save image from contents of view
        drawnImg = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }
    
//    //this is to be called right before we prepare for a next/prev page
//    func refreshImage() {
//        UIGraphicsBeginImageContextWithOptions(frame.size, true, 0)
//        drawnImg = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//        setNeedsDisplay()
//    }
}

public class BookController: UIViewController, CAAnimationDelegate {
    var images: [UIImage] = []
    var pageIndex = 0
    var soundPlayer: AVAudioPlayer!
    var coverView: UIImageView!
    var backView: UIImageView!
    var pageView: FlipPageView!
    var watermarkView: UIView!
    var bookTitle = "MY STORY I"
    var pageXOffset: CGFloat!
    var pageYOffset: CGFloat!
    var coverImgView: UIImageView!
    var shadowView: UIView!
    var extraPages: [UIView] = []
    
    public init(frame: CGRect) {
        super.init(nibName: nil, bundle: nil)
        view.frame = frame
        let xOffsetFactor: CGFloat = 0.05
        let yOffsetFactor: CGFloat = 0.02
        //pageXOffset to be used for book cover
        pageXOffset = frame.size.width * xOffsetFactor
        pageYOffset = frame.size.height * yOffsetFactor
        pageView = FlipPageView(frame: CGRect(x: pageXOffset, y: pageYOffset, width: frame.size.width - (frame.size.width * xOffsetFactor * 2), height: frame.size.height - (pageYOffset * 2)))
    }
    
    public required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
    
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
        
        shadowView = UIView(frame: CGRect(x: pageXOffset, y: pageYOffset, width: 0.5, height: pageView.frame.size.height))
        shadowView.backgroundColor = .white
        shadowView.layer.shadowRadius = 2
        shadowView.layer.shadowColor = UIColor.black.cgColor
        shadowView.layer.shadowOpacity = 0.7
        view.addSubview(shadowView)
        
        //change anchorpoint for flip animation
        coverImgView.layer.anchorPoint = CGPoint(x: 0, y: 0.5)
        
        rotatePage(view: coverImgView, toLeft: true)
    }
    
    func rotatePage(view: UIView, toLeft: Bool, isPage: Bool = false) {
        var rotationAnimation = CABasicAnimation()
        rotationAnimation = CABasicAnimation.init(keyPath: "transform.rotation.y")
        rotationAnimation.fromValue = NSNumber(value: (toLeft ? 0 : -1) * Double.pi)
        rotationAnimation.toValue = NSNumber(value: (toLeft ? -1 : 0) * Double.pi)
        rotationAnimation.duration = isPage ? 0.3 : 1.5
        // these must be set to avoid a certain error with removal on completion
        rotationAnimation.isRemovedOnCompletion = false
        rotationAnimation.autoreverses = false
        rotationAnimation.repeatCount = 0
        rotationAnimation.fillMode = (toLeft ? kCAFillModeForwards : kCAFillModeBackwards)
        
        //we only handle the callback when we move a page right
        if isPage && !toLeft {rotationAnimation.delegate = self}
        
        view.layer.add(rotationAnimation, forKey: "rotationAnimation")
        
        if isPage {
            //            UIView.animate(withDuration: 0.2) {
            //                view.alpha = toLeft ? 0 : 1
            //            }
        }
    }
    
    //called only when page is flipped right
    public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        DispatchQueue.main.async {
            self.extraPages.last?.removeFromSuperview()
            self.extraPages.removeLast()
            self.pageView.drawnImg = self.images[self.pageIndex]
            self.pageView.setNeedsDisplay()
        }
    }
    
    // take current page and put it on left side
    // assume that the pageIndex has been adjusted to the new page
    func animateFlipToLeft() {
        let dummyView = UIImageView(image: images[pageIndex - 1])
        dummyView.frame = pageView.frame
        dummyView.layer.anchorPoint = CGPoint(x: 0, y: 0.5)
        dummyView.frame.origin = CGPoint(x: pageXOffset, y: pageView.frame.origin.y)
        
        extraPages.append(dummyView)
        view.insertSubview(dummyView, belowSubview: shadowView)
        
        //reset the drawing board
        pageView.drawnImg = nil
        if pageIndex < images.count {
            pageView.drawnImg = images[pageIndex]
        }
        pageView.setNeedsDisplay()
        
        rotatePage(view: dummyView, toLeft: true, isPage: true)
    }
    
    // take old page and cover current one
    // we can assume that we are not on page 1
    func animateFlipToRight() {
        if let prevView = extraPages.last {
            view.bringSubview(toFront: prevView)
            view.layer.layoutSublayers()
            rotatePage(view: prevView, toLeft: false, isPage: true)
            
            //the animation did stop function will handle removing the iage from extraPages

            
//            let x = self.pageIndex - 1
//            UIView.animate(withDuration: 0.2, delay: 0, options: .curveLinear, animations: {
//                self.pageView.alpha = 0.99
//            }, completion: { (done) in
//                //reset the drawing board
//                self.pageView.drawnImg = self.images[x]
//                self.pageView.setNeedsDisplay()
//            })
        }
    }
    
    func prev() {
//        //do this to prevent nil images when nothing drawn
//        pageView.refreshImage()
        
        //if we havent ever added this image yet, add it
        if pageIndex >= images.count {
            images.append(pageView.drawnImg!)
        } else {
            //else, we already stored this page image before
            images[pageIndex] = pageView.drawnImg!
        }
        if (pageIndex > 0) {
            pageIndex -= 1
            animateFlipToRight()
        }
    }
    
    func next() {
        //if we havent ever added this image yet, add it
        if pageIndex >= images.count {
            images.append(pageView.drawnImg!)
        } else {
            //else, we already stored this page image before
            images[pageIndex] = pageView.drawnImg!
        }
        
        pageIndex += 1
        
        //animate going to the next page
        animateFlipToLeft()
    }
    
    func clear() {
        pageView.drawnImg = nil
        pageView.drawImage()
        pageView.setNeedsDisplay()
    }
    
    func animate() {
        
    }
    
    func copyPage() {
        //set image to previous
        if pageIndex > 0 {
            pageView.drawnImg = images[pageIndex - 1]
        }
        pageView.setNeedsDisplay()
    }
    
    func toggleErase() {
        pageView.erasing = !pageView.erasing
    }
}

//this viewcontroller controls the main simulation
public class StopMotionController: UIViewController {
    let bookSize = CGSize(width: 240, height: 150)
    let bookCenter = CGPoint(x: 160, y: 240)
    var book: BookController!
    var pageLabel: UILabel!
    
    //buttons for editing
    var prevPageButton: SqueezeButton!
    var nextPageButton: SqueezeButton!
    var clearButton: SqueezeButton!
    var animateButton: SqueezeButton!
    var copyButton: SqueezeButton!
    var eraseButton: SqueezeButton!
    
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
        copyButton = newButton(imageName: "copy.png")
        prevPageButton = newButton(imageName: "previous.png")
        nextPageButton = newButton(imageName: "next.png")
        animateButton = newButton(imageName: "animate.png")
        clearButton = newButton(imageName: "clear.png")
        eraseButton = newButton(imageName: "erase.png")
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
        let buttonOffset: CGFloat = 100
        let x1 = book.view.frame.origin.x
        let y1 = book.view.frame.origin.y + book.view.frame.size.height + 40
        
        prevPageButton.center = CGPoint(x: x1, y: y1)
        nextPageButton.center = CGPoint(x: x1 + animateButton.frame.size.width + buttonOffset, y: y1)
        copyButton.center = CGPoint(x: x1, y: y1 + 8 + copyButton.frame.size.height)
        clearButton.center = CGPoint(x: x1 + clearButton.frame.size.width + buttonOffset, y: y1 + 8 + clearButton.frame.size.height)
        animateButton.center = CGPoint(x: x1 + (animateButton.frame.size.width + buttonOffset) * 2, y: y1)
        eraseButton.center = CGPoint(x: x1 + (animateButton.frame.size.width + buttonOffset) * 2, y: y1 + 8 + clearButton.frame.size.height)
        
        prevPageButton.addTarget(self, action: #selector(prevPressed), for: .touchUpInside)
        nextPageButton.addTarget(self, action: #selector(nextPressed), for: .touchUpInside)
        copyButton.addTarget(self, action: #selector(copyPressed), for: .touchUpInside)
        animateButton.addTarget(self, action: #selector(animatePressed), for: .touchUpInside)
        clearButton.addTarget(self, action: #selector(clearPressed), for: .touchUpInside)
        eraseButton.addTarget(self, action: #selector(erasePressed), for: .touchUpInside)
        
        view.addSubview(prevPageButton)
        view.addSubview(nextPageButton)
        view.addSubview(copyButton)
        view.addSubview(animateButton)
        view.addSubview(clearButton)
        view.addSubview(eraseButton)
        
        //add a label to keep track of pages
        pageLabel = UILabel(frame: CGRect(x: book.view.frame.size.width + book.view.frame.origin.x + 8, y: book.view.frame.size.height + book.view.frame.origin.y - 30, width: 100, height: 50))
        pageLabel.textColor = .white
        pageLabel.text = "page 1/1"
        view.addSubview(pageLabel)
    }
    
    @objc func prevPressed() {
        //if we are at page index 0, then do nothing
        //no need to show watermark in this case.. just make sure you handle the watermark view
        if book.pageIndex > 0 {
            book.prev()
            pageLabel.text = "page \(book.pageIndex + 1)/\(book.images.count)"
        }
    }
    
    @objc func nextPressed() {
        //store last drawn image in book's images array and
        //animate a new clear page in along with a watermak of last image
        book.next()
        //if we havent created anything yet, we offset 1
        let offset = book.pageIndex == book.images.count ? 1 : 0
        pageLabel.text = "page \(book.pageIndex + 1)/\(book.images.count + offset)"
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
    
    @objc func erasePressed() {
        book.toggleErase()
    }
    
    
}


let viewController = StopMotionController()
viewController.view.frame = CGRect(x: 0, y: 0, width: 640, height: 480)
//let book = FlipPageView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
PlaygroundSupport.PlaygroundPage.current.liveView = viewController.view



//: [Next](@next)
