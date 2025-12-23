import Foundation
import SwiftData

@Model
class SavedPodcast {
    // We use the ID to ensure we don't save duplicates
    @Attribute(.unique) var id: Int
    var title: String
    var author: String
    var artworkURL: String
    var feedURL: String
    var dateAdded: Date
    
    init(id: Int, title: String, author: String, artworkURL: String, feedURL: String) {
        self.id = id
        self.title = title
        self.author = author
        self.artworkURL = artworkURL
        self.feedURL = feedURL
        self.dateAdded = Date()
    }
}