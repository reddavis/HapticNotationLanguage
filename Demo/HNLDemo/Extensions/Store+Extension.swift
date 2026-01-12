import ComposableArchitecture
import SwiftUI

extension Store {
    static func preview(_ initialState: State) -> Self {
        .init(
            initialState: initialState,
            reducer: { EmptyReducer() },
        )
    }

    static func preview<R: Reducer>(
        _ initialState: State,
        reducer: () -> R,
    ) -> Self where R.State == State, R.Action == Action, State: Equatable {
        .init(
            initialState: initialState,
            reducer: reducer,
        )
    }
}
