import Foundation
import AVFoundation

class SoundManager {
    static let shared = SoundManager()
    
    private var tapSoundPlayer: AVAudioPlayer?
    private var flowerSoundPlayer: AVAudioPlayer?
    
    private init() {
        setupAudioPlayers()
    }
    
    private func setupAudioPlayers() {
        // Load tap sound
        if let tapSoundURL = Bundle.main.url(forResource: "tap_sound", withExtension: "wav") {
            do {
                tapSoundPlayer = try AVAudioPlayer(contentsOf: tapSoundURL)
                tapSoundPlayer?.prepareToPlay()
            } catch {
                print("Error loading tap sound: \(error.localizedDescription)")
                createDefaultTapSound()
            }
        } else {
            createDefaultTapSound()
        }
        
        // Load flower sound
        if let flowerSoundURL = Bundle.main.url(forResource: "flower_sound", withExtension: "wav") {
            do {
                flowerSoundPlayer = try AVAudioPlayer(contentsOf: flowerSoundURL)
                flowerSoundPlayer?.prepareToPlay()
            } catch {
                print("Error loading flower sound: \(error.localizedDescription)")
                createDefaultFlowerSound()
            }
        } else {
            createDefaultFlowerSound()
        }
    }
    
    // Create a default tap sound if the sound file is not available
    private func createDefaultTapSound() {
        // Create a simple beep sound using AudioServicesPlaySystemSound
        // This is a fallback method that doesn't require an audio file
        print("Using default system sound for tap")
    }
    
    // Create a default flower sound if the sound file is not available
    private func createDefaultFlowerSound() {
        // Create a simple chime sound using AudioServicesPlaySystemSound
        // This is a fallback method that doesn't require an audio file
        print("Using default system sound for flower")
    }
    
    func playTapSound() {
        if let player = tapSoundPlayer, player.isPlaying == false {
            player.currentTime = 0
            player.play()
        } else {
            // Fallback to system sound
            AudioServicesPlaySystemSound(1104) // Standard tap sound
        }
    }
    
    func playFlowerSound() {
        if let player = flowerSoundPlayer, player.isPlaying == false {
            player.currentTime = 0
            player.play()
        } else {
            // Fallback to system sound
            AudioServicesPlaySystemSound(1016) // Chime sound
        }
    }
}
