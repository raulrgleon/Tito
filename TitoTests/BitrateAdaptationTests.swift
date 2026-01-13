import XCTest
@testable import Tito

final class BitrateAdaptationTests: XCTestCase {
    
    func testBitrateAdjustmentDown() {
        let encoder = EncoderService(preset: .street)
        encoder.setupEncoder(preset: .street)
        
        let initialBitrate = encoder.getCurrentBitrate()
        encoder.adjustBitrate(down: true)
        let adjustedBitrate = encoder.getCurrentBitrate()
        
        XCTAssertLessThan(adjustedBitrate, initialBitrate)
    }
    
    func testBitrateAdjustmentUp() {
        let encoder = EncoderService(preset: .street)
        encoder.setupEncoder(preset: .street)
        
        // First adjust down
        encoder.adjustBitrate(down: true)
        let loweredBitrate = encoder.getCurrentBitrate()
        
        // Then adjust up
        encoder.adjustBitrate(down: false)
        let raisedBitrate = encoder.getCurrentBitrate()
        
        XCTAssertGreaterThan(raisedBitrate, loweredBitrate)
    }
    
    func testBitrateDoesNotGoBelowMinimum() {
        let encoder = EncoderService(preset: .street)
        encoder.setupEncoder(preset: .street)
        
        let minBitrate = Int(Double(Preset.street.videoBitrateRange.lowerBound) * 0.5)
        
        // Adjust down multiple times
        for _ in 0..<10 {
            encoder.adjustBitrate(down: true)
        }
        
        let finalBitrate = encoder.getCurrentBitrate()
        XCTAssertGreaterThanOrEqual(finalBitrate, minBitrate)
    }
    
    func testBitrateDoesNotExceedMaximum() {
        let encoder = EncoderService(preset: .street)
        encoder.setupEncoder(preset: .street)
        
        let maxBitrate = Preset.street.videoBitrateRange.upperBound
        
        // Adjust up multiple times
        for _ in 0..<10 {
            encoder.adjustBitrate(down: false)
        }
        
        let finalBitrate = encoder.getCurrentBitrate()
        XCTAssertLessThanOrEqual(finalBitrate, maxBitrate)
    }
    
    func testResetBitrate() {
        let encoder = EncoderService(preset: .street)
        encoder.setupEncoder(preset: .street)
        
        let initialBitrate = encoder.getCurrentBitrate()
        encoder.adjustBitrate(down: true)
        encoder.adjustBitrate(down: true)
        
        encoder.resetBitrate()
        let resetBitrate = encoder.getCurrentBitrate()
        
        XCTAssertEqual(resetBitrate, initialBitrate)
    }
}
