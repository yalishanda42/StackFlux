import XCTest
@testable import StackFlux

final class MutableStacklessStateMachineTests: XCTestCase {
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
        let sut = MutableStacklessStateMachine<S, A>(
            initial: initial,
            finishingCondition: { $0 == .s2 },
            reducer: testReducer
        )
        
        let result = sut.currentState
        
        XCTAssertEqual(result, initial)
    }
    
    func testInitHashableWithNoCurrentTakesInitial() {
        let initial: S = .s1
        let sut = MutableStacklessStateMachine<S, A>(
            initial: initial,
            finalStates: [.s2],
            reducer: testReducer
        )
        
        let result = sut.currentState
        
        XCTAssertEqual(result, initial)
    }
    
    func testInitWithFinalState() {
        let sut = MutableStacklessStateMachine<S, A>(
            initial: .s0,
            current: .s0,
            finishingCondition: { $0 == .s0 },
            reducer: testReducer
        )
        
        let result = sut.isInFinalState
        
        XCTAssertTrue(result)
    }
    
    func testAppliedTransition() {
        var sut = MutableStacklessStateMachine<S, A>(
            initial: .s0,
            current: .s0,
            finishingCondition: { $0 == .s2 },
            reducer: testReducer
        )
        
        sut.apply(action: .a2)
        let result = sut.currentState
        
        XCTAssertEqual(result, S.s2)
    }
    
    func testTransitionToFinalState() {
        var sut = MutableStacklessStateMachine<S, A>(
            initial: .s0,
            current: .s0,
            finishingCondition: { $0 == .s2 },
            reducer: testReducer
        )
        
        sut.apply(action: .a2)
        let result = sut.isInFinalState
        
        XCTAssertTrue(result)
    }
    
    func testTwoTransitionsToFinalState() {
        var sut = MutableStacklessStateMachine<S, A>(
            initial: .s0,
            current: .s0,
            finishingCondition: { $0 == .s2 },
            reducer: testReducer
        )
        
        sut.apply(action: .a1)
        sut.apply(action: .a1)
        let result = sut.isInFinalState
        
        XCTAssertTrue(result)
    }
    
    func testTwoTransitionsToFinalStateFoundInSet() {
        var sut = MutableStacklessStateMachine<S, A>(
            initial: .s0,
            current: .s0,
            finalStates: [.s2],
            reducer: testReducer
        )
        
        sut.apply(action: .a1)
        sut.apply(action: .a1)
        let result = sut.isInFinalState
        
        XCTAssertTrue(result)
    }
    
    func testFinalStateDoesNotChange() {
        var sut = MutableStacklessStateMachine<S, A>(
            initial: .s0,
            current: .s2,
            finalStates: [.s2],
            reducer: testReducer
        )
        
        sut.apply(action: .a1)
        let result = sut.currentState
        
        XCTAssertEqual(result, .s2)
    }
}
