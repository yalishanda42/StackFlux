// MARK: - Result Builder

@resultBuilder
public struct StacklessStateMachineReducerBuilder<State: Hashable, Action: Hashable> {
    public typealias Transition = (State, Action, State)
    public typealias Component = [Transition]
    
    public static func buildExpression(_ element: Transition) -> Component {
        [element]
    }
    
    public static func buildExpression(_ element: Component) -> Component {
        element
    }
    
    public static func buildOptional(_ component: Component?) -> Component {
        component ?? []
    }
    
    public static func buildEither(first component: Component) -> Component {
        component
    }
    
    public static func buildEither(second component: Component) -> Component {
        component
    }
    
    public static func buildArray(_ components: [Component]) -> Component {
        Array(components.joined())
    }
    
    public static func buildBlock(_ components: Component...) -> Component {
        Array(components.joined())
    }
    
    public static func buildLimitedAvailability(_ component: Component) -> Component {
        component
    }
    
    fileprivate struct StateActionPair: Hashable {
        // that is because implicit tuple conformance to Hashable
        // is not possible yet
        let state: State
        let action: Action
    }
    
    public static func buildFinalResult(_ component: Component) -> (State, Action) -> State {
        // Split transition triplets into
        // a state-action pair and an associated next state.
        let transitions = component.map {
            (StateActionPair(state: $0.0, action: $0.1), $0.2)
        }
        
        // The following will throw if the keys are not unique
        // i.e. if one tries to create a nondeterministic state machine
        // via supplying ambiguous transitions.
        let dictionary = Dictionary(uniqueKeysWithValues: transitions)
        
        // The reducer simply finds the state-action pair and returns
        // the associated next state with it.
        // If it doesn't find such a transition
        // then no state change should be performed.
        return { dictionary[StateActionPair(state: $0, action: $1)] ?? $0 }
    }
}

// MARK: - Inits with result builder

extension StacklessStateMachine where State: Hashable, Action: Hashable {
    public init(
        initial: State,
        current: State? = nil,
        finishingCondition: @escaping (State) -> Bool,
        @StacklessStateMachineReducerBuilder<State, Action> reducerBuilder: () -> (State, Action) -> State
    ) {
        self.init(
            initial: initial,
            current: current,
            finishingCondition: finishingCondition,
            reducer: reducerBuilder()
        )
    }
    
    public init(
        initial: State,
        current: State? = nil,
        finalStates: Set<State>,
        @StacklessStateMachineReducerBuilder<State, Action> reducerBuilder: () -> (State, Action) -> State
    ) {
        self.init(
            initial: initial,
            current: current,
            finalStates: finalStates,
            reducer: reducerBuilder()
        )
    }
}

// MARK: - Custom helper operator

precedencegroup TransitionPrecedence {
    higherThan: AssignmentPrecedence
    lowerThan: TernaryPrecedence
    associativity: none
    assignment: false
}

infix operator -->: TransitionPrecedence

public func --><S, A>(lhs: (S, A), rhs: S) -> (S, A, S) {
    (lhs.0, lhs.1, rhs)
}

public func --><S: CaseIterable, A>(lhs: A, rhs: S) -> [(S, A, S)] {
    S.allCases.map { ($0, lhs, rhs) }
}

public func --><S, A: CaseIterable>(lhs: S, rhs: S) -> [(S, A, S)] {
    A.allCases.map { (lhs, $0, rhs) }
}
