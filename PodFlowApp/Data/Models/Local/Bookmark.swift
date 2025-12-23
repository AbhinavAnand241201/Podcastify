import Foundation
import SwiftData

@Model
class Bookmark {
    var id: String // UUID string
    var episodeID: String // Links to the Episode
    var timestamp: Double // The time in seconds (e.g., 140.5)
    var note: String // The user's text
    var createdAt: Date
    
    init(episodeID: String, timestamp: Double, note: String) {
        self.id = UUID().uuidString
        self.episodeID = episodeID
        self.timestamp = timestamp
        self.note = note
        self.createdAt = Date()
    }
    
    // Helper to display time like "02:20"
    var formattedTime: String {
        let minutes = Int(timestamp) / 60
        let seconds = Int(timestamp) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}