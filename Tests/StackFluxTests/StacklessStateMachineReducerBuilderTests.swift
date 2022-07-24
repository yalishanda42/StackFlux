import XCTest
@testable import StackFlux

class StacklessStateMachineReducerBuilderTests: XCTestCase {
    private enum S: Int, Hashable, CaseIterable {
        case s0, s1, s2
    }
    
    private enum A: Int, Hashable, CaseIterable {
        case a0, a1, a2
    }
    
    private let testReducer: (S, A) -> S = {
        S(rawValue: ($0.rawValue + $1.rawValue) % S.allCases.count)!
    }
    
    func testOneTransition() {
        let sut = StacklessStateMachine<S, A>(initial: .s0, finalStates: []) {
            .s0 --> .a1 ==> .s1
        }
        
        let result = sut.applied(action: .a1).currentState
        
        XCTAssertEqual(result, S.s1)
    }
    
    func testNonexistingTransitionDoesntChangeState() {
        let sut = StacklessStateMachine<S, A>(initial: .s0, finalStates: []) {
            .s0 --> .a1 ==> .s1
        }
        
        let result = sut.applied(action: .a2).currentState
        
        XCTAssertEqual(result, S.s0)
    }
    
    func testThreeTransitions() {
        let sut = StacklessStateMachine<S, A>(initial: .s0, finalStates: []) {
            (.s0 --> .a1) ==> .s1
            (.s1 --> .a1) ==> .s2
            (.s2 --> .a1) ==> .s0
        }
        
        let result = sut
            .applied(action: .a1)
            .applied(action: .a1)
            .currentState
        
        XCTAssertEqual(result, S.s2)
    }
    
    func testForStatementInBuilder() {
        let sut = StacklessStateMachine<S, A>(initial: .s0, finalStates: [], reducerBuilder: {
            for s in S.allCases {
                for a in A.allCases {
                    s --> a ==> S(rawValue: (s.rawValue + a.rawValue) % S.allCases.count)!
                }
            }
        })
        
        let result = sut
            .applied(action: .a1)
            .applied(action: .a1)
            .currentState
        
        XCTAssertEqual(result, S.s2)
    }
    
    func testArrowSyntaxTransitions() {
        let sut = StacklessStateMachine<S, A>(initial: .s0, finalStates: []) {
            (.s0 --> .a0) ==> .s0
            (.s0 --> .a1) ==> .s1
            (.s0 --> .a2) ==> .s2
        }
        
        let result = sut
            .applied(action: .a2)
            .currentState
        
        XCTAssertEqual(result, S.s2)
    }
    
    func testBatchArrowSyntaxTransitions() {
        let sut = StacklessStateMachine<S, A>(initial: .s0, finalStates: []) {
            A.a0 ==> .s0
            A.a1 ==> .s1
        }
        
        let result = sut
            .applied(action: .a1)
            .currentState
        
        XCTAssertEqual(result, S.s1)
    }
    
    func testMixedArrowSyntaxTransitions() {
        let sut = StacklessStateMachine<S, A>(initial: .s0, finalStates: []) {
            A.a0 ==> .s0
            (.s0 --> .a1) ==> .s1
            S.s2 ==> .s0
        }
        
        let result = sut
            .applied(action: .a1)
            .currentState
        
        XCTAssertEqual(result, S.s1)
    }
}
