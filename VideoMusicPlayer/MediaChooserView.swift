import SwiftUI
import AVKit

struct MediaChooserView: View {
    @Binding var selectedMediaType: MediaType?
    
    var body: some View {
        VStack {
            Text("Choose Media Type")
                .font(.largeTitle)
                .padding()
            
            HStack {
                
                // Button to transition to the AudioPlayerView()
                Button(action: {
                    selectedMediaType = .audio
                }) {
                    Text("Play Audio")
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                // Button to transition to the VideoPlayerView()
                Button(action: {
                    selectedMediaType = .video
                }) {
                    Text("Play Video")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding()
        }
    }
}

struct MediaChooserView_Previews: PreviewProvider {
    static var previews: some View {
        MediaChooserView(selectedMediaType: .constant(nil))
    }
}
