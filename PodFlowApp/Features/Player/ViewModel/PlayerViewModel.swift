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
    
    // AI Chapters State
    @Published var aiChapters: [SmartChapter] = []
    @Published var isAnalyzingAI: Bool = false
    
    // Link to Audio Service
    @ObservedObject var audioService = AudioPlayerService.shared
    
    private init() {}
    func play(episode: Episode, podcast: Podcast) {
        self.currentEpisode = episode
        self.currentPodcast = podcast
        self.isMiniPlayerVisible = true
        self.isExpanded = true 
        
        // Reset chapters when playing new episode
        self.aiChapters = []
        
        // Trigger Analysis if downloaded
        analyzeCurrentEpisode() 
        
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
    
    // MARK: - AI Analysis
    func analyzeCurrentEpisode() {
        guard let episode = currentEpisode,
              let localURL = DownloadManager.shared.localFilePath(for: episode.id),
              DownloadManager.shared.isDownloaded(episodeID: episode.id) else {
            return
        }
        
        // Start Analysis
        self.isAnalyzingAI = true
        self.aiChapters = [] // clear old ones
        
        Task {
            let newChapters = await AudioAnalysisService.shared.generateChapters(for: localURL)
            DispatchQueue.main.async {
                self.aiChapters = newChapters
                self.isAnalyzingAI = false
            }
        }
    }
}