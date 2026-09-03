import SwiftUI

@main
struct IceFiShBrowserApp: App {
    @State private var store = BrowserStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(store)
                .preferredColorScheme(.light)
        }
    }
}
