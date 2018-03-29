//: [Previous](@previous)


//: Tuning Fork
//: Sound is just a series of vibrations in the air! Tuning forks take advantage of their long, narrow ends, called tines, to make air compressions with a constant frequency, which is why they are useful for `tuning` musical instruments.

import PlaygroundSupport
import SpriteKit
import AVFoundation
import Accelerate


class TunePlayer {
    func play() {
        
        // Specify the audio format we're going to use
        let sampleRateHz = 44100
        let numChannels = 1
        let pcmFormat = AVAudioFormat(standardFormatWithSampleRate: Double(sampleRateHz), channels: UInt32(numChannels))
        
        let noteFrequencyHz = 440
        let noteDuration: TimeInterval = 10000
        
        // Create a buffer for the audio data
        let numSamples = UInt32(noteDuration * Double(sampleRateHz))
        let buffer = AVAudioPCMBuffer(pcmFormat: pcmFormat!, frameCapacity: numSamples)
        buffer?.frameLength = numSamples  // the buffer will be completely full
        
        for channelBuffer in UnsafeBufferPointer(start: buffer?.floatChannelData, count: numChannels) {
            // Generate a sine wave with the specified frequency and duration
            var length = Int32(numSamples)
            var dc: Float = 0
            var multiplier: Float = 2*Float(Double.pi)*Float(noteFrequencyHz)/Float(sampleRateHz)
            vDSP_vramp(&dc, &multiplier, channelBuffer, (buffer?.stride)!, UInt(numSamples))
            vvsinf(channelBuffer, channelBuffer, &length)
        }
        
        // play audio buffer
//        let engine = AVAudioEngine()
//        let player = AVAudioPlayerNode()
//        engine.attach(player)
//        engine.connect(player, to: engine.mainMixerNode, format: pcmFormat)
//        try! engine.start()
//        player.scheduleBuffer(buffer!, completionHandler: { exit(1) })
//        player.play()
        
        //play in background
//        RunLoop.main.run()
    }
}

class TuningFork: SKSpriteNode {
    var frequency: CGFloat!
    var timeSincePlayed: Float!
    var playing = false
    
    // height of tines added to top of fork – based on freq.
    var tineHeight: CGFloat!
    var freqLabel: SKLabelNode!
    let emitter = SKEmitterNode(fileNamed: "WaveEmitter")
    
    func play() {
        //change this to be based on actual sound output
        if !playing {
            emitter?.position = CGPoint(x: 0, y: -120 + tineHeight + frame.size.height / 2)
            emitter?.alpha = 0
            if emitter?.parent == nil {
                addChild(emitter!)
            }
            
            let fadeIn = SKAction.fadeIn(withDuration: 0.5)
            //we keep our tune playing for 8 seconds
            let delay = SKAction.wait(forDuration: 3)
            //WARNING!!! ^^ make this delay longer once done testing
            let fadeOut = SKAction.fadeOut(withDuration: 0.8)
            
            let resetState = SKAction.customAction(withDuration: 0, actionBlock: { (node, i) in
                //reset state, which includes playing bool
                self.playing = false
                //no need to remove from parent for now
//                self.emitter?.removeFromParent()
            })
            
            let soundSequence = SKAction.sequence([fadeIn, delay, fadeOut, resetState])
            emitter?.run(soundSequence)
//            let x = TunePlayer()
//            x.play()
            playing = true
        }
    }
}

public class TuneScene: SKScene {
    var forks: [TuningFork] = []
    let forkTexture = SKTexture(imageNamed: "fork")
    let tineTexture = SKTexture(imageNamed: "tine")
    let forkOffset: CGFloat = 80
    var strikeButton: SqueezeButton!
    
    // note frequencies
    let As: [CGFloat] = [27.5, 55, 110, 220, 440, 880, 1760, 3520, 7040]
    let Bs: [CGFloat] = [30.87, 61.74, 123.47, 246.94, 493.88, 987.77, 1975.53, 3951.07, 7902.13]
    let Cs: [CGFloat] = [16.35, 32.70, 65.41, 130.81, 261.63, 523.25, 1046.50, 2093.00, 4186.01]
    let Ds: [CGFloat] = [18.35, 36.71, 73.42, 146.83, 293.66, 587.33, 1174.66, 2349.32, 4698.63]
    let Es: [CGFloat] = [20.60, 41.20, 82.41, 164.81, 329.63, 659.25, 1318.51, 2637.02, 5274.04]
    let Fs: [CGFloat] = [21.83, 43.65, 87.31, 174.61, 349.23, 698.46, 1396.91, 2793.83, 5587.65]
    let Gs: [CGFloat] = [24.50, 49.00, 98.00, 196.00, 392.00, 783.99, 1567.98, 3135.96, 6271.93]
    
