import Foundation

struct Episode: Identifiable, Codable, Hashable {
    let id: String // usually the GUID from RSS
    let title: String
    let description: String
    let pubDate: Date
    let audioURL: String
    let duration: Double // in seconds
    
    // Helper for formatting date in UI
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: pubDate)
    }
}