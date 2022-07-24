public struct StacklessStateMachine<State, Action>: StateMachine {
    public let initialState: State
    public let currentState: State
    
    public var isInFinalState: Bool {
        finishingCondition(currentState)
    }
    
    private let reducer: (State, Action) -> State
    private let finishingCondition: (State) -> Bool
    
    public init(
        initial: State,
        current: State? = nil,
        reducer: @escaping (State, Action) -> State,
        finishingCondition: @escaping (State) -> Bool
    ) {
        self.initialState = initial
        self.currentState = current ?? initial
        self.reducer = reducer
        self.finishingCondition = finishingCondition
    }
    
    public func applied(action: Action) -> StacklessStateMachine<State, Action> {
        .init(
            initial: initialState,
            current: reducer(currentState, action),
            reducer: reducer,
            finishingCondition: finishingCondition
        )
    }
}

extension StacklessStateMachine where State: Hashable {
    public init(
        initial: State,
        current: State? = nil,
        finalStates: Set<State>,
        reducer: @escaping (State, Action) -> State
    ) {
        self.init(
            initial: initial,
            current: current,
            reducer: reducer,
            finishingCondition: { finalStates.contains($0) }
        )
    }
}
