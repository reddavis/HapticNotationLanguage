import ComposableArchitecture
import SwiftUI

struct ListScreen: View {
    @Bindable var store: StoreOf<ListReducer>

    // MARK: Body

    var body: some View {
        List(HNLExample.all) { example in
            Button {
                 store.send(.didTapExample(example))
             } label: {
                 HStack {
                     Text(example.title)
                     Spacer()
                     Image(systemName: "chevron.right")
                         .font(.system(size: 14, weight: .semibold))
                         .foregroundStyle(.tertiary)
                 }
             }
             .foregroundStyle(.primary)
        }
        .navigationTitle("HNL Examples")
        .onAppear { store.send(.onAppear) }
        .navigationDestination(item: $store.scope(state: \.destination, action: \.destination)) {
            switch $0.case {
            case .details(let store):
                DetailsScreen(store: store)
            }
        }
    }
}

// MARK: Preview

#Preview("Idle") {
    ListScreen.idle
}

extension ListScreen {
    static func fixture(
        _ state: ListReducer.State = .init(),
    ) -> some View {
        NavigationStack {
            ListScreen(store: .preview(state))
        }
    }

    static var idle: some View {
        fixture()
    }
}
