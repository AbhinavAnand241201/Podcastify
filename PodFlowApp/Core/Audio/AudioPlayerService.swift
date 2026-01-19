import Foundation
import AVFoundation
import Combine

class AudioPlayerService: NSObject, ObservableObject {
    static let shared = AudioPlayerService()
    
    var player: AVPlayer?
    

    @Published var isPlaying: Bool = false
    @Published var currentTime: Double = 0.0
    @Published var duration: Double = 0.0
    @Published var sleepTimerActive: Bool = false
    @Published var sleepTimeRemaining: TimeInterval = 0
    
    private var timeObserver: Any?
    private var sleepTimer: Timer?
    private var fadeTimer: Timer?
    
    private override init() {
        super.init()
        setupAudioSession()
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .spokenAudio)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set audio session: \(error)")
        }
    }
    

    func play(episode: Episode) {
        let downloadManager = DownloadManager.shared
        var urlToPlay: URL?
        

        if let localURL = downloadManager.localFilePath(for: episode.id),
           downloadManager.isDownloaded(episodeID: episode.id) {
            print("🎧 Playing from Offline Storage")
            urlToPlay = localURL
        } else {
            print("☁️ Streaming from Web")
            if let url = URL(string: episode.audioURL) {
                urlToPlay = url
            }
        }
        
        guard let finalURL = urlToPlay else { return }
        
        let item = AVPlayerItem(url: finalURL)
        
        let item = AVPlayerItem(url: finalURL)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(playerDidFinishPlaying),
                                               name: .AVPlayerItemDidPlayToEndTime,
                                               object: item)
        
        player = AVPlayer(playerItem: item)
        player?.play()
        isPlaying = true
        setupTimeObserver()
    }
    
    func resume() {
        player?.play()
        isPlaying = true
    }
    
    func pause() {
        player?.pause()
        isPlaying = false
    }
    
    func seek(to time: Double) {
        let cmTime = CMTime(seconds: time, preferredTimescale: 600)
        player?.seek(to: cmTime)
    }
    
    func setSpeed(_ speed: Float) {
        if isPlaying {
            player?.rate = speed
        }
    }
    
    @objc private func playerDidFinishPlaying() {
        DispatchQueue.main.async {
            self.isPlaying = false
            self.currentTime = 0
        }
    }
    

    func startSleepTimer(minutes: Double) {
        cancelSleepTimer() // Reset if exists
        
        let totalSeconds = minutes * 60
        self.sleepTimeRemaining = totalSeconds
        self.sleepTimerActive = true
        
        self.sleepTimerActive = true
        
        self.sleepTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            
            self.sleepTimeRemaining -= 1
            
            if self.sleepTimeRemaining <= 10 && self.sleepTimeRemaining > 0 {
                self.fadeOutVolume()
            }
            
            if self.sleepTimeRemaining <= 0 {
                self.pause()
                self.cancelSleepTimer()
            }
        }
    }
    
    func cancelSleepTimer() {
        sleepTimer?.invalidate()
        sleepTimer = nil
        sleepTimerActive = false
        sleepTimeRemaining = 0
        player?.volume = 1.0
    }
    
    private func fadeOutVolume() {
        guard let player = player else { return }
        if player.volume > 0.1 {
            player.volume -= 0.1
        }
    }
    

    private func setupTimeObserver() {
        if let observer = timeObserver {
            player?.removeTimeObserver(observer)
            timeObserver = nil
        }
        
        timeObserver = player?.addPeriodicTimeObserver(forInterval: CMTime(seconds: 0.5, preferredTimescale: 600), queue: .main) { [weak self] time in
            guard let self = self else { return }
            self.currentTime = time.seconds
            
            if let duration = self.player?.currentItem?.duration.seconds, !duration.isNaN {
                self.duration = duration
            }
        }
    }
}