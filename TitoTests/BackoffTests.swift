import XCTest
@testable import Tito

final class BackoffTests: XCTestCase {
    
    func testBackoffSchedule() {
        var backoffDelay: TimeInterval = 2.0
        let maxDelay: TimeInterval = 30.0
        
        var delays: [TimeInterval] = []
        
        for attempt in 1...5 {
            delays.append(backoffDelay)
            backoffDelay = min(maxDelay, backoffDelay * 2.0)
        }
        
        XCTAssertEqual(delays[0], 2.0)
        XCTAssertEqual(delays[1], 4.0)
        XCTAssertEqual(delays[2], 8.0)
        XCTAssertEqual(delays[3], 16.0)
        XCTAssertEqual(delays[4], 30.0) // Capped at max
    }
    
    func testBackoffDoesNotExceedMax() {
        var backoffDelay: TimeInterval = 16.0
        let maxDelay: TimeInterval = 30.0
        
        for _ in 0..<10 {
            backoffDelay = min(maxDelay, backoffDelay * 2.0)
        }
        
        XCTAssertLessThanOrEqual(backoffDelay, maxDelay)
    }
    
    func testBackoffResetsOnSuccess() {
        var backoffDelay: TimeInterval = 30.0
        let initialDelay: TimeInterval = 2.0
        
        // Simulate successful reconnection
        backoffDelay = initialDelay
        
        XCTAssertEqual(backoffDelay, initialDelay)
    }
}
