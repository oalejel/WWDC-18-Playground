import AVFoundation

public class PitchPlayer {
    let engine = AVAudioEngine()
    var players: [AVAudioPlayerNode] = []
    var buffer: AVAudioPCMBuffer!
    
    public init() {
        // setup our audio data buffer to handle file audio
        let fileURL = Bundle.main.url(forResource:"tuning_a", withExtension: "m4a")!
        let audioFile = try! AVAudioFile(forReading: fileURL)
        buffer = AVAudioPCMBuffer(pcmFormat: audioFile.processingFormat, frameCapacity: UInt32(audioFile.length))
        try! audioFile.read(into:buffer!)
    }
    
    // this uses the pitch effect to change the frequency emitted by a tuning fork
    public func addFrequency(f: Float) {
        // if adding a new tuning fork to a set of 3, remove first tone and fork
        if players.count == 3 {
            players[0].pause()
            players.remove(at: 0)
        }
        
        let newPlayer = AVAudioPlayerNode()
        let newPitchEffect = AVAudioUnitTimePitch()
        
        // cents = 1200 * log(f1 / f0) / log(2) where f0 is the Hz of audio file
        newPitchEffect.pitch = 1200 * log(f / 440) / log(2)
        
        //attach the audio node and audio unit
        engine.attach(newPlayer)
        engine.attach(newPitchEffect)
        
        engine.connect(newPlayer, to: newPitchEffect, format: engine.mainMixerNode.outputFormat(forBus: 0))
        engine.connect(newPitchEffect, to: engine.mainMixerNode, format: engine.mainMixerNode.outputFormat(forBus: 0))
        newPlayer.volume = 1
        
        // store our player that is unique to the given frequency in an array indexed by tuning fork
        players.append(newPlayer)
        
        newPlayer.scheduleBuffer(buffer, at: nil, options: .loops)
        self.engine.prepare()
        try! self.engine.start()
    }
    
    // fade volume out when ready to
    public func fadeVolumeAndPause(index: Int) {
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
    public func play(index: Int) {
        players[index].volume = 1.0
        let startTime = AVAudioTime(hostTime: 0)
        players[index].play(at: startTime)
    }
}
