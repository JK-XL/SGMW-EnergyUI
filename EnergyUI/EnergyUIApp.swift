import SwiftUI

@main
struct EnergyUIApp: App {
    @StateObject private var model = DashboardModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(model)
        }
    }
}
