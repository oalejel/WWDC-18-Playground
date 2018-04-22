//: [Previous](@previous)

import UIKit
import AVFoundation
import PlaygroundSupport

let viewController = StopMotionController()
viewController.view.frame = CGRect(x: 0, y: 0, width: 640, height: 480)
PlaygroundSupport.PlaygroundPage.current.liveView = viewController.view

//: ## Stop-Motion 🏃‍♀️🚶‍♀️📖💨
//: Stop-motion is an essential genre of artistic animation, and the illusion of motion is completely based on the way our minds interpret sequences of visual inputs! To trick the brain into seeing something move, we just take advantage of ∆position over ∆time.

//: - Experiment:
//: To get an idea of how the wonders of stop-motion with a flipbook can be used, let's start with a sequence of pre-made images I designed. Flip through the first few pages with the arrow buttons.
var imageSequence: [UIImage] = []
for i in 1..<86 {
    if let image = UIImage(named: "wwdcimg \(i).tiff") {
        imageSequence.append(image)
    }
}
viewController.book.setImages(imageArr: imageSequence)
//: Press the **triangle play button** to animate through the flipbook! ▶️

//: Uncomment the following line to empty our flipbook's array of UIImages and make our own custom animations.
//viewController.book.setImages(imageArr: [])

//: - Experiment:
//: Let's draw a bouncing ball animation! 🏀
//: ### Step 1: If you're not on the first page, move by pressing the left arrow button. You can clear old images using the 🗑 button.
//: ### Step 2: Draw a medium sized circle in the middle of the top of the page ˚
//: ### Step 3: Press the right arrow, and notice the watermark from the previous page that helps you keep track of your previous drawing. Draw a circle beneath the previous circle's position.
//: ### Step 4: Repeat this process until you reach a circle touching the bottom of the book. This time, use the snapshot camera button to copy the previous page. Then toggle the eraser to erase the top half of a new circle hitting the ground.
//: ### Step 5: Un-toggle the eraser to draw a flat top on the circle to give the impression that it is flattening out.
//: ### Step 6: Repeat the animation of the ball's movement but backwards!
//: ### Step 7: Voila! Running your animation will show a bouncing ball.

//: [Next](@next)
