import ComposableArchitecture

@Reducer
struct ListReducer {
    // MARK: Destination

    @Reducer
    enum Destination {
        case details(DetailsReducer)
    }

    // MARK: State

    @ObservableState
    struct State: Equatable {
        @Presents var destination: Destination.State?
    }

    // MARK: Action

    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case destination(PresentationAction<Destination.Action>)

        case onAppear

        case didTapExample(HNLExample)
    }

    // MARK: Reducer

    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            _reduce(into: &state, action: action)
        }
        .ifLet(\.$destination, action: \.destination)
    }

    func _reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .destination(let action):
            return reduceDestination(into: &state, action: action)

        case .onAppear:
            return .none

        case .didTapExample(let example):
            state.destination = .details(.init(example: example))
            return .none

        default:
            return .none
        }
    }

    private func reduceDestination(
        into state: inout State,
        action: PresentationAction<Destination.Action>,
    ) -> Effect<Action> {
        switch action {
        case .presented:
            .none
        case .dismiss:
            .none
        }
    }
}

extension ListReducer.Destination.State: Equatable { }
