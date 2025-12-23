import Foundation

// FIX: Added 'final' and '@unchecked Sendable' to satisfy Swift 6 Strict Concurrency
final class RSSFeedParser: NSObject, XMLParserDelegate, @unchecked Sendable {
    private var episodes: [Episode] = []
    private var currentElement = ""
    private var currentTitle: String = ""
    private var currentDescription: String = ""
    private var currentPubDate: Date = Date()
    private var currentAudioURL: String = ""
    private var currentID: String = ""
    private var currentDuration: Double = 0.0
    
    // Completion handler for the parser
    private var continuation: CheckedContinuation<[Episode], Error>?
    
    // The main function you call
    func parse(url: URL) async throws -> [Episode] {
        return try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                guard let data = data else {
                    continuation.resume(throwing: NetworkError.decodingError)
                    return
                }
                
                let parser = XMLParser(data: data)
                parser.delegate = self
                if !parser.parse() {
                    // Parser errors are handled in parseErrorOccurred
                }
            }
            task.resume()
        }
    }
    
    // MARK: - XMLParserDelegate Methods
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        currentElement = elementName
        
        if elementName == "item" {
            // Reset temp variables
            currentTitle = ""
            currentDescription = ""
            currentAudioURL = ""
            currentID = ""
            currentDuration = 0.0
        }
        
        if elementName == "enclosure", let url = attributeDict["url"] {
            currentAudioURL = url
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        let data = string.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !data.isEmpty else { return }
        
        switch currentElement {
        case "title": currentTitle += data
        case "description": currentDescription += data
        case "guid": currentID += data
        default: break
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "item" {
            let episode = Episode(
                id: currentID.isEmpty ? UUID().uuidString : currentID,
                title: currentTitle,
                description: currentDescription,
                pubDate: Date(),
                audioURL: currentAudioURL,
                duration: currentDuration
            )
            if !episode.audioURL.isEmpty {
                episodes.append(episode)
            }
        }
    }
    
    func parserDidEndDocument(_ parser: XMLParser) {
        continuation?.resume(returning: episodes)
        continuation = nil
    }
    
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        continuation?.resume(throwing: parseError)
        continuation = nil
    }
}