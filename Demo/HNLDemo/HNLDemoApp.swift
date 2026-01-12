import ComposableArchitecture
import SwiftUI

@main
struct HNLDemoApp: App {
    private let store: Store = .init(initialState: ListReducer.State(), reducer: ListReducer.init)

    // MARK: Body

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                ListScreen(store: store)
            }
        }
    }
}
