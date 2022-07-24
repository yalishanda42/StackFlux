public protocol StateMachine {
    associatedtype State
    associatedtype Action
    
    var initialState: State { get }
    var currentState: State { get }
    
    var isInFinalState: Bool { get }
    
    func applied(action: Action) -> Self
}

public protocol MutableStateMachine: StateMachine {
    mutating func apply(action: Action)
}
