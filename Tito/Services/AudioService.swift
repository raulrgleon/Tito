import Foundation
import AVFoundation
import Combine

class AudioService: NSObject, ObservableObject {
    @Published var isMicrophoneEnabled: Bool = true
    @Published var error: String?
    
    private let audioEngine = AVAudioEngine()
    private var audioConverter: AudioConverterRef?
    private var audioFormat: AVAudioFormat?
    
    var audioOutputHandler: ((Data, TimeInterval) -> Void)?
    
    override init() {
        super.init()
        setupAudioEngine()
    }
    
    private func setupAudioEngine() {
        let inputNode = audioEngine.inputNode
        let inputFormat = inputNode.inputFormat(forBus: 0)
        
        audioFormat = AVAudioFormat(
            commonFormat: .pcmFormatFloat32,
            sampleRate: 48000,
            channels: 1,
            interleaved: false
        )
        
        guard audioFormat != nil else {
            error = "No se pudo crear el formato de audio"
            return
        }
        
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: inputFormat) { [weak self] buffer, time in
            self?.processAudioBuffer(buffer, time: time)
        }
    }
    
    func start() throws {
        guard !audioEngine.isRunning else { return }
        try audioEngine.start()
    }
    
    func stop() {
        guard audioEngine.isRunning else { return }
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        setupAudioEngine()
    }
    
    private func processAudioBuffer(_ buffer: AVAudioPCMBuffer, time: AVAudioTime) {
        guard isMicrophoneEnabled, let audioFormat = audioFormat else { return }
        
        guard let converter = createAudioConverter(from: buffer.format, to: audioFormat) else {
            return
        }
        
        guard let outputBuffer = AVAudioPCMBuffer(pcmFormat: audioFormat, frameCapacity: buffer.frameLength) else {
            return
        }
        
        var convertError: OSStatus = noErr
        
        var inputData = AudioBufferList()
        var outputData = AudioBufferList()
        
        guard let inputDataPointer = buffer.audioBufferList.pointee.mBuffers.mData else {
            return
        }
        
        let frameLengthInt = Int(buffer.frameLength)
        let inputChannelCount = Int(buffer.format.channelCount)
        let inputDataByteSize = UInt32(frameLengthInt * MemoryLayout<Float32>.size * inputChannelCount)
        
        inputData.mNumberBuffers = 1
        inputData.mBuffers.mNumberChannels = UInt32(inputChannelCount)
        inputData.mBuffers.mDataByteSize = inputDataByteSize
        inputData.mBuffers.mData = inputDataPointer
        
        guard let outputFloatData = outputBuffer.floatChannelData?[0] else {
            return
        }
        
        let outputChannelCount = Int(audioFormat.channelCount)
        let outputFrameCapacity = Int(outputBuffer.frameCapacity)
        let outputDataByteSize = UInt32(outputFrameCapacity * MemoryLayout<Float32>.size * outputChannelCount)
        
        outputData.mNumberBuffers = 1
        outputData.mBuffers.mNumberChannels = UInt32(outputChannelCount)
        outputData.mBuffers.mDataByteSize = outputDataByteSize
        outputData.mBuffers.mData = UnsafeMutableRawPointer(outputFloatData)
        
        convertError = AudioConverterConvertComplexBuffer(
            converter,
            UInt32(buffer.frameLength),
            &inputData,
            &outputData
        )
        
        guard convertError == noErr else {
            return
        }
        
        let outputFrameLength = outputBuffer.frameLength
        let dataCount = Int(outputFrameLength) * MemoryLayout<Float32>.size
        let data = Data(bytes: outputFloatData, count: dataCount)
        let timestamp = Double(time.sampleTime) / time.sampleRate
        
        audioOutputHandler?(data, timestamp)
    }
    
    private func createAudioConverter(from: AVAudioFormat, to: AVAudioFormat) -> AudioConverterRef? {
        var converter: AudioConverterRef?
        
        let status = AudioConverterNew(
            from.streamDescription,
            to.streamDescription,
            &converter
        )
        guard status == noErr, let converter = converter else {
            return nil
        }
        
        return converter
    }
    
    func configureForPreset(_ preset: Preset) {
        audioFormat = AVAudioFormat(
            commonFormat: .pcmFormatFloat32,
            sampleRate: preset.audioSampleRate,
            channels: 1,
            interleaved: false
        )
    }
}
