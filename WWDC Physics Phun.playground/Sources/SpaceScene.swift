import SpriteKit
import Foundation

/*
 Notes
 - first show 3 planets in orbit with sun. should use dynamic animationf for sun flame
 
 */

//public class SpaceScene: SKScene {
//    var sunNode: SKSpriteNode!
//    var earthNode: SKSpriteNode!
//
//    public override func didMove(to view: SKView) {
//        backgroundColor = .black
//        print("did move to iew")
//        
//        sunNode = SKShapeNode(
//        
//        var starPoints: [(CGFloat, CGFloat)] = []
//        
//        for _ in 0..<80 {
//            let x = Int(arc4random()) % Int(view.frame.size.width) - Int(view.frame.size.width * 0.5)
//            let y =  Int(arc4random()) % Int(view.frame.size.height) - Int(view.frame.size.height * 0.5)
//            starPoints.append((CGFloat(x), CGFloat(y)))
//        }
//        
//        for coord in starPoints {
//            print("adding star")
//            addStar(x: coord.0, y: coord.1)
//        }
//        
////        let height = view.frame.height
////        let pickerRect = CGRect(x: 0, y: height - 50, width: view.frame.width, height: 100)
////        let pickerView = SKView(frame: pickerRect)
////        pickerView.backgroundColor = SKColor.green
////        view.addSubview(pickerView)
//    }
//    
//    public override func update(_ currentTime: TimeInterval) {
//        // Called before each frame is rendered
//    }
//    
//    func addStar(x: CGFloat, y: CGFloat) {
//        let fadeIn = SKAction.fadeIn(withDuration: 0.5)
//        let fadeOut = SKAction.fadeOut(withDuration: 0.3)
//        let wait = SKAction.wait(forDuration: 2, withRange: 10)
//        let glow = SKAction.repeatForever(.sequence([wait, fadeOut, fadeIn]))
//        
//        let star = SKShapeNode(circleOfRadius: 1)
//        star.fillColor = .white
//        star.position = CGPoint(x: x, y: y)
//        star.run(glow)
//        addChild(star)
//    }
//}