    public override func didMove(to view: SKView) {
        backgroundColor = .white
        
        newFork(frequency: 440)
        newFork(frequency: 440)
        newFork(frequency: 440)
        
        let buttonRect = CGRect(x: 0, y: 0, width: 170, height: 50)
        strikeButton = SqueezeButton(frame: buttonRect)
        strikeButton.center = CGPoint(x: 100, y: 60)
        view.addSubview(strikeButton)
        strikeButton.backgroundColor = .gray
        strikeButton.setTitle("Strike!", for: .normal)
        strikeButton.addTarget(self, action: #selector(strikePressed), for: .touchUpInside)
    }
    
    @objc func strikePressed() {
        // I love guard statements
        guard let playing = forks.first?.playing, !playing else {
            return
        }
        
        var allActions: [SKAction] = []
        for (index, f) in forks.enumerated() {
            // generate path moving towards wall
            let toWallPath = UIBezierPath()
            toWallPath.move(to: .zero)
            
            let startPoint = f.position
            let startX = (f.frame.size.width + forkOffset) * CGFloat(index)
            // need a special offset to account for angle
            let changeX = -70 + frame.size.width - startX
            let endPosition = CGPoint(x: changeX, y: 0)
            toWallPath.addQuadCurve(to: endPosition, controlPoint: CGPoint(x: changeX * 0.5, y: 200))
            
            let moveToWall = SKAction.follow(toWallPath.cgPath, asOffset: true, orientToPath: false, duration: 0.5)
            moveToWall.timingMode = .easeIn
            
            moveToWall.timingMode = .easeIn
            
            
            let moveFromWall = SKAction.move(to: startPoint, duration: 1)
            
            //= moveToWall.reversed()
            
            moveFromWall.timingMode = .easeOut
            moveFromWall.duration = 0.8
            
//            moveFromWall.duration = 0.7
            
            let playSound = SKAction.customAction(withDuration: 0, actionBlock: { (node, i) in
//                (node as! TuningFork).play()
            })
            
            let rotate = SKAction.rotate(byAngle: CGFloat(Double.pi * -0.2), duration: 0.5)
            let reverseRotate = rotate.reversed()
            reverseRotate.duration = 0.7
            let reverseSequence = SKAction.sequence([rotate, reverseRotate])
            let strikeAnimationGroup = SKAction.sequence([moveToWall, playSound, moveFromWall])
//            let readjust = SKAction.move
            allActions.append(.group([reverseSequence, strikeAnimationGroup]))
        }
        
        for (index, strikeAction) in allActions.enumerated() {
            let indexedDelay = SKAction.wait(forDuration: TimeInterval(index))
            let waitThenStrike = SKAction.sequence([indexedDelay, strikeAction])
            forks[index].run(waitThenStrike)
        }
    }

    func newFork(frequency: CGFloat) {
        //max of 3 tuning forks allowed
        if forks.count == 3 {
            let removeAction = SKAction.customAction(withDuration: 0.5, actionBlock: { (node, num) in
                node.removeFromParent()
            })
            let removalGroup = SKAction.group([.fadeOut(withDuration: 0.5), removeAction])
            forks[0].run(removalGroup)
            forks.remove(at: 0)
            
            //must shift other forks
            let moveAction = SKAction.moveBy(x: -1 * (forkOffset + forks[0].frame.size.width), y: 0, duration: 1)
            forks[0].run(moveAction)
            forks[1].run(moveAction)
        }
        
        let f = TuningFork(texture: forkTexture)
        
        var freqText = ""
        if let index = As.index(of: frequency) {
            freqText = "A\(index): \(frequency) Hz"
        } else if let index = Bs.index(of: frequency) {
            freqText = "B\(index): \(frequency) Hz"
        } else if let index = Cs.index(of: frequency) {
            freqText = "C\(index): \(frequency) Hz"
        } else if let index = Ds.index(of: frequency) {
            freqText = "D\(index): \(frequency) Hz"
        } else if let index = Es.index(of: frequency) {
            freqText = "E\(index): \(frequency) Hz"
        } else if let index = Fs.index(of: frequency) {
            freqText = "F\(index): \(frequency) Hz"
        } else if let index = Gs.index(of: frequency) {
            freqText = "G\(index): \(frequency) Hz"
        } else {
            freqText = "\(frequency) Hz"
        }
        
        f.freqLabel = SKLabelNode(fontNamed: "SanFranciscoText-Bold")
        f.freqLabel.fontSize = 16
        f.freqLabel.text = freqText
        f.freqLabel.fontColor = .darkGray
        f.freqLabel.position = CGPoint(x: 0, y: -1 * f.frame.size.height / 1.8)
        f.addChild(f.freqLabel)
        
        f.size = CGSize(width: 55, height: 260)
        f.frequency = frequency
        addChild(f)
        let forkX = CGFloat(forks.count + 1) *  (f.frame.size.width + forkOffset) - frame.size.width * 0.5
        f.position = CGPoint(x: forkX, y: 0)
        
        let extraTine = SKSpriteNode(texture: tineTexture)
        //longer tines means lower frequency!
        let maxTineHeight: CGFloat = 55
        let tineHeight = maxTineHeight * (frequency / 440)
        f.tineHeight = tineHeight
        extraTine.size = CGSize(width: 55, height: tineHeight)
        
        //adjust added tine and tuning fork anchors
        extraTine.anchorPoint = CGPoint(x: 0.5, y: 0.1)
        f.anchorPoint = CGPoint(x: 0.5, y: 1)
        f.addChild(extraTine)

        //add the fork to our list
        forks.append(f)
//        f.play()//remove later
    }
    
    func removeForks() {
        removeChildren(in: forks)
        forks.removeAll()
    }
 
    public override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}







/// Welcome to THe Tuning fork simulator!

//: We can combine tuning forks to play different musical chords! Clear the previous forks and create 2 more that have frequencies of ___ and ____, then press the strike button!

//: See how different frequency

let sceneView = SKView(frame: CGRect(x:0 , y:0, width: 640, height: 480))
if let scene = TuneScene(fileNamed: "TuneScene") {
    scene.scaleMode = .aspectFill
//    scene.size = sceneView.frame.size
    sceneView.presentScene(scene)
}

PlaygroundSupport.PlaygroundPage.current.liveView = sceneView

//: [Next](@next)
