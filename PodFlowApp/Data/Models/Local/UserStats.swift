import Foundation
import SwiftData

@Model
class UserStats {
    @Attribute(.unique) var id: String = "MainUser"
    var totalMinutesListened: Double
    var genreCounts: [String: Int] // e.g. ["Tech": 5, "Comedy": 2]
    var dailyListening: [Date: Double] // Date -> Minutes
    
    init() {
        self.totalMinutesListened = 0
        self.genreCounts = [:]
        self.dailyListening = [:]
    }
}