//: Physics Phun 🚀⚡️🛰
//: Physics Phun is a physics simulator for exploring fascinating phenomena made with SpriteKit, AVFoundation, and

import PlaygroundSupport
import SpriteKit

/*
 Notes (remove when done):
 walkthrough that is similat to other one.
 allow user to try at least one thing and teach a concept
 have transitions like animating into a planet for some close-earth physics concept
 
 IMPORTANT: must give ability to add pluto back in a fun uncommenting feature!!!
 
 */

public class SpaceScene: SKScene {
    
    class ControlView: UIView {
        var scene: SpaceScene!
        var speedSlider: UISlider!
        
        override init(frame: CGRect) {
            super.init(frame: frame)

            let sliderW: CGFloat = 200
            speedSlider = UISlider(frame: CGRect(x: 0, y: 0, width: sliderW, height: 30))
            speedSlider.minimumValue = Float(1 / 365)
            speedSlider.isContinuous = true
            speedSlider.maximumValue = 2
            speedSlider.center = CGPoint(x: sliderW * 0.5 + 8, y: 10)
            
            speedSlider.addTarget(scene, action: #selector(adjustSpeed(sender:)), for: .valueChanged)
            
            addSubview(speedSlider)
        }
        
        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
        }
    }
    
    var sunNode: SKShapeNode!
    var mercuryNode: SKShapeNode!
    var venusNode: SKShapeNode!
    var earthNode: SKShapeNode!
    var marsNode: SKShapeNode!
    var jupiterNode: SKShapeNode!
    var saturnNode: SKShapeNode!
    var uranusNode: SKShapeNode!
    var neptuneNode: SKShapeNode!
    
    public override func didMove(to view: SKView) {
        
        
        backgroundColor = .black
        let height = view.frame.size.height
        let controlFrame = CGRect(x: 0, y: height - 50, width: view.frame.width, height: 100)
        let controlView = ControlView(frame: controlFrame)
        controlView.scene = self
        controlView.backgroundColor = .red
        view.addSubview(controlView)
        
//:Sprinkle in some stars ✨
        sprinkleStars(count: 100)
        
        sunNode = SKShapeNode(circleOfRadius: 10)
        sunNode.fillColor = .yellow
        sunNode.strokeColor = .yellow
        sunNode.position = .zero
        addChild(sunNode)
        
        mercuryNode = addPlanet(radius: 40, orbitYears: 0.24, angleOffset: Double.pi - 0.1, color: SKColor(displayP3Red: 0.8, green: 0, blue: 0, alpha: 1))
        venusNode = addPlanet(radius: 70, orbitYears: 0.616, angleOffset: Double.pi * 0.3, color: .brown)
        earthNode = addPlanet(radius: 100, orbitYears: 1, angleOffset: Double.pi + 0.1, color: .blue)
        marsNode = addPlanet(radius: 130, orbitYears: 1.88, angleOffset: Double.pi * 1.2, color: .red)
        jupiterNode = addPlanet(radius: 160, orbitYears: 12, angleOffset: Double.pi * 1.12, color: .orange)
        saturnNode = addPlanet(radius: 190, orbitYears: 29, angleOffset: Double.pi * 1.5, color: .white)
        uranusNode = addPlanet(radius: 220, orbitYears: 84, angleOffset: Double.pi * 0.2, color: .cyan)
        neptuneNode = addPlanet(radius: 250, orbitYears: 165, angleOffset: Double.pi * 1.91, color: .blue)
        
        
        // not a planet :(
        //WARNING: MAKE THIS PART Of THE PLAYGROUND EXPERIENCE!!
//        let pluto = addPlanet(radius: 110, orbitYears: 248, color: .gray)
        
       let fireEmitter = SKEmitterNode(fileNamed: "FireParticle.sks")
        fireEmitter?.position = .zero
        addChild(fireEmitter!)
    }
    
    @objc func adjustSpeed(sender: UISlider) {
        let s = SKAction.speed(to: 0.5, duration: 0.5)
        run(s)
    }
    
    func sprinkleStars(count: Int) {
        //create twinkle animations
        let fadeIn = SKAction.fadeIn(withDuration: 0.5)
        let fadeOut = SKAction.fadeOut(withDuration: 0.3)
        let wait = SKAction.wait(forDuration: 2, withRange: 10)
        let glow = SKAction.repeatForever(.sequence([wait, fadeOut, fadeIn]))
        
        //generate the stars with random points
        for _ in 0..<count {
            let x = Int(arc4random()) % Int(view!.frame.size.width * 2) - Int(view!.frame.size.width)
            let y =  Int(arc4random()) % Int(view!.frame.size.height * 2) - Int(view!.frame.size.height)
            
            addStar(x: CGFloat(x), y: CGFloat(y)).run(glow)
        }
    }
    
    public override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
    
    // takes orbit radius, earth years for orbit, offset angle (polar coordiantes), and a color for a planet node to be added to the scene
    func addPlanet(radius: CGFloat, orbitYears: CGFloat, angleOffset: Double, color: SKColor) -> SKShapeNode {
        
        let planetNode = SKShapeNode(circleOfRadius: 5)
        planetNode.strokeColor = .clear
        planetNode.fillColor = color
        planetNode.position = .zero
        
        //CGPoint(x: CGFloat(cos(angleOffset)) * radius, y: CGFloat(sin(angleOffset)) * radius)
        
        addChild(planetNode)
        
        let orbitPath = UIBezierPath(ovalIn: CGRect(x: -1 * radius, y: -1 * radius, width: 2 * radius, height: 2 * radius))
        orbitPath.move(to: planetNode.position)

        let orbit = SKAction.follow(orbitPath.cgPath, asOffset: false, orientToPath: true, duration: TimeInterval(15 * orbitYears))
        let readjust = SKAction.move(to:CGPoint(x: radius, y: 0), duration: 0)
        planetNode.run(.repeatForever(.group([readjust, orbit])))
        
        return planetNode
    }
    
    func addStar(x: CGFloat, y: CGFloat) -> SKShapeNode {
        let star = SKShapeNode(circleOfRadius: 0.5)
        star.fillColor = .white
        star.position = CGPoint(x: x, y: y)
        addChild(star)
        return star
    }
}





let sceneView = SKView(frame: CGRect(x:0 , y:0, width: 640, height: 480))
if let scene = SpaceScene(fileNamed: "SpaceScene.sks") {
    scene.scaleMode = .aspectFill
    sceneView.presentScene(scene)
}




/// Welcome to Space!
/// The motion of our planets and stars are governed by gravity, a fundamental force that pulls objects with mass together

//-> Drag and release the planet in the corner to view its interaction with the massive star at the center!!
//-> uncomment these lines to instantly change the gravity that the planets orbiting are experiencing

/// Now it's time to take a look at ____ press ___ to transition to a new simulation! (show emoji)
/// The motion of our planets and stars are governed by gravity, a fundamental force that pulls objects with mass together


PlaygroundSupport.PlaygroundPage.current.liveView = sceneView
