import Foundation
import SwiftData

@Model
class RecentlyPlayed {
    @Attribute(.unique) var episodeID: String
    var podcastTitle: String
    var episodeTitle: String
    var coverURL: String
    var audioURL: String // Needed to resume playback
    var progress: Double // Where they stopped (seconds)
    var duration: Double // Total length
    var lastPlayedAt: Date
    
    init(episodeID: String, podcastTitle: String, episodeTitle: String, coverURL: String, audioURL: String, progress: Double, duration: Double) {
        self.episodeID = episodeID
        self.podcastTitle = podcastTitle
        self.episodeTitle = episodeTitle
        self.coverURL = coverURL
        self.audioURL = audioURL
        self.progress = progress
        self.duration = duration
        self.lastPlayedAt = Date()
    }
}