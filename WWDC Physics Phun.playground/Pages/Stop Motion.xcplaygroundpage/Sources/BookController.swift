import Foundation
import AVFoundation
import UIKit

public class BookController: UIViewController, CAAnimationDelegate {
    public var images: [UIImage] = []
    public var pageIndex = 0
    public var soundPlayer: AVAudioPlayer!
    public var coverView: UIImageView!
    public var backView: UIImageView!
    public var pageView: FlipPageView!
    public var watermarkView: WatermarkView!
    public var pageXOffset: CGFloat!
    public var pageYOffset: CGFloat!
    public var coverImgView: UIImageView!
    public var shadowView: UIView!
    public var extraPages: [UIView] = []
    public var animating = false
    public var animateView: UIImageView!
    
    // ability to change framework of your book
    public var frameDuration: Double = 0.1
    
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
    
    // to be called after initialization in order to set the default animated images if there are any
    public func setImages(imageArr: [UIImage]) {
        images = imageArr
        pageView.drawnImg = images.first
        pageView.setNeedsDisplay()
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
        
        watermarkView = WatermarkView(frame: pageView.frame)
        watermarkView.backgroundColor = .clear
        watermarkView.isExclusiveTouch = false
        watermarkView.isUserInteractionEnabled = false
        
        view.addSubview(watermarkView)
        
        //change anchorpoint for flip animation
        coverImgView.layer.anchorPoint = CGPoint(x: 0, y: 0.5)
        
        rotatePage(view: coverImgView, toLeft: true)
    }
    
    func rotatePage(view: UIView, toLeft: Bool, isPage: Bool = false) {
        var rotationAnimation = CABasicAnimation()
        rotationAnimation = CABasicAnimation.init(keyPath: "transform.rotation.y")
        rotationAnimation.fromValue = NSNumber(value: (toLeft ? 0 : -1) * Double.pi)
        rotationAnimation.toValue = NSNumber(value: (toLeft ? -1 : 0) * Double.pi)
        rotationAnimation.duration = isPage ? 0.3 : 1
        // these must be set to avoid a certain error with removal on completion
        rotationAnimation.isRemovedOnCompletion = false
        rotationAnimation.autoreverses = false
        rotationAnimation.repeatCount = 0
        rotationAnimation.fillMode = (toLeft ? kCAFillModeForwards : kCAFillModeBackwards)
        
        //we only handle the callback when we move a page right
        if isPage && !toLeft {rotationAnimation.delegate = self}
        
        view.layer.add(rotationAnimation, forKey: "rotationAnimation")
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
            
            //the animation did stop function will handle removing the image from extraPages
        }
    }
    
    func prev() {
        if animating {return}
        
        //if we havent ever added this image yet, add it
        if pageIndex >= images.count {
            images.append(pageView.drawnImg!)
        } else {
            //else, we already stored this page image before
            images[pageIndex] = pageView.drawnImg!
        }
        if (pageIndex > 0) {
            pageIndex -= 1
            
            //if we havent reached page 0, then set watermark
            if pageIndex > 0 {
                watermarkView.image = images[pageIndex - 1]
            }
            animateFlipToRight()
        }
        
        // if we become or were already page 0, set to nothing
        if pageIndex == 0 {
            // set our watermark for reference
            watermarkView.image = nil
        }
    }
    
    func next() {
        if animating {return}
        
        //if we havent ever added this image yet, add it
        if pageIndex >= images.count {
            images.append(pageView.drawnImg!)
        } else {
            //else, we already stored this page image before
            images[pageIndex] = pageView.drawnImg!
        }
        
        // set our watermark for reference
        watermarkView.image = pageView.drawnImg
        
        pageIndex += 1
        
        //animate going to the next page
        animateFlipToLeft()
    }
    
    func clear() {
        if animating {return}
        pageView.drawnImg = nil
        pageView.drawImage()
        pageView.setNeedsDisplay()
    }
    
    func toggleAnimate() {
        //animate just the first page coming back, set page back to 1, and animate a sequnce of UIImageView images with a timer that increments page
        
        if !animating {
            animating = true
            
            // this calls setNeedsDisplay too
            watermarkView.image = nil
            
            //if we havent ever added this image yet, add it
            if pageIndex >= images.count {
                images.append(pageView.drawnImg!)
            } else {
                //else, we already stored this page image before
                images[pageIndex] = pageView.drawnImg!
            }
            
            //no need to animate other pages
            if extraPages.count >= 2 {
                for p in extraPages[1...] {
                    p.removeFromSuperview()
                }
                extraPages.removeSubrange(1...)
            }
            //if we are on first page, no need to rotate anything
            if images.count > 1 && pageIndex != 0 {
                //go back to first page
                pageIndex = 0
                let first = extraPages.first!
                rotatePage(view: first, toLeft: false, isPage: true)
            }
            
            UIView.animate(withDuration: extraPages.count != 0 ? 2 : 0.3, delay: 0, options: .curveLinear, animations: {
                self.pageView.alpha = 0.999
            }) { (done) in
                self.animateView = UIImageView(frame: self.pageView.frame)
                self.view.addSubview(self.animateView)
                self.animateView!.animationImages = self.images
                self.animateView!.animationDuration = Double(self.images.count) * self.frameDuration
                self.animateView!.animationRepeatCount = 0
                self.animateView!.startAnimating()
            }
        } else {
            //go back to start state on the first page!
            DispatchQueue.main.async {
                self.animating = false
                self.animateView?.removeFromSuperview()
            }
            
            // repeat = 0 in case we started on first page
            pageIndex = 0
            pageView.drawnImg = images[0]
            pageView.setNeedsDisplay()
        }
    }
    
    func copyPage() {
        if animating {return}
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
