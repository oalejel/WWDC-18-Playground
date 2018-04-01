//: [Previous](@previous)

//: ## Tuning Fork 🎻 🔊
//: Sound is just a series of vibrations in the air! Tuning forks take advantage of their long, narrow ends, called tines, to make air compressions with a constant frequency, which is why they are useful for `tuning` musical instruments.

import PlaygroundSupport
import SpriteKit
import AVFoundation

class PitchPlayer {
    let engine = AVAudioEngine()
    var players: [AVAudioPlayerNode] = []
    var buffer: AVAudioPCMBuffer!
    
    init() {
        let fileURL = Bundle.main.url(forResource:"tuning_a", withExtension: "m4a")!
        let audioFile = try! AVAudioFile(forReading: fileURL)
        buffer = AVAudioPCMBuffer(pcmFormat: audioFile.processingFormat, frameCapacity: UInt32(audioFile.length))
        try! audioFile.read(into:buffer!)
    }
    
    func addFrequency(f: Float) {
        // if adding a new tuning fork to a set of 3, remove first tone and fork
        if players.count == 3 {
            players[0].pause()
            players.remove(at: 0)
        }
        
        let newPlayer = AVAudioPlayerNode()
        let newPitchEffect = AVAudioUnitTimePitch()
        
        // cents = 1200 * log(f1 / f0) where f0 is the Hz of audio file
//        let cents = 1200 * log(f / 440)
        newPitchEffect.pitch = 1200 * log(f / 440) / log(2) //newPitchEffect.pitch.advanced(by: 60)
        
        engine.attach(newPlayer)
        engine.attach(newPitchEffect)
        
        engine.connect(newPlayer, to: newPitchEffect, format: engine.mainMixerNode.outputFormat(forBus: 0))
        engine.connect(newPitchEffect, to: engine.mainMixerNode, format: engine.mainMixerNode.outputFormat(forBus: 0))
        newPlayer.volume = 1
        
        players.append(newPlayer)
        
        newPlayer.scheduleBuffer(buffer, at: nil, options: .loops)
        self.engine.prepare()
        try! self.engine.start()
    }
    
    // fade volume out when ready to
    func fadeVolumeAndPause(index: Int) {
        if players[index].volume > 0.05 {
            players[index].volume = players[index].volume - 0.05
            
            // use the dispatch queue to reduce volume every 0.1 nanosec/sec
            let dispatchTime: DispatchTime = DispatchTime(uptimeNanoseconds: UInt64(1 * Double(NSEC_PER_SEC)))
            DispatchQueue.main.asyncAfter(deadline: dispatchTime, execute: {
                self.fadeVolumeAndPause(index: index)
            })
        } else {
            players[index].pause()
        }
    }
    
    // raise volume back up and play! 🎹
    func play(index: Int) {
        players[index].volume = 1.0
        let startTime = AVAudioTime(hostTime: 0)
        players[index].play(at: startTime)
    }
}

let tuneDuration: TimeInterval = 5

class TuningFork: SKSpriteNode {
    
    var frequency: CGFloat!
    var timeSincePlayed: Float!
    var playing = false
    
    // height of tines added to top of fork – based on freq.
    var tineHeight: CGFloat!
    var freqLabel: SKLabelNode!
    let emitter = SKEmitterNode(fileNamed: "WaveEmitter")
    
    func showWaves() {
        //change this to be based on actual sound output
        if !playing {
            emitter?.position = CGPoint(x: 0, y: -120 + tineHeight + frame.size.height / 2)
            emitter?.alpha = 0
            if emitter?.parent == nil {
                addChild(emitter!)
            }

            let fadeIn = SKAction.fadeIn(withDuration: 0.5)
            //we keep our tune playing for ~8 seconds
            let delay = SKAction.wait(forDuration: tuneDuration)
            let fadeOut = SKAction.fadeOut(withDuration: 0.8)
            
            //action on completion of tune
            let resetState = SKAction.customAction(withDuration: 0, actionBlock: { (node, i) in
                //reset state, which includes playing bool
                self.playing = false
                //no need to remove from parent for now
//                self.emitter?.removeFromParent()
            })
            
            let soundSequence = SKAction.sequence([fadeIn, delay, fadeOut, resetState])
            emitter?.run(soundSequence)
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
    let pitchPlayer = PitchPlayer()
    
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
        
        newFork(frequency: 261.63)
        newFork(frequency: 329.63)
        newFork(frequency: 392.00)
        
        //show them how to play c major on the next octave
        
        //option for picking from a list of chords that make up a chord --> would need to add sharps
        
        //consider showing longitudinal waves and transverse waves when only one tuning fork has been added
        //create a clear funciton
        
        
        let buttonRect = CGRect(x: 0, y: 0, width: 120, height: 40)
        strikeButton = SqueezeButton(frame: buttonRect)
        let viewSize = view.frame.size
        strikeButton.center = CGPoint(x: viewSize.width * 0.5, y: viewSize.height - buttonRect.height * 0.5 - 8)
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
            
            let moveFromWall = SKAction.move(to: startPoint, duration: 1)
            
            moveFromWall.timingMode = .easeOut
            moveFromWall.duration = 0.8
            
            let playSound = SKAction.customAction(withDuration: 0, actionBlock: { (node, i) in
                (node as! TuningFork).showWaves()
                self.pitchPlayer.play(index: index)
                let wait = SKAction.wait(forDuration: tuneDuration)
                let pausePlayer = SKAction.customAction(withDuration: 0, actionBlock: { (node, i) in
                    self.pitchPlayer.fadeVolumeAndPause(index: index)
                })
                self.run(.sequence([wait, pausePlayer]))
            })
            
            let rotate = SKAction.rotate(byAngle: CGFloat(Double.pi * -0.2), duration: 0.5)
            let reverseRotate = rotate.reversed()
            reverseRotate.duration = 0.7
            let reverseSequence = SKAction.sequence([rotate, reverseRotate])
            let strikeAnimationGroup = SKAction.sequence([moveToWall, playSound, moveFromWall])
            allActions.append(.group([reverseSequence, strikeAnimationGroup]))
        }
        
        for (index, strikeAction) in allActions.enumerated() {
            let indexedDelay = SKAction.wait(forDuration: TimeInterval(index))
            let waitThenStrike = SKAction.sequence([indexedDelay, strikeAction])
            forks[index].run(waitThenStrike)
        }
    }

    func newFork(frequency: CGFloat) {
        //max of 3 tuning forks
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
        
        //add the frequency to our audio player
        pitchPlayer.addFrequency(f: Float(frequency))
        
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
        
        //longer tines means lower frequency!
        let extraTine = SKSpriteNode(texture: tineTexture)
        let maxTineHeight: CGFloat = 55
        let tineHeight = maxTineHeight * (440 / frequency)
        f.tineHeight = tineHeight
        extraTine.size = CGSize(width: 55, height: tineHeight)
        
        //adjust added tine and tuning fork anchors
        extraTine.anchorPoint = CGPoint(x: 0.5, y: 0)
        f.anchorPoint = CGPoint(x: 0.5, y: 1)
        f.addChild(extraTine)

        //add the fork to our list
        forks.append(f)
    }
    
    func removeForks() {
        removeChildren(in: forks)
        forks.removeAll()
    }
 
    public override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}

/// Welcome to The Tuning fork simulator!

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
