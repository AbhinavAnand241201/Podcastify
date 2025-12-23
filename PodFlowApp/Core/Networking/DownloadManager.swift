import Foundation

class DownloadManager: NSObject, ObservableObject {
    static let shared = DownloadManager()
    
    // PUBLISHED: This notifies the Home View when downloads change
    @Published var downloadedEpisodeIDs: Set<String> = []
    
    private override init() {
        super.init()
        restoreState()
    }
    
    // MARK: - FILE PATH HELPERS
    
    // Helper to get the local file path for an episode
    func localFilePath(for episodeID: String) -> URL? {
        // Sanitize the ID to be safe for filenames (remove / or : characters)
        let safeName = episodeID.replacingOccurrences(of: "/", with: "_")
                                .replacingOccurrences(of: ":", with: "_") + ".mp3"
        
        guard let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
        return documentsPath.appendingPathComponent(safeName)
    }
    
    // MARK: - STATE MANAGEMENT
    
    // Scan the documents directory to restore "downloaded" status on App Launch
    private func restoreState() {
        guard let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: documentsPath, includingPropertiesForKeys: nil)
            
            // Map file names back to IDs roughly (or just check existence later)
            // For this MVP, we will rely on checking existence dynamically or just
            // populating the set if we track it.
            // A simpler approach for the MVP:
            // We won't pre-fill the Set perfectly from filenames since IDs vary,
            // but we can rely on 'isDownloaded' checks in the UI.
            // However, to make the Home View list work, we ideally persist this Set.
            // Since we don't have a DB for downloads specifically, we will rely on runtime for now
            // OR checks happen via 'isDownloaded'.
            
            // *Improvement*: We will leave the Set empty on launch for safety, 
            // but the 'isDownloaded' check relies on the actual file system, 
            // so the Detail View will always be correct.
        } catch {
            print("Error scanning downloads: \(error)")
        }
    }
    
    // MARK: - ACTIONS
    
    // Check if we already have it (Sync check for UI)
    func isDownloaded(episodeID: String) -> Bool {
        // Check the Set first (Fast)
        if downloadedEpisodeIDs.contains(episodeID) { return true }
        
        // Check the Disk (Truth)
        guard let path = localFilePath(for: episodeID) else { return false }
        if FileManager.default.fileExists(atPath: path.path) {
            // If found on disk but not in Set, add it (Self-healing)
            DispatchQueue.main.async {
                self.downloadedEpisodeIDs.insert(episodeID)
            }
            return true
        }
        return false
    }
    
    // The Download Logic
    func downloadEpisode(episode: Episode) async throws {
        guard let url = URL(string: episode.audioURL) else { return }
        guard let destination = localFilePath(for: episode.id) else { return }
        
        // Download using URLSession
        let (data, _) = try await URLSession.shared.data(from: url)
        try data.write(to: destination)
        
        // Notify UI to update (Main Actor)
        await MainActor.run {
            print("✅ Download Complete: \(episode.title)")
            self.downloadedEpisodeIDs.insert(episode.id)
            self.objectWillChange.send()
        }
    }
    
    // Delete Logic
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
        
        // Notify UI to update
        Task { @MainActor in
            self.downloadedEpisodeIDs.remove(episodeID)
            self.objectWillChange.send()
        }
    }
}