import SwiftUI
import AVKit

// Create a MediaType enum that the program can leverage to handle view transitions
enum MediaType {
    case audio
    case video
}

struct ContentView: View {
    @State private var selectedMediaType: MediaType? = nil
    
    var body: some View {
        
        // Handle the view transitions here
        VStack {
            
            // If selectedMediaType == nil, transition to MediaChooserView
            if selectedMediaType == nil {
                MediaChooserView(selectedMediaType: $selectedMediaType)
                
            // If selectedMediaType == .audio, transition to AudioPlayerView
            } else if selectedMediaType == .audio {
                AudioPlayerView(selectedMediaType: $selectedMediaType)
                
            // If selectedMediaType == .video, transition to VideoPlayerView
            } else if selectedMediaType == .video {
                VideoPlayerView(selectedMediaType: $selectedMediaType)
            }
        }
    }
}

// Set ContentView() as the main view for this application
@main
struct MediaPlayerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
