import Foundation

// The top-level wrapper returned by iTunes
struct ITunesSearchResponse: Codable {
    let resultCount: Int
    let results: [Podcast]
}

// The actual Podcast object
struct Podcast: Codable, Identifiable, Hashable {
    let collectionId: Int
    let collectionName: String?
    let artistName: String?
    let artworkUrl600: String? // The high-res image
    let feedUrl: String?       // The key to getting episodes
    let primaryGenreName: String?
    let trackCount: Int?

    // Identifiable conformance
    var id: Int { collectionId }
    
    // Helper to prevent crashes if data is missing
    var title: String { collectionName ?? "Unknown Title" }
    var author: String { artistName ?? "Unknown Artist" }
    var coverURL: URL? {
        guard let urlString = artworkUrl600 else { return nil }
        return URL(string: urlString)
    }
}