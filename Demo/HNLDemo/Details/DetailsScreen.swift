import ComposableArchitecture
import SwiftUI

struct DetailsScreen: View {
    @Bindable var store: StoreOf<DetailsReducer>

    // MARK: Body

    var body: some View {
        List {
            Section("Notation") {
                Text(store.example.notation)
                    .font(.subheadline)
                    .monospaced()
            }
        }
        .safeAreaInset(edge: .bottom) {
            Button("Play") {
                store.send(.didTapPlayButton)
            }
            .buttonSizing(.flexible)
            .buttonStyle(.glassProminent)
            .controlSize(.large)
            .padding()
        }
        .navigationTitle(store.example.title)
        .onAppear { store.send(.onAppear) }
    }
}

// MARK: Preview

#Preview("Idle") {
    DetailsScreen.idle
}

extension DetailsScreen {
    static func fixture(
        _ state: DetailsReducer.State = .init(example: .simpleTaps),
    ) -> some View {
        NavigationStack {
            DetailsScreen(store: .preview(state))
        }
    }

    static var idle: some View {
        fixture()
    }
}
