import ComposableArchitecture

@Reducer
struct DetailsReducer {
    @Dependency(\.detailsProvider) private var provider

    // MARK: State

    @ObservableState
    struct State: Equatable {
        var example: HNLExample
    }

    // MARK: Action

    enum Action: BindableAction {
        case binding(BindingAction<State>)

        case onAppear

        case didTapPlayButton
    }

    // MARK: Reducer

    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            _reduce(into: &state, action: action)
        }
    }

    func _reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .onAppear:
            return .none

        case .didTapPlayButton:
            let example = state.example
            return .run { _ in
                try? await provider.play(example)
            }

        default:
            return .none
        }
    }
}
