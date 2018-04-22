import Foundation
import SpriteKit

public class TuningFork: SKSpriteNode {
    public var frequency: CGFloat!
    public var playing = false
    public let tuneDuration: TimeInterval = 5
    
    // height of tines added to top of fork – based on freq.
    public var tineHeight: CGFloat!
    public var freqLabel: SKLabelNode!
    public let emitter = SKEmitterNode(fileNamed: "WaveEmitter")
    public var waveAction: SKAction?
    
    public func setWaveAction() {
        let fadeIn = SKAction.fadeIn(withDuration: 0.5)
        //we keep our tune playing for ~8 seconds
        let delay = SKAction.wait(forDuration: tuneDuration - 1)
        let fadeOut = SKAction.fadeOut(withDuration: 0.8)
        
        //action on completion of tune
        let resetState = SKAction.customAction(withDuration: 0, actionBlock: { (node, i) in
            //reset state, which includes playing bool
            self.playing = false
        })
        
        waveAction = SKAction.sequence([fadeIn, delay, fadeOut, resetState])
    }
    
    // Show animating wave emitter
    public func showWaves() {
        if !playing {
            if let a = waveAction {
                emitter?.run(a)
            }
            playing = true
        }
    }
}
