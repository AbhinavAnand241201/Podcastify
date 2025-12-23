import SwiftUI
import SwiftData

struct BookmarkInputSheet: View {
    let episodeID: String
    let currentTimestamp: Double
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) var dismiss
    @State private var noteText: String = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Timestamp: \(formatTime(currentTimestamp))")) {
                    TextField("Write a note...", text: $noteText)
                }
            }
            .navigationTitle("Add Bookmark")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let newBookmark = Bookmark(episodeID: episodeID, timestamp: currentTimestamp, note: noteText)
                        modelContext.insert(newBookmark)
                        dismiss()
                    }
                    .disabled(noteText.isEmpty)
                }
            }
        }
    }
    
    func formatTime(_ time: Double) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}