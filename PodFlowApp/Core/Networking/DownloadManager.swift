import Foundation

class DownloadManager: NSObject, ObservableObject {
    static let shared = DownloadManager()
    
    @Published var downloadedEpisodeIDs: Set<String> = []
    @Published var savedEpisodes: [String: Episode] = [:] 
    
    private let kSavedEpisodesKey = "saved_episodes_metadata"
    
    private override init() {
        super.init()
        loadPersistence()
        restoreState() 
    }
    
    func localFilePath(for episodeID: String) -> URL? {
        let safeName = episodeID.replacingOccurrences(of: "/", with: "_")
                                .replacingOccurrences(of: ":", with: "_") + ".mp3"
        guard let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
        return documentsPath.appendingPathComponent(safeName)
    }
    

    
    private func loadPersistence() {
        if let data = UserDefaults.standard.data(forKey: kSavedEpisodesKey) {
            if let decoded = try? JSONDecoder().decode([String: Episode].self, from: data) {
                print("💾 Loaded \(decoded.count) episodes from metadata.")
                self.savedEpisodes = decoded
            }
        }
    }
    
    private func savePersistence() {
        if let data = try? JSONEncoder().encode(self.savedEpisodes) {
            UserDefaults.standard.set(data, forKey: kSavedEpisodesKey)
        }
    }
    
    private func restoreState() {
        guard let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: documentsPath, includingPropertiesForKeys: nil)
            
            var foundIDs: Set<String> = []
            for url in fileURLs {
                if url.pathExtension == "mp3" {
                    let filename = url.deletingPathExtension().lastPathComponent
                    foundIDs.insert(filename)
                }
            }
            
            DispatchQueue.main.async {
                self.downloadedEpisodeIDs = foundIDs
            }
            
        } catch {
            print("Error scanning downloads: \(error)")
        }
    }
    
    func isDownloaded(episodeID: String) -> Bool {
        if downloadedEpisodeIDs.contains(episodeID) { return true }
        
        guard let path = localFilePath(for: episodeID) else { return false }
        if FileManager.default.fileExists(atPath: path.path) {
            DispatchQueue.main.async {
                self.downloadedEpisodeIDs.insert(episodeID)
            }
            return true
        }
        return false
    }
    
    func downloadEpisode(episode: Episode) async throws {
        guard let url = URL(string: episode.audioURL) else { return }
        guard let destination = localFilePath(for: episode.id) else { return }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        try data.write(to: destination)
        
        await MainActor.run {
            print("✅ Download Complete: \(episode.title)")
            self.downloadedEpisodeIDs.insert(episode.id)
            self.savedEpisodes[episode.id] = episode
            self.savePersistence()
            self.objectWillChange.send()
        }
    }
    
    func deleteEpisode(episodeID: String) {
        guard let path = localFilePath(for: episodeID) else { return }
        
        do {
            if FileManager.default.fileExists(atPath: path.path) {
                try FileManager.default.removeItem(at: path)
                print("🗑️ Deleted: \(episodeID)")
            }
        } catch {
            print("Error deleting file: \(error)")
        }
        
        Task { @MainActor in
            self.downloadedEpisodeIDs.remove(episodeID)
            self.savedEpisodes.removeValue(forKey: episodeID)
            self.savePersistence()
            self.objectWillChange.send()
        }
    }
}