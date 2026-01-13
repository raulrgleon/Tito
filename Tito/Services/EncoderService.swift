import Foundation
import VideoToolbox
import AVFoundation
import CoreVideo

class EncoderService {
    private var compressionSession: VTCompressionSession?
    private var currentPreset: Preset
    private var currentBitrate: Int
    private let bitrateAdjustmentStep: Double = 0.15
    private let minBitrateRatio: Double = 0.5
    
    var encodedVideoHandler: ((Data, TimeInterval, Bool) -> Void)?
    var onFrameDropped: (() -> Void)?
    
    private var frameCount: Int64 = 0
    private let keyframeInterval: TimeInterval = 2.0
    
    init(preset: Preset) {
        self.currentPreset = preset
        self.currentBitrate = preset.initialVideoBitrate
    }
    
    func setupEncoder(preset: Preset) {
        currentPreset = preset
        currentBitrate = preset.initialVideoBitrate
        
        let width = Int32(preset.resolution.width)
        let height = Int32(preset.resolution.height)
        
        let status = VTCompressionSessionCreate(
            allocator: nil,
            width: width,
            height: height,
            codecType: kCMVideoCodecType_H264,
            encoderSpecification: nil,
            imageBufferAttributes: nil,
            compressedDataAllocator: nil,
            outputCallback: { outputCallbackRefCon, sourceFrameRefCon, status, infoFlags, sampleBuffer in
                guard let sampleBuffer = sampleBuffer else { return }
                let encoder = Unmanaged<EncoderService>.fromOpaque(outputCallbackRefCon!).takeUnretainedValue()
                encoder.handleEncodedFrame(sampleBuffer)
            },
            refcon: Unmanaged.passUnretained(self).toOpaque(),
            compressionSessionOut: &compressionSession
        )
        
        guard status == noErr, let session = compressionSession else {
            print("Error creating compression session: \(status)")
            return
        }
        
        VTSessionSetProperty(session, key: kVTCompressionPropertyKey_RealTime, value: kCFBooleanTrue)
        VTSessionSetProperty(session, key: kVTCompressionPropertyKey_ProfileLevel, value: kVTProfileLevel_H264_Baseline_AutoLevel)
        VTSessionSetProperty(session, key: kVTCompressionPropertyKey_AllowFrameReordering, value: kCFBooleanFalse)
        VTSessionSetProperty(session, key: kVTCompressionPropertyKey_MaxKeyFrameInterval, value: NSNumber(value: Int(preset.keyframeInterval * Double(preset.frameRate))))
        VTSessionSetProperty(session, key: kVTCompressionPropertyKey_MaxKeyFrameIntervalDuration, value: NSNumber(value: preset.keyframeInterval))
        
        updateBitrate(currentBitrate)
        
        VTCompressionSessionPrepareToEncodeFrames(session)
    }
    
    func encodeFrame(_ sampleBuffer: CMSampleBuffer) {
        guard let session = compressionSession,
              let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        
        let presentationTimeStamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
        let duration = CMSampleBufferGetDuration(sampleBuffer)
        
        let status = VTCompressionSessionEncodeFrame(
            session,
            imageBuffer: imageBuffer,
            presentationTimeStamp: presentationTimeStamp,
            duration: duration,
            frameProperties: nil,
            sourceFrameRefcon: nil,
            infoFlagsOut: nil
        )
        
        if status != noErr {
            onFrameDropped?()
        }
    }
    
    private func handleEncodedFrame(_ sampleBuffer: CMSampleBuffer) {
        guard let dataArray = CMSampleBufferGetDataBuffer(sampleBuffer) else {
            return
        }
        
        var length: Int = 0
        var dataPointer: UnsafeMutablePointer<Int8>?
        
        let status = CMBlockBufferGetDataPointer(
            dataArray,
            atOffset: 0,
            lengthAtOffsetOut: nil,
            totalLengthOut: &length,
            dataPointerOut: &dataPointer
        )
        
        guard status == noErr, let pointer = dataPointer else {
            return
        }
        
        let data = Data(bytes: pointer, count: length)
        let presentationTimeStamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
        let timestamp = CMTimeGetSeconds(presentationTimeStamp)
        
        let attachments = CMSampleBufferGetSampleAttachmentsArray(sampleBuffer, createIfNecessary: false)
        var isKeyframe = true
        if let attachments = attachments, CFArrayGetCount(attachments) > 0 {
            let attachment = unsafeBitCast(CFArrayGetValueAtIndex(attachments, 0), to: CFDictionary.self)
            if let attachmentDict = attachment as? [String: Any] {
                let isNotSync = attachmentDict[kCMSampleAttachmentKey_NotSync as String] as? Bool ?? false
                isKeyframe = !isNotSync
            }
        }
        
        encodedVideoHandler?(data, timestamp, isKeyframe)
    }
    
    func adjustBitrate(down: Bool) {
        let range = currentPreset.videoBitrateRange
        let step = Int(Double(currentBitrate) * bitrateAdjustmentStep)
        
        if down {
            let minBitrate = Int(Double(range.lowerBound) * minBitrateRatio)
            currentBitrate = max(minBitrate, currentBitrate - step)
        } else {
            currentBitrate = min(range.upperBound, currentBitrate + step)
        }
        
        updateBitrate(currentBitrate)
    }
    
    func resetBitrate() {
        currentBitrate = currentPreset.initialVideoBitrate
        updateBitrate(currentBitrate)
    }
    
    private func updateBitrate(_ bitrate: Int) {
        guard let session = compressionSession else { return }
        VTSessionSetProperty(session, key: kVTCompressionPropertyKey_AverageBitRate, value: NSNumber(value: bitrate * 1000))
        let dataRateLimits: [NSNumber] = [
            NSNumber(value: bitrate * 1000 * 8 / 8),
            NSNumber(value: 1)
        ]
        VTSessionSetProperty(session, key: kVTCompressionPropertyKey_DataRateLimits, value: dataRateLimits as CFArray)
    }
    
    func getCurrentBitrate() -> Int {
        return currentBitrate
    }
    
    func cleanup() {
        guard let session = compressionSession else { return }
        VTCompressionSessionCompleteFrames(session, untilPresentationTimeStamp: CMTime.invalid)
        VTCompressionSessionInvalidate(session)
        compressionSession = nil
    }
}
