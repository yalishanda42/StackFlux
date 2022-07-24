import XCTest
@testable import StackFlux

final class StacklessStateMachineTests: XCTestCase {
    private enum S: Int, Hashable, CaseIterable {
        case s0, s1, s2
    }
    
    private enum A: Int {
        case a0, a1, a2
    }
    
    private let testReducer: (S, A) -> S = {
        S(rawValue: ($0.rawValue + $1.rawValue) % S.allCases.count)!
    }
    
    func testInitWithNoCurrentTakesInitial() {
        let initial: S = .s1
        let sut = StacklessStateMachine<S, A>(
            initial: initial,
            reducer: testReducer,
            finishingCondition: { $0 == .s2 }
        )
        
        let result = sut.currentState
        
        XCTAssertEqual(result, initial)
    }
    
    func testInitHashableWithNoCurrentTakesInitial() {
        let initial: S = .s1
        let sut = StacklessStateMachine<S, A>(
            initial: initial,
            finalStates: [.s2],
            reducer: testReducer
        )
        
        let result = sut.currentState
        
        XCTAssertEqual(result, initial)
    }
    
    func testInitWithFinalState() {
        let sut = StacklessStateMachine<S, A>(
            initial: .s0,
            current: .s0,
            reducer: testReducer,
            finishingCondition: { $0 == .s0 }
        )
        
        let result = sut.isInFinalState
        
        XCTAssertTrue(result)
    }
    
    func testAppliedTransition() {
        let sut = StacklessStateMachine<S, A>(
            initial: .s0,
            current: .s0,
            reducer: testReducer,
            finishingCondition: { $0 == .s2 }
        )
        
        let result = sut
            .applied(action: .a2)
            .currentState
        
        XCTAssertEqual(result, S.s2)
    }
    
    func testTransitionToFinalState() {
        let sut = StacklessStateMachine<S, A>(
            initial: .s0,
            current: .s0,
            reducer: testReducer,
            finishingCondition: { $0 == .s2 }
        )
        
        let result = sut
            .applied(action: .a2)
            .isInFinalState
        
        XCTAssertTrue(result)
    }
    
    func testTwoTransitionsToFinalState() {
        let sut = StacklessStateMachine<S, A>(
            initial: .s0,
            current: .s0,
            reducer: testReducer,
            finishingCondition: { $0 == .s2 }
        )
        
        let result = sut
            .applied(action: .a1)
            .applied(action: .a1)
            .isInFinalState
        
        XCTAssertTrue(result)
    }
    
    func testTwoTransitionsToFinalStateFoundInSet() {
        let sut = StacklessStateMachine<S, A>(
            initial: .s0,
            current: .s0,
            finalStates: [.s2],
            reducer: testReducer
        )
        
        let result = sut
            .applied(action: .a1)
            .applied(action: .a1)
            .isInFinalState
        
        XCTAssertTrue(result)
    }
}
