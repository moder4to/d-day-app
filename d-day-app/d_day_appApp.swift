import SwiftData
import SwiftUI

@main
struct d_day_appApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [
            CoupleProfile.self,
            DayEvent.self
        ])
    }
}
