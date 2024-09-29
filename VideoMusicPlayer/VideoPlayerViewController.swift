import SwiftUI
import AVKit

// VideoPlayerViewController provides the implementation for video playback in the application
// VideoPlayerViewController is a subclass of UIViewController, allowing the class to manage/control the video players UI and behavior
class VideoPlayerViewController: UIViewController {
    
    // The player property for the AVPlayerLayer
    var player: AVPlayer?
    
    // The actual PlayerLayer reference variable
    var playerLayer: AVPlayerLayer?
    
    // The Current playback time reference variable for the video
    var currentPlaybackTime: CMTime = .zero
    
    // The amount of time the forward and rewind buttons should move the playback
    let playbackStep: TimeInterval = 10

    // viewDidLoad() will run when the views controller is initialized into memory
    override func viewDidLoad() {
        
        // Execute any default initialization stuff
        super.viewDidLoad()
        
        // Set up the user interface
        setupUI()
        
        // Set up the the notifications which will watch the app for when it goes in and out of background/foreground
        setupNotifications()
    }

    // Build the UI for the VideoPlayerView()
    func setupUI() {
        
        // Create the AVPlayerLayer to display the video
        playerLayer = AVPlayerLayer()
        
        // Ensure the video maintains its aspect ratio
        playerLayer?.videoGravity = .resizeAspect
        
        // Add the player layer as a sublayer of the view
        view.layer.addSublayer(playerLayer!)

        // Create a horizontal stack view to hold the control buttons
        let stackView = UIStackView()
                stackView.axis = .horizontal
                stackView.alignment = .center
                stackView.distribution = .fillEqually
                stackView.spacing = 20

        // Create buttons with SF Symbols, assign their respective functions to them
        let playButton = createButton(systemName: "play.fill") { self.play() }
        let pauseButton = createButton(systemName: "pause.fill") { self.pause() }
        let stopButton = createButton(systemName: "stop.fill") { self.stop() }
        let forwardButton = createButton(systemName: "goforward.10") { self.forward() }
        let rewindButton = createButton(systemName: "gobackward.10") { self.rewind() }

        // Add the buttons to the stackView
        stackView.addArrangedSubview(playButton)
        stackView.addArrangedSubview(pauseButton)
        stackView.addArrangedSubview(stopButton)
        stackView.addArrangedSubview(forwardButton)
        stackView.addArrangedSubview(rewindButton)

        // Disable autoresizing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        // Add the stackView to the main view
        view.addSubview(stackView)

        // Set up layout constraints for the stack view
        NSLayoutConstraint.activate([
            stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            stackView.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    func createButton(systemName: String, action: @escaping () -> Void) -> UIButton {
        let button = UIButton(type: .system)
        // Set the button image using SF Symbols
        let buttonImage = UIImage(systemName: systemName)
        button.setImage(buttonImage, for: .normal)
        button.addTarget(self, action: #selector(actionHandler(_:)), for: .touchUpInside)
        button.tag = systemName == "play.fill" ? 1 : systemName == "pause.fill" ? 2 : systemName == "goforward.10" ? 3 : systemName == "gobackward.10" ? 4 : 5
        
        return button
    }

    @objc func actionHandler(_ sender: UIButton) {
        switch sender.tag {
        case 1:
            play()
        case 2:
            pause()
        case 3:
            forward()
        case 4:
            rewind()
        case 5:
            stop()
        default:
            break
        }
    }

    // play() is called when the user clicks the play button. The function starts the song at the current playback time
    func play() {
        
        // If the player is not initialized
        if player == nil {
            
            // Try to get the url for the test-video file
            guard let url = Bundle.main.url(forResource: "test-video", withExtension: "mp4") else { return }
            
            // Initialize player with the video file URL using AVPlayer
            player = AVPlayer(url: url)
        }
            
        // Assign the player instance to the player layer to display the video
        playerLayer?.player = player

        // Start/resume video playback
        player?.play()
        
        // Call setupVideoSession() to initialize the program to play the video
        setupVideoSession()
    }

    
    // pause() is called when the user clicks the pause button
    func pause() {
        
        // Pause video playback
        player?.pause()
    }

    // forward() is called when the user clicks the forward button. The function advances the playback 10 seconds
    func forward() {
        
        // Retrieve the current playback time from the player
        if let currentTime = player?.currentTime() {
            
            // Calculate a new playback time that is 10 seconds higher than the currentTime
            let newTime = CMTimeAdd(currentTime, CMTime(seconds: (playbackStep / 2), preferredTimescale: 1))
            
            // Seek the player to the newly calculated time
            player?.seek(to: newTime)
        }
    }
    
    // rewind() is called when the user clicks the rewind button. The function rewinds the playback 10 seconds
    func rewind() {
        
        // Retriece the current playback time from the player
        if let currentTime = player?.currentTime() {
            
            // Calculate a new playback time that is 10 seconds smaller than the currentTime
            let newTime = CMTimeSubtract(currentTime, CMTime(seconds: playbackStep, preferredTimescale: 1))
            
            // Seek the player to the newly calculated time
            player?.seek(to: newTime)
        }
    }

    // stop() is called when the user clicks the stop button. The function stops the song and sets the current playback time to 0
    func stop() {
        
        // Pause video playback
        player?.pause()
        
        // Seek the player to 0
        player?.seek(to: .zero)
    }
    
    // setupVideoSession() will initialize the program to be ready to play a .mp3/.mp4 file
    func setupVideoSession() {
        
        // Get a shared audio instance & assign it to videoSession
        let videoSession = AVAudioSession.sharedInstance()
        
        // Try to set the video sessions category. Also set the video session as active
        do {
            
            // Set the category to playback, allowing audio & video playback & set the audio session as active
            try videoSession.setCategory(.playback, mode: .default)
            try videoSession.setActive(true)
        }
        
        // Catch any errors, should they arise
        catch {
            print("Failed to set up audio session: \(error)")
        }
    }

    // setupNotifications() sets the app up to listen for when the app enters the background and when it returns to the foreground.
    func setupNotifications() {
        
        // Add an observer for when the app enters the background, triggering appDidEnterBackground() method.
        NotificationCenter.default.addObserver(self, selector: #selector(appDidEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        
        // Add an observer for when the app is about to enter the foreground, triggering appWillEnterForeground() method.
        NotificationCenter.default.addObserver(self, selector: #selector(appWillEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }

    // appDidEnterBackground() is called when the app goes into the background. It saves the current playback time and removes the player from the player layer to maintain playback.
    @objc func appDidEnterBackground() {
        
        // Store the current playback time. If the player is nil, use .zero as a default value.
        currentPlaybackTime = player?.currentTime() ?? .zero
        
        // Remove the player from the player layer to maintain video playback.
        playerLayer?.player = nil
    }

    // appWillEnterForeground() is called when the app is about to come back into the foreground. It reinitializes the player and resumes playback from the last saved playback time.
    @objc func appWillEnterForeground() {
        
        // Attempt to get the URL for the test video file from the app bundle.
        if let url = Bundle.main.url(forResource: "test-video", withExtension: "mp4") {
            
            // Initialize the player with the video file URL.
            player = AVPlayer(url: url)
            
            // Reassign the player to the player layer.
            playerLayer?.player = player
            
            // Seek to the previously saved playback time and start playback.
            player?.seek(to: currentPlaybackTime)
            
            // Resume playback
            player?.play()
        }
    }
    
    // viewDidLayoutSubviews() is called whenever the view's layout is updated. It adjusts the frame of the player layer to ensure it fits correctly within the view.
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // Define bottom padding to prevent the video from overlapping the button area.
        let bottomPadding: CGFloat = 100

        // Set the frame for the playerLayer to fill the available space above the buttons.
        playerLayer?.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height - bottomPadding)
    }

    // deinit is called when the object is about to be deallocated. It removes the observer for notifications to prevent memory leaks.
    deinit {
        
        // Remove the current object as an observer from NotificationCenter.
        NotificationCenter.default.removeObserver(self)
    }

}
