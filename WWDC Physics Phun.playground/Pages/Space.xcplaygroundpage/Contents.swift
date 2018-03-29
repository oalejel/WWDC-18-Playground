
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
 
 teach how accelration or force of gravity has a __ proportion to radius, and how velocity has an inverse root relation
 
 */

public class SpaceScene: SKScene {
    
    class ControlView: UIView {
        var scene: SpaceScene!
        var speedSlider: UISlider!
        var speedLabel: UILabel!
        
        var accelerationButton: SqueezeButton!
        var velocityButton: SqueezeButton!
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            let buttonRect = CGRect(x: 0, y: 0, width: 170, height: 50)
            accelerationButton = SqueezeButton(frame: buttonRect)
            accelerationButton.backgroundColor = .white
            accelerationButton.setTitle("Show Acceleration", for: .normal)
            accelerationButton.center = CGPoint(x: frame.size.width / 2, y: frame.size.height / 5)
            accelerationButton.setTitleColor(.darkGray, for: .normal)
            
            velocityButton = SqueezeButton(frame: buttonRect)
            velocityButton.backgroundColor = .white
            velocityButton.setTitle("Show Velocity", for: .normal)
            velocityButton.center = CGPoint(x: frame.size.width * 0.8, y: frame.size.height / 5)
            velocityButton.setTitleColor(.darkGray, for: .normal)
            
            
            accelerationButton.addTarget(self, action: #selector(accPressed), for: .touchUpInside)
            velocityButton.addTarget(self, action: #selector(velPressed), for: .touchUpInside)
            
            addSubview(accelerationButton)
            addSubview(velocityButton)
            
            
            let sliderW: CGFloat = 200
            speedSlider = UISlider(frame: CGRect(x: 0, y: 0, width: sliderW, height: 30))
            speedSlider.minimumValue = Float(1 / 365)
            speedSlider.isContinuous = true
            speedSlider.maximumValue = 2
            speedSlider.center = CGPoint(x: sliderW * 0.5 + 8, y: frame.size.height / 4)
            speedSlider.value = 1
            
            speedSlider.addTarget(self, action: #selector(speedChanged(sender:)), for: .valueChanged)
            
            speedLabel = UILabel(frame: CGRect(x: 0, y: 0, width: sliderW, height: 30))
            speedLabel.center = CGPoint(x: speedSlider.center.x, y: speedSlider.frame.origin.y - 12)
            speedLabel.text = "\(Int(speedSlider.value * 365)) day(s) per second"
            speedLabel.textColor = .white
            addSubview(speedLabel)
            addSubview(speedSlider)
        }
        
        @objc func accPressed() {
            scene.accButtonPressed()
            if accelerationButton.tag == 0 {
                accelerationButton.setTitleColor(.red, for: .normal)
                accelerationButton.setTitle("Hide Acceleration", for: .normal)
                accelerationButton.tag = 1
            } else {
                accelerationButton.setTitleColor(.darkGray, for: .normal)
                accelerationButton.setTitle("Show Acceleration", for: .normal)
                accelerationButton.tag = 0
            }
        }
        
        @objc func velPressed() {
            scene.velButtonPressed()
            if velocityButton.tag == 0 {
                velocityButton.setTitleColor(UIColor(red: 0, green: 0.8, blue: 0, alpha: 1), for: .normal)
                velocityButton.setTitle("Hide Velocity", for: .normal)
                velocityButton.tag = 1
            } else {
                velocityButton.setTitleColor(.darkGray, for: .normal)
                velocityButton.setTitle("Show Velocity", for: .normal)
                velocityButton.tag = 0
            }
        }
        
        @objc func speedChanged(sender: UISlider) {
            speedLabel.text = "\(Int(sender.value * 365 + 1)) day(s) per second"
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
    var planets: [SKShapeNode] = []
    let arrowTexture = SKTexture(imageNamed: "arrow")
    
    public override func didMove(to view: SKView) {
        
        backgroundColor = .black
        let height = view.frame.size.height
        let controlFrame = CGRect(x: 0, y: height - 50, width: view.frame.width, height: 100)
        let controlView = ControlView(frame: controlFrame)
        controlView.scene = self
        controlView.speedSlider.addTarget(self, action: #selector(adjustSpeed(sender:)), for: UIControlEvents.touchUpInside)
        controlView.backgroundColor = .clear
        view.addSubview(controlView)
        
        //:Sprinkle in some stars ✨
        sprinkleStars(count: 100)
        
        sunNode = SKShapeNode(circleOfRadius: 10)
        sunNode.fillColor = .yellow
        sunNode.strokeColor = .yellow
        sunNode.position = .zero
        addChild(sunNode)
        
        mercuryNode = addPlanet(radius: 60, orbitYears: 0.24, angleOffset: Double.pi - 0.1, color: SKColor(displayP3Red: 0.8, green: 0, blue: 0, alpha: 1))
        venusNode = addPlanet(radius: 90, orbitYears: 0.616, angleOffset: Double.pi * 0.3, color: .brown)
        earthNode = addPlanet(radius: 120, orbitYears: 1, angleOffset: Double.pi + 0.1, color: .blue)
        marsNode = addPlanet(radius: 150, orbitYears: 1.88, angleOffset: Double.pi * 1.2, color: .red)
        jupiterNode = addPlanet(radius: 180, orbitYears: 12, angleOffset: Double.pi * 1.12, color: .orange)
        saturnNode = addPlanet(radius: 210, orbitYears: 29, angleOffset: Double.pi * 1.5, color: .white)
        uranusNode = addPlanet(radius: 230, orbitYears: 84, angleOffset: Double.pi * 0.2, color: .cyan)
        neptuneNode = addPlanet(radius: 270, orbitYears: 165, angleOffset: Double.pi * 1.91, color: .blue)
        
        
        // not a planet :(
        //WARNING: MAKE THIS PART Of THE PLAYGROUND EXPERIENCE!!
        //        let pluto = addPlanet(radius: 410, orbitYears: 248, angleOffset: 0, color: #colorLiteral(red: 0.9764705896, green: 0.850980401, blue: 0.5490196347, alpha: 1))
        
        let fireEmitter = SKEmitterNode(fileNamed: "FireParticle.sks")
        fireEmitter?.position = .zero
        addChild(fireEmitter!)
    }
    
    @objc func adjustSpeed(sender: UISlider) {
        let changeSpeed = SKAction.speed(to: CGFloat(sender.value), duration: 1)
        run(changeSpeed)//.repeatForever(changeSpeed))
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
    
    func accButtonPressed() {
        for planet in planets {
            if let accArrow = planet.childNode(withName: "accArrow") {
                accArrow.isHidden = !accArrow.isHidden
            }
        }
    }
    
    func velButtonPressed() {
        for planet in planets {
            if let accArrow = planet.childNode(withName: "velArrow") {
                accArrow.isHidden = !accArrow.isHidden
            }
        }
    }
    
    public override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
    
    // takes orbit radius, earth years for orbit, offset angle (polar coordiantes), and a color for a planet node to be added to the scene
    func addPlanet(radius: CGFloat, orbitYears: CGFloat, angleOffset: Double, color: SKColor) -> SKShapeNode {
        
        //arrow node for acceleration
        let accArrowNode = SKSpriteNode(texture: arrowTexture)
        accArrowNode.color = .red
        accArrowNode.colorBlendFactor = 1
        accArrowNode.size = CGSize(width: (100 / radius) * 23, height: 8)
        accArrowNode.anchorPoint = CGPoint(x: 1, y: 0.5)
        accArrowNode.name = "accArrow"
        accArrowNode.isHidden = true
        
        //arrow node for velocity
        let velArrowNode = SKSpriteNode(texture: arrowTexture)
        velArrowNode.color = .green
        velArrowNode.colorBlendFactor = 1
        velArrowNode.size = CGSize(width: (100 / radius) * 23, height: 8)
        velArrowNode.anchorPoint = CGPoint(x: 1, y: 0.5)
        velArrowNode.zRotation = CGFloat(Double.pi / -2)
        velArrowNode.name = "velArrow"
        velArrowNode.isHidden = true
        
        let planetNode = SKShapeNode(circleOfRadius: 5)
        planetNode.strokeColor = .clear
        planetNode.fillColor = color
        planetNode.position = .zero
        
        planetNode.addChild(accArrowNode)
        accArrowNode.zPosition = -1
        planetNode.addChild(velArrowNode)
        velArrowNode.zPosition = -1
        
        //CGPoint(x: CGFloat(cos(angleOffset)) * radius, y: CGFloat(sin(angleOffset)) * radius)
        
        addChild(planetNode)
        
        
        planetNode.position = CGPoint(x: CGFloat(cos(angleOffset)) * radius, y: CGFloat(sin(angleOffset)) * radius)
        
        let orbitPath = UIBezierPath()//ovalIn: CGRect(x: -1 * radius, y: -1 * radius, width: 2 * radius, height: 2 * radius))
        orbitPath.move(to: planetNode.position)
        
        
        
        
        
        
        
        orbitPath.addArc(withCenter: .zero, radius: radius, startAngle: CGFloat(angleOffset), endAngle: CGFloat(2 * Double.pi - angleOffset), clockwise: true)
        orbitPath.addArc(withCenter: .zero, radius: radius, startAngle: CGFloat(2 * Double.pi - angleOffset), endAngle: CGFloat(angleOffset), clockwise: true)

        
        
        
        
        
        
        
        let orbit = SKAction.follow(orbitPath.cgPath, asOffset: false, orientToPath: true, duration: TimeInterval(15 * orbitYears))
//        let readjust = SKAction.move(to:CGPoint(x: radius, y: 0), duration: 0)
        planetNode.run(.repeatForever(.sequence([orbit])))
        
        planets.append(planetNode)
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

//: [Next](@next)
