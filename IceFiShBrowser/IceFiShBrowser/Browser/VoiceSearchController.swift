import AVFoundation
import Foundation
import Speech

@MainActor
@Observable
final class VoiceSearchController {
    var isListening = false
    var lastError: String?

    @ObservationIgnored private let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "en_US"))
    @ObservationIgnored private let audioEngine = AVAudioEngine()
    @ObservationIgnored private var request: SFSpeechAudioBufferRecognitionRequest?
    @ObservationIgnored private var task: SFSpeechRecognitionTask?

    var isAvailable: Bool {
        recognizer?.isAvailable == true
    }

    func toggle(update: @escaping (String) -> Void) {
        if isListening {
            stop()
        } else {
            Task { await start(update: update) }
        }
    }

    func start(update: @escaping (String) -> Void) async {
        stop()
        lastError = nil

        let speech = await requestSpeechAuthorization()
        guard speech else {
            lastError = "Speech recognition is not allowed."
            return
        }

        let mic = await requestMicAuthorization()
        guard mic else {
            lastError = "Microphone access is not allowed."
            return
        }

        guard let recognizer, recognizer.isAvailable else {
            lastError = "Voice search is unavailable on this device."
            return
        }

        let request = SFSpeechAudioBufferRecognitionRequest()
        request.shouldReportPartialResults = true
        self.request = request

        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.record, mode: .measurement, options: .duckOthers)
            try session.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            lastError = "Could not start the microphone."
            return
        }

        let input = audioEngine.inputNode
        let format = input.outputFormat(forBus: 0)
        input.removeTap(onBus: 0)
        input.installTap(onBus: 0, bufferSize: 1024, format: format) { buffer, _ in
            request.append(buffer)
        }

        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            lastError = "Could not start voice search."
            stop()
            return
        }

        isListening = true
        task = recognizer.recognitionTask(with: request) { [weak self] result, error in
            Task { @MainActor in
                if let text = result?.bestTranscription.formattedString {
                    update(text)
                }
                if result?.isFinal == true || error != nil {
                    self?.stop()
                }
            }
        }
    }

    func stop() {
        if audioEngine.isRunning {
            audioEngine.stop()
            audioEngine.inputNode.removeTap(onBus: 0)
        }
        request?.endAudio()
        task?.cancel()
        task = nil
        request = nil
        isListening = false
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }

    private func requestSpeechAuthorization() async -> Bool {
        await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status == .authorized)
            }
        }
    }

    private func requestMicAuthorization() async -> Bool {
        await AVAudioApplication.requestRecordPermission()
    }
}
