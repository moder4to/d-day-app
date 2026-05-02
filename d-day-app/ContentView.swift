import SwiftUI

struct ContentView: View {
    var body: some View {
        AppRootView()
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [
            CoupleProfile.self,
            DayEvent.self
        ], inMemory: true)
}
