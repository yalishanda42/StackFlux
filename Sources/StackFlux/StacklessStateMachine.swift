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
        finishingCondition: @escaping (State) -> Bool,
        reducer: @escaping (State, Action) -> State
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
            finishingCondition: finishingCondition,
            reducer: reducer
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
            finishingCondition: { finalStates.contains($0) },
            reducer: reducer
        )
    }
}
