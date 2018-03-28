//: [Previous](@previous)

//: Physics Phun 🚀⚡️🛰
//: Tuning Fork
//: Sound is just a series of vibrations in the air! Tuning forks take advantage of their long, narrow ends, called tines, to make air compressions with a constant frequency, which is why they are useful for `tuning` musical instruments.

import PlaygroundSupport
import SpriteKit
import AVFoundation

class TuningFork: SKSpriteNode {
    var frequency: Float!
    var timeSincePlayed: Float!
    
    func play() {
        
    }
}

public class TuneScene: SKScene {
    
//    class ControlView: UIView {
//
//
//        override init(frame: CGRect) {
//            super.init(frame: frame)
//
//        }
//
//        required init?(coder aDecoder: NSCoder) {
//            super.init(coder: aDecoder)
//        }
//    }
//
    var forks: [TuningFork] = []
    let forkTexture = SKTexture(imageNamed: "fork")
    
    public override func didMove(to view: SKView) {
        backgroundColor = .blue
       
       
    }
    
    func newFork(frequency: Float) {
        let f = TuningFork(texture: forkTexture)
        f.frequency = frequency
        addChild(f)
        
        forks.append(f)
    }
 
    public override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}





let sceneView = SKView(frame: CGRect(x:0 , y:0, width: 640, height: 480))
let scene = TuneScene()
scene.scaleMode = .aspectFill
sceneView.presentScene(scene)





/// Welcome to THe Tuning fork simulator!

//: We can combine tuning forks to play different musical chords! Clear the previous forks and create 2 more that have frequencies of ___ and ____, then press the strike button!

//: See how different frequency


PlaygroundSupport.PlaygroundPage.current.liveView = sceneView

//: [Next](@next)
