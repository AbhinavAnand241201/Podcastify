import Foundation
import SwiftUI

@MainActor
class PlayerViewModel: ObservableObject {
    // Singleton so we can access this VM from anywhere (Search, Detail, Library)
    static let shared = PlayerViewModel()
    
    // The Data
    @Published var currentEpisode: Episode?
    @Published var currentPodcast: Podcast?
    
    // The UI State
    @Published var isMiniPlayerVisible = false
    @Published var isExpanded = false
    
    // Link to Audio Service
    @ObservedObject var audioService = AudioPlayerService.shared
    
    private init() {}
    func play(episode: Episode, podcast: Podcast) {
        self.currentEpisode = episode
        self.currentPodcast = podcast
        self.isMiniPlayerVisible = true
        self.isExpanded = true 
        
        // Pass the whole object now
        audioService.play(episode: episode)
    }
    
    func togglePlayPause() {
        if audioService.isPlaying {
            audioService.pause()
        } else {
            audioService.resume()
        }
    }
    
    func seek(to value: Double) {
        audioService.seek(to: value)
    }
}