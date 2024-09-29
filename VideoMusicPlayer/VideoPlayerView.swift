import SwiftUI
import AVKit
import AVFoundation

struct VideoPlayerView: View {
    @Binding var selectedMediaType: MediaType?
    
    // State variable to control stopping video
    @State private var stopVideoAction = false

    var body: some View {
        VStack {
            
            // Button to return to MediaChooserView()
            Button(action: {
                
                // Set stopVideoAction to true to trigger the video stop
                stopVideoAction = true
                
                // Go back to the media chooser
                selectedMediaType = nil
            }) {
                Text("Back to Media Chooser")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
            
            // Initialize the VideoPlayerViewControllerWrapper to display the video and buttons
            VideoPlayerViewControllerWrapper(stopVideoAction: $stopVideoAction)
                .frame(height: 400)
        }
        .padding()
    }
}

// This structure integrates the VideoPlayerViewController into SwiftUI. UIViewControllerRepresentable enables SwiftUI to manage its lifecycle
struct VideoPlayerViewControllerWrapper: UIViewControllerRepresentable {
    
    // Binding to trigger stopVideo, listenes to changes from a SwiftUI view
    @Binding var stopVideoAction: Bool
    
    // makeUIViewController() creates an instance of VideoPlayerViewController, called only once when the SwiftUI is rendered
    func makeUIViewController(context: Context) -> VideoPlayerViewController {
        let viewController = VideoPlayerViewController()
        return viewController
    }

    // updateUIViewController() is called when the SwiftUI view state changes
    func updateUIViewController(_ uiViewController: VideoPlayerViewController, context: Context) {
        
        // Call stopVideo if stopVideoAction is true
        if stopVideoAction {
            uiViewController.stop()
            
            // Reset the action
            stopVideoAction = false
        }
    }
}

