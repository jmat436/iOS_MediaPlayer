import AVKit
import SwiftUI

class MediaPlayer: ObservableObject {
    var player: AVPlayer?
    private var isPlaying = false
    private var currentPlaybackTime: CMTime = .zero
    
    // setupAudioSession() will initialize the program to be ready to play a .mp3/.mp4 file
    func setupAudioSession() {
        
        // Get a shared audio instance & assign it to audioSession
        let audioSession = AVAudioSession.sharedInstance()
        
        // Try to set the audio sessions category. Also set the audio session as active
        do {
            
            // Set the category to playback, allowing audio & video playback & set the audio session as active
            try audioSession.setCategory(.playback)
            try audioSession.setActive(true)
        }
        
        // Catch any errors, should they arise
        catch {
            print("Failed to set up audio session: \(error)")
        }
        
        // Observe & handle any interruptions (EX: phone call)
        NotificationCenter.default.addObserver(self, selector: #selector(handleInterruption), name: AVAudioSession.interruptionNotification, object: audioSession)
    }
    
    // handleInterruption() will handle incoming interruptions, like a phone call, by pausing the audio and resuming it when the interruption ends
    // This function is given an objc attribute so that it can be exposed to the Objective-C runtime
    @objc func handleInterruption(notification: Notification) {
        
        // Extract userInfo from the notification to get the interruption details
        guard let userInfo = notification.userInfo,
              
              // Retrieve the interruption type as an UInt
              let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
              
              // Convert the type of the interruption from an UInt to an AVAudioSession.InterruptionType()
              let type = AVAudioSession.InterruptionType(rawValue: typeValue)
        
        // Exit the function if any of the previous statements fail
        else {
            return
        }
        
        // Handle the interruption itself
        switch type {
            
        // When the interruption begins, pause the audio playback
        case .began:
            pause()
            
        // When the interruption ends...
        case .ended:
            
            // Check if playback should resume
            if let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt {
                
                // Convert the optionsValue from type UInt to type AVAudioSession.InterruptionOptions()
                let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
                
                // If the options indicate that the playback should resume, do so
                if options.contains(.shouldResume) {
                    play()
                }
            }
            
        // Break out if the other two cases arent passed
        default:
            break
        }
    }
    
    // play() is called when the user clicks the play button. The function starts the song at the current playback time
    func play() {
        
        // if player is not initialized
        if player == nil {
            
            // Try to get the URL for the test-audio file
            guard let url = Bundle.main.url(forResource: "test-audio", withExtension: "mp3") else { return }
            
            // Initialize player with the audio file URL using AVPlayer
            player = AVPlayer(url: url)
        }
        
        // Seek the player to the current playback time
        player?.seek(to: currentPlaybackTime)
        
        // Start audio playback
        player?.play()
        
        // Update the isPlaying flag to true to indicate that the audio is currently playing
        isPlaying = true
    }
    
    // pause() is called when the user clicks the pause button. The function pauses the song and sets the current playback time variable
    func pause() {
        
        // Pause audio playback
        player?.pause()
        
        // Update the isPlaying flag to false to indicate that the audio is not currently playing
        isPlaying = false
        
        // Set the currentPlaybackTime variable
        if let currentTime = player?.currentTime() {
            currentPlaybackTime = currentTime
        }
    }
    
    // stop() is called when the user clicks the stop button. The function stops the song and sets the current playback time to 0
    func stop() {
        
        // Pause audio playback
        player?.pause()
        
        // Seek the player to 0 (beginning of the song)
        player?.seek(to: CMTime.zero)
        
        // Set the currentPlaybackTime to 0
        currentPlaybackTime = .zero
        
        // Update the isPlaying flag to false to indicate that the audio is not currently playing
        isPlaying = false
    }
    
    // forward() is called when the user clicks the forward button. The function advances the playback 10 seconds
    func forward() {
        
        // Check if the player has a valid piece of media being played. If it doesnt this statement will exit the function so the button does nothing
        guard player?.currentItem != nil else { return }
        
        // Create a current playback time variable, and make the variable type a 'Double', rather than a 'CMTime'
        let currentTime = CMTimeGetSeconds(player!.currentTime())
        
        // Create a newTime variable that is 10 seconds higher than currentTime
        let newTime = currentTime + 10
        
        // Seek the player to the newTime, set the preferredTimescale to 600
        // Preferred timescale makes a connections between a single second and a number of units (in this case 600). It essentially says that each unit is (1/600) of a second
        player?.seek(to: CMTimeMakeWithSeconds(newTime, preferredTimescale: 600))
        
        // Set currentPlaybackTime to the new current time
        currentPlaybackTime = player!.currentTime()
    }
    
    // rewing() is called when the user clicks the rewind button. The function rewinds the playback 10 seconds
    func rewind() {
        
        // Check if the player has a valid piece of media being played. If it doesnt this statement will exit the function so the button does nothing
        guard player?.currentItem != nil else { return }
        
        // Create a current playback time variable, and make the variable type a 'Double, rather than a 'CMTime'
        let currentTime = CMTimeGetSeconds(player!.currentTime())
        
        // Create a newTime variable that is 10 seconds lower than currentTime
        let newTime = currentTime - 10
        
        // Seek the player to the newTime, set the preferredTimescale to 600 and use the max() function so the value passed to CMTimeMakeWithSeconds() is never less than 0
        // Preferred timescale makes a connections between a single second and a number of units (in this case 600). It essentially says that each unit is (1/600) of a second
        player?.seek(to: CMTimeMakeWithSeconds(max(newTime, 0), preferredTimescale: 600))
        
        // Set currentPlaybackTime to the new current time
        currentPlaybackTime = player!.currentTime()
    }
}
