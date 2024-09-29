// Import statements
import SwiftUI
import AVKit

struct AudioPlayerView: View {
    @Binding var selectedMediaType: MediaType?
    @StateObject private var mediaPlayer = MediaPlayer()
    
    var body: some View {
        VStack {
            
            // Button to return to MediaChooserView()
            Button(action: {
                
                // Stop audio playback
                mediaPlayer.stop()
                
                // Go back to the chooser
                selectedMediaType = nil
            }) {
                Text("Back to Media Chooser")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
            
            Text("Audio Player")
                .font(.largeTitle)
                .padding()
            
            // HStack that holds all the buttons for the audio player. Each button calls its respective funtion when clicked
            HStack(spacing: 30) {
                Button(action: { mediaPlayer.play() }) {
                    Image(systemName: "play.fill")
                        .resizable()
                        .frame(width: 20, height: 20)
                }
                
                Button(action: { mediaPlayer.pause() }) {
                    Image(systemName: "pause.fill")
                        .resizable()
                        .frame(width: 20, height: 20)
                }
                Button(action: { mediaPlayer.stop() }) {
                    Image(systemName: "stop.fill")
                        .resizable()
                        .frame(width: 20, height: 20)
                }
                Button(action: { mediaPlayer.forward() }) {
                    Image(systemName: "goforward.10")
                        .resizable()
                        .frame(width: 25, height: 25)
                }
                Button(action: { mediaPlayer.rewind() }) {
                    Image(systemName: "gobackward.10")
                        .resizable()
                        .frame(width: 25, height: 25)
                }
            }
            .padding()
        }
        
        // When the view appears, call the setupAudioSession() function
        .onAppear {
            mediaPlayer.setupAudioSession()
        }
    }
}


struct AudioPlayerView_Previews: PreviewProvider {
    static var previews: some View {
        AudioPlayerView(selectedMediaType: .constant(nil))
    }
}
