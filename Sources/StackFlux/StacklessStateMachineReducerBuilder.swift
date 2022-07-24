// MARK: - Result Builder

@resultBuilder
public struct StacklessStateMachineReducerBuilder<State: Hashable, Action: Hashable> {
    public struct Condition: Hashable {
        let state: State
        let action: Action
    }
    
    public struct Transition: Hashable {
        let condition: Condition
        let consequence: State
        
        init(from: State, taking: Action, to: State) {
            self.condition = .init(state: from, action: taking)
            self.consequence = to
        }
    }
    
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
    
    public static func buildFinalResult(_ component: Component) -> (State, Action) -> State {
        let transitions = Set(component) // uniquify
            .map {
                // Split transition triplets into
                // a state-action pair and an associated next state.
                ($0.condition, $0.consequence)
            }
        
        // The following will throw if the keys are not unique
        // i.e. if one tries to create a nondeterministic state machine
        // via supplying ambiguous transitions.
        let dictionary = Dictionary(uniqueKeysWithValues: transitions)
        
        // The reducer simply finds the state-action pair and returns
        // the associated next state with it.
        // If it doesn't find such a transition
        // then no state change should be performed.
        return { dictionary[Condition(state: $0, action: $1)] ?? $0 }
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

precedencegroup ConditionPrecedence {
    higherThan: TransitionPrecedence
    lowerThan: TernaryPrecedence
    associativity: none
    assignment: false
}

infix operator --> : ConditionPrecedence
infix operator ==> : TransitionPrecedence

public func --><S, A>(
    lhs: S,
    rhs: A
) -> StacklessStateMachineReducerBuilder<S, A>.Condition {
    .init(state: lhs, action: rhs)
}

public func ==><S, A>(
    lhs: StacklessStateMachineReducerBuilder<S, A>.Condition,
    rhs: S
) -> StacklessStateMachineReducerBuilder<S, A>.Transition {
    .init(from: lhs.state, taking: lhs.action, to: rhs)
}

public func ==><S: CaseIterable, A>(lhs: A, rhs: S) -> [StacklessStateMachineReducerBuilder<S, A>.Transition] {
    S.allCases.map { .init(from: $0, taking: lhs, to: rhs) }
}

public func ==><S, A: CaseIterable>(lhs: S, rhs: S) -> [StacklessStateMachineReducerBuilder<S, A>.Transition] {
    A.allCases.map { .init(from: lhs, taking: $0, to: rhs) }
}
