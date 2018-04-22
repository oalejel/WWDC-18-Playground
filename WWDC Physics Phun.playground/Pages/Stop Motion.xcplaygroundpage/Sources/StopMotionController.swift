import UIKit

//this viewcontroller controls the main simulation
public class StopMotionController: UIViewController {
    let bookSize = CGSize(width: 240, height: 150)
    let bookCenter = CGPoint(x: 200, y: 240)
    public var book: BookController!
    public var pageLabel: UILabel!
    
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
    
    public  init() {
        super.init(nibName: nil, bundle: nil)
        book = BookController(frame: CGRect(x: 0, y: 0, width: bookSize.width, height: bookSize.height))
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
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
        
        // place the book where it needs to be
        book.view.center = bookCenter
        view.addSubview(book.view)
        
        let buttonOffset: CGFloat = 40
        let x1 = book.view.frame.origin.x
        let y1 = book.view.frame.origin.y + book.view.frame.size.height + 40
        
        // position buttons
        prevPageButton.center = CGPoint(x: x1, y: y1)
        nextPageButton.center = CGPoint(x: x1 + animateButton.frame.size.width + buttonOffset, y: y1)
        copyButton.center = CGPoint(x: x1, y: y1 + 8 + copyButton.frame.size.height)
        clearButton.center = CGPoint(x: x1 + clearButton.frame.size.width + buttonOffset, y: y1 + 8 + clearButton.frame.size.height)
        animateButton.center = CGPoint(x: x1 + (animateButton.frame.size.width + buttonOffset) * 2, y: y1)
        eraseButton.center = CGPoint(x: x1 + (animateButton.frame.size.width + buttonOffset) * 2, y: y1 + 8 + clearButton.frame.size.height)
        
        // set self as button targets
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
        pageLabel = UILabel(frame: CGRect(x: book.view.frame.size.width + book.view.frame.origin.x + 8, y: book.view.frame.size.height + book.view.frame.origin.y - 34, width: 100, height: 50))
        pageLabel.textColor = .white
        pageLabel.font = UIFont.systemFont(ofSize: 17, weight: UIFont.Weight.bold)
        
        // if images were preset, the page denominator may not be 1
        pageLabel.text = "Page 1/\(book.images.count == 0 ? 1 : book.images.count)"
        view.addSubview(pageLabel)
    }
    
    @objc func prevPressed() {
        //if we are at page index 0, then do nothing
        //no need to show watermark in this case.. just make sure you handle the watermark view
        if book.pageIndex > 0 {
            book.prev()
            pageLabel.text = "Page \(book.pageIndex + 1)/\(book.images.count)"
        }
    }
    
    @objc func nextPressed() {
        //store last drawn image in book's images array and
        //animate a new clear page in along with a watermak of last image
        book.next()
        //if we havent created anything yet, we offset 1
        let offset = book.pageIndex == book.images.count ? 1 : 0
        pageLabel.text = "Page \(book.pageIndex + 1)/\(book.images.count + offset)"
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
        
        if book.images.count > 1 {
            DispatchQueue.main.async {
                if !self.book.animating {
                    //prepare for beginning of animation
                    self.animateButton.setImage(UIImage(named: "stop.png"), for: .normal)
                    self.prevPageButton.isEnabled = false
                    self.nextPageButton.isEnabled = false
                    self.clearButton.isEnabled = false
                    self.copyButton.isEnabled = false
                    self.eraseButton.isEnabled = false
                    
                    //hide page number label
                    UIView.animate(withDuration: 0.5, animations: {
                        self.pageLabel.alpha = 0
                    })
                } else {
                    //prepare for end of animation
                    self.animateButton.setImage(UIImage(named: "animate.png"), for: .normal)
                    self.prevPageButton.isEnabled = true
                    self.nextPageButton.isEnabled = true
                    self.clearButton.isEnabled = true
                    self.copyButton.isEnabled = true
                    self.eraseButton.isEnabled = true
                    
                    //show page number label
                    self.pageLabel.text = "Page \(1)/\(self.book.images.count)"
                    UIView.animate(withDuration: 0.5, animations: {
                        self.pageLabel.alpha = 1
                    })
                }
                
                self.book.toggleAnimate()
            }
        }
    }
    @objc func clearPressed() {
        book.clear()
    }
    
    @objc func erasePressed() {
        var newImg: UIImage!
        if book.pageView.erasing {
            newImg = UIImage(named: "erase.png")
        } else {
            newImg = UIImage(named: "pencil.png")
        }
        
        eraseButton.setImage(newImg, for: .normal)
        book.toggleErase()
    }
}
