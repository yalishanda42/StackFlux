public struct MutableStacklessStateMachine<State, Action>: MutableStateMachine {
    public let initialState: State
    public private(set) var currentState: State
    
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
    
    public func applied(action: Action) -> MutableStacklessStateMachine<State, Action> {
        .init(
            initial: initialState,
            current: newState(appliedAction: action),
            finishingCondition: finishingCondition,
            reducer: reducer
        )
    }
    
    public mutating func apply(action: Action) {
        currentState = newState(appliedAction: action)
    }
    
    private func newState(appliedAction action: Action) -> State {
        isInFinalState ? currentState : reducer(currentState, action)
    }
}

extension MutableStacklessStateMachine where State: Hashable {
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
