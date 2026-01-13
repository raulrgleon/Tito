import XCTest
@testable import Tito

final class PresetTests: XCTestCase {
    
    func testStreetPreset() {
        let preset = Preset.street
        
        XCTAssertEqual(preset.resolution.width, 1280)
        XCTAssertEqual(preset.resolution.height, 720)
        XCTAssertEqual(preset.frameRate, 30)
        XCTAssertEqual(preset.initialVideoBitrate, 2500)
        XCTAssertTrue(preset.videoBitrateRange.contains(2500))
    }
    
    func testWiFiPreset() {
        let preset = Preset.wifi
        
        XCTAssertEqual(preset.resolution.width, 1920)
        XCTAssertEqual(preset.resolution.height, 1080)
        XCTAssertEqual(preset.frameRate, 30)
        XCTAssertEqual(preset.initialVideoBitrate, 5000)
        XCTAssertTrue(preset.videoBitrateRange.contains(5000))
    }
    
    func testHighQualityPreset() {
        let preset = Preset.highQuality
        
        XCTAssertEqual(preset.resolution.width, 1920)
        XCTAssertEqual(preset.resolution.height, 1080)
        XCTAssertEqual(preset.frameRate, 60)
        XCTAssertEqual(preset.initialVideoBitrate, 7500)
        XCTAssertTrue(preset.videoBitrateRange.contains(7500))
    }
    
    func testAllPresetsHaveAudioSettings() {
        for preset in Preset.allCases {
            XCTAssertEqual(preset.audioBitrate, 128)
            XCTAssertEqual(preset.audioSampleRate, 48000)
        }
    }
}
