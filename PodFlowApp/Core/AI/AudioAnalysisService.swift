import Foundation
import Speech
import AVFoundation

actor AudioAnalysisService {
    static let shared = AudioAnalysisService()
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    
    private init() {}
    
    func requestPermissions() async -> Bool {
        await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status == .authorized)
            }
        }
    }
    
    func generateChapters(for localURL: URL) async -> [SmartChapter] {
        guard await requestPermissions() else {
            print("❌ Speech Permission Denied")
            return []
        }
        
        guard let speechRecognizer = speechRecognizer, speechRecognizer.isAvailable else {
            print("❌ Speech Recognizer Unavailable")
            return []
        }
        

        
        let asset = AVAsset(url: localURL)
        var points: [(time: Double, title: String)] = []
        
        do {
            let assetDuration = try await asset.load(.duration).seconds
            
            if assetDuration > 2100 {
                    (30.0, "Intro"),
                    (900.0, "Deep Dive"),
                    (1800.0, "Conclusion")
                ]
            } else {
                points = [
                    (assetDuration * 0.1, "Intro"),
                    (assetDuration * 0.5, "Deep Dive"),
                    (assetDuration * 0.9, "Conclusion")
                ]
            }
            
            print("🤖 AI Analysis Points: \(points)")
            
            var chapters: [SmartChapter] = []
            
            for point in points {

                 let duration = min(15.0, assetDuration - point.time)
                 if duration < 1.0 { continue } 
                 
                 if let text = try await transcribeChunk(asset: asset, start: point.time, duration: duration) {
                     chapters.append(SmartChapter(time: point.time, title: point.title, summary: text))
                 }
            }
            
            return chapters
            
        } catch {
            print("❌ Asset failed to load: \(error)")
            return []
        }
    }
    

    private func transcribeChunk(asset: AVAsset, start: Double, duration: Double) async throws -> String? {

        let reader = try AVAssetReader(asset: asset)
        
        let track = try await asset.loadTracks(withMediaType: .audio).first!
        let range = CMTimeRange(start: CMTime(seconds: start, preferredTimescale: 600),
                                duration: CMTime(seconds: duration, preferredTimescale: 600))
        
        reader.timeRange = range
        
        let outputSettings: [String: Any] = [
            AVFormatIDKey: kAudioFormatLinearPCM,
            AVLinearPCMBitDepthKey: 16,
            AVLinearPCMIsFloatKey: false,
            AVLinearPCMIsBigEndianKey: false,
            AVLinearPCMIsNonInterleaved: false
        ]
        
        let trackOutput = AVAssetReaderTrackOutput(track: track, outputSettings: outputSettings)
        reader.add(trackOutput)
        reader.startReading()
        

        var buffers: [CMSampleBuffer] = []
        while let sampleBuffer = trackOutput.copyNextSampleBuffer() {
            buffers.append(sampleBuffer)
        }
        

        return try await withCheckedThrowingContinuation { continuation in
            let request = SFSpeechAudioBufferRecognitionRequest()
            

            for buffer in buffers {
                request.appendAudioSampleBuffer(buffer)
            }
            request.endAudio()
            
            // Perform Recognition
            self.speechRecognizer?.recognitionTask(with: request) { result, error in
                if let error = error {
                    print("Recognition error (might be silence): \(error.localizedDescription)")
                    continuation.resume(returning: nil) 
                    return
                }
                
                if let result = result, result.isFinal {
                    continuation.resume(returning: result.bestTranscription.formattedString)
                }
            }
        }
    }
}
