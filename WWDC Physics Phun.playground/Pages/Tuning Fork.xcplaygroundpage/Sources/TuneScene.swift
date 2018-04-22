import Foundation
import SpriteKit

public class TuneScene: SKScene {
    let pitchPlayer = PitchPlayer()
    var forks: [TuningFork] = []
    var wallNode: SKSpriteNode!
    let forkTexture = SKTexture(imageNamed: "fork")
    let tineTexture = SKTexture(imageNamed: "tine")
    let forkOffset: CGFloat = 80
    let tuneDuration: TimeInterval = 5
    var strikeButton: SqueezeButton!
    
    // whole note frequencies going from A0 to A8 for the As array
    let As: [CGFloat] = [27.5, 55, 110, 220, 440, 880, 1760, 3520, 7040]
    let Bs: [CGFloat] = [30.87, 61.74, 123.47, 246.94, 493.88, 987.77, 1975.53, 3951.07, 7902.13]
    let Cs: [CGFloat] = [16.35, 32.70, 65.41, 130.81, 261.63, 523.25, 1046.50, 2093.00, 4186.01]
    let Ds: [CGFloat] = [18.35, 36.71, 73.42, 146.83, 293.66, 587.33, 1174.66, 2349.32, 4698.63]
    let Es: [CGFloat] = [20.60, 41.20, 82.41, 164.81, 329.63, 659.25, 1318.51, 2637.02, 5274.04]
    let Fs: [CGFloat] = [21.83, 43.65, 87.31, 174.61, 349.23, 698.46, 1396.91, 2793.83, 5587.65]
    let Gs: [CGFloat] = [24.50, 49.00, 98.00, 196.00, 392.00, 783.99, 1567.98, 3135.96, 6271.93]
    
    public override func didMove(to view: SKView) {
        backgroundColor = .white
        self.size = view.bounds.size
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        wallNode = SKSpriteNode(imageNamed: "wall")
        wallNode.size = CGSize(width: 60, height: view.frame.size.height)
        wallNode.anchorPoint = CGPoint(x: 1, y: 1)
        
        wallNode.position = CGPoint(x: view.frame.size.width * 0.5, y: view.frame.size.height * 0.5)
        addChild(wallNode)
        
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
            let changeX = 120 + 0.5 * view!.bounds.size.width - startX
            let endPosition = CGPoint(x: changeX, y: 0)
            toWallPath.addQuadCurve(to: endPosition, controlPoint: CGPoint(x: changeX * 0.5, y: 200))
            
            //action to animate back to original position
            let moveToWall = SKAction.follow(toWallPath.cgPath, asOffset: true, orientToPath: false, duration: 0.5)
            moveToWall.timingMode = .easeIn
            let moveFromWall = SKAction.move(to: startPoint, duration: 1)
            moveFromWall.timingMode = .easeOut
            moveFromWall.duration = 0.8
            
            
            let playSound = SKAction.customAction(withDuration: 0, actionBlock: { (node, i) in
                (node as! TuningFork).showWaves()
                self.pitchPlayer.play(index: index)
            })
            
            let pausePlayer = SKAction.customAction(withDuration: 0, actionBlock: { (node, i) in
                self.pitchPlayer.fadeVolumeAndPause(index: index)
            })
            let wait = SKAction.wait(forDuration: tuneDuration)
            let pauseSequence = SKAction.sequence([wait, pausePlayer])
            
            let rotate = SKAction.rotate(byAngle: CGFloat(Double.pi * -0.2), duration: 0.5)
            let reverseRotate = rotate.reversed()
            reverseRotate.duration = 0.7
            let reverseSequence = SKAction.sequence([rotate, reverseRotate])
            
            // put our motions and sounds in a timeline
            let strikeAnimationGroup = SKAction.sequence([moveToWall, .group([playSound, pauseSequence, moveFromWall]), pausePlayer])
            
            //add to our array of actions indexed by tuning fork
            allActions.append(.group([reverseSequence, strikeAnimationGroup]))
        }
        
        // customize a delay for each tuning fork so that they do not strike the wall at the same time
        for (index, strikeAction) in allActions.enumerated() {
            let indexedDelay = SKAction.wait(forDuration: TimeInterval(index))
            let waitThenStrike = SKAction.sequence([indexedDelay, strikeAction])
            forks[index].run(waitThenStrike)
        }
    }
    
    // if given a string, we can convert by parsing the string and using our frequency array
    public func newFork(noteString: String) {
        let noteDict: [Character:[CGFloat]] = ["A":As, "B":Bs, "C":Cs, "D":Ds, "E":Es, "F":Fs, "G":Gs]
        if noteString.count > 1 {
            let index1 = noteString.index(noteString.startIndex, offsetBy: 0)
            if let noteArr = noteDict[noteString[index1]] {
                if let octave = Int(noteString.components(separatedBy: CharacterSet.letters).joined()) {
                    if octave >= 0 && octave <= 8 {
                        newFork(frequency: noteArr[octave])
                    }
                }
            }
        }
    }
    
    // creates a new fork node with given frequency and adds to scene
    public func newFork(frequency: CGFloat) {
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
        
        // if there is an associated note letter, then use it
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
        
        //setup the fork
        f.size = CGSize(width: 34.375, height: 162.5)
        f.frequency = frequency
        //necessary to have waves view on screen
        f.setWaveAction()
        addChild(f)
        let forkX = CGFloat(forks.count + 1) *  (f.frame.size.width + forkOffset) - frame.size.width * 0.5
        f.position = CGPoint(x: forkX, y: 0)
        
        f.freqLabel = SKLabelNode(fontNamed: UIFont.systemFont(ofSize: 17, weight: UIFont.Weight.bold).fontName)
        f.freqLabel.fontSize = 12
        f.freqLabel.text = freqText
        f.freqLabel.fontColor = .darkGray
        f.freqLabel.position = CGPoint(x: 0, y: -1 * f.frame.size.height - (8 + f.freqLabel.frame.size.height))
        f.addChild(f.freqLabel)
        
        //longer tines means lower frequency!
        let extraTine = SKSpriteNode(texture: tineTexture)
        let maxTineHeight: CGFloat = 40
        let tineHeight = maxTineHeight * (440 / frequency)
        f.tineHeight = tineHeight
        extraTine.size = CGSize(width: 34.375, height: tineHeight)
        
        //adjust added tine and tuning fork anchors
        extraTine.anchorPoint = CGPoint(x: 0.5, y: 0)
        f.anchorPoint = CGPoint(x: 0.5, y: 1)
        f.addChild(extraTine)
        
        //add invisible waves for now
        if let em = f.emitter {
            em.position = CGPoint(x: 0, y: 20 + tineHeight)
            em.alpha = 0
            f.addChild(em)
        }
        
        //add the fork to our list
        forks.append(f)
    }
    
    func removeForks() {
        removeChildren(in: forks)
        forks.removeAll()
    }
}
