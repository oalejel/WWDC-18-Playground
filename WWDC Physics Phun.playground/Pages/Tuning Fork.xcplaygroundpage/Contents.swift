//: [Previous](@previous)

import PlaygroundSupport
import SpriteKit
import AVFoundation

let sceneRect = CGRect(x:0 , y:0, width: 640, height: 480)
let sceneView = SKView(frame: sceneRect)
let scene = TuneScene(size: sceneView.frame.size)
scene.scaleMode = .aspectFit
sceneView.presentScene(scene)
PlaygroundSupport.PlaygroundPage.current.liveView = sceneView

//: ## Tuning Fork 🎻 🔊
//: Sound is just a mix of vibrations in the air! Tuning forks take advantage of their long, narrow ends, called tines, to make air compressions with a constant frequency, which is why they are useful for `tuning` musical instruments.

//: - Experiment:
//: The following line creates a tuning fork with a constant frequency of 261.63 Hertz, which means that there are 261.63 wave oscillations in the air as a result of hitting this fork. Press the `Strike` button to see the fork in action!
scene.newFork(frequency: 261.63)

//: - Experiment:
//: The C Major chord is made of a triad of the notes for C, E, and G. The last fork we added already plays the note C4. Try uncommenting the lines below to hear a C major chord in the 4th octave of a standard 88 key 🎹.
//scene.newFork(frequency: 329.63)
//scene.newFork(frequency: 392.00)

//: - Experiment:
//: The G Major chord is composed of notes G, B, and D. Uncomment the following 3 lines to hear it.
//scene.newFork(frequency: 392.00)
//scene.newFork(frequency: 493.88)
//scene.newFork(frequency: 587.33)

//: Note: The different frequencies played by this simulator use a single 440 Hz (note A4) audio file. PitchPlayer uses the equation *cents = 1,200 * log(f1 / f0) / log(2)* to calculate how much that audio file's pitch should be adjusted. See more here: [http://www.sengpielaudio.com/calculator-centsratio.htm](web).

//: - Experiment:
//: This simulator also allows you to easily specify musical notes. Just pass a string in the format "A4", where the first character is a capital letter for whole note A-G, and the number represents octave 0-8.
//scene.newFork(noteString: "A3")
//scene.newFork(noteString: "A4")
//scene.newFork(noteString: "A5")

//: Let's move on to my favorite of the three simulators and get creative! ✍🏼

//: [Next](@next)
