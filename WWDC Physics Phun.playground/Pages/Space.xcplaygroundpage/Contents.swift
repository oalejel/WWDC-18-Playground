
//: # Physics Phun 🚀⚡️🛰
//: Physics Phun is a physics simulator for exploring fascinating phenomena made with SpriteKit, AVFoundation, and UIKit. This simulator features just a few new simulations that reflect a creative extension of the Physics Phun app I published in my Junior year of high school! 👩‍🚀 👨‍🚀 Make sure you get at least a minute of time with the Stop Motion Simulator.

import PlaygroundSupport
import SpriteKit
let sceneRect = CGRect(x:0 , y:0, width: 640, height: 480)
let sceneView = SKView(frame: sceneRect)
let space = SpaceScene(size: sceneView.frame.size)
space.scaleMode = .aspectFill
sceneView.presentScene(space)
PlaygroundSupport.PlaygroundPage.current.liveView = sceneView

//: ## Welcome to the Space Simulator! 🚀 ☀️
//: The motion of our planets and stars are governed by gravity, a fundamental force that pulls objects with mass together

//: - Experiment:
//: Pluto is now classified as a `dwarf planet` because of its small size, especially since it's smaller than our moon! Try adding pluto to our list of orbiting planets and see how slow its orbit is; one orbit period = 248 Earth years.

//let pluto = space.addPlanet(radius: 240, orbitYears: 248, angleOffset: 0, color: #colorLiteral(red: 0.9764705896, green: 0.850980401, blue: 0.5490196347, alpha: 1))


//: *Try pressing the `Show Acceleration` button*
//: The force of gravity represents the invisible pull of one object with mass to another. All objects with mass experience the force of gravity, but the strength depends on distance and mass.
//: The equation *Force = G * M * m / r^2* tells us that as the distance from the sun gets bigger, the force pulling towards the sun gets *way* smaller.


//: - Experiment:
//: This simulator currently shows 100 stars twinkling in the background... Scientists estimate over 1 billion trillion stars existing in the observable universe. Input a number of stars to your heart's desire (but note that 1 billion trillion is larger than a Swift `Int` will ever be).
//space.sprinkleStars(count: 80)

//: *Now try pressing the `Show Velocity` button*
//: Velocity is the speed and direction an object travels in. For a planet, velocity is always perpendicular to acceleration!

//: - Experiment:
//: The speed slider gives you control over how long it takes for planets to orbit. To understand how long it really takes for the 🌎 to orbit the sun, set the slider to the minimum value!


//: Now it's time to take a look at a phenomenon that exists at a smaller scale
//: [Next](@next)
