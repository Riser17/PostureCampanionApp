import Foundation
import AVFoundation
import Vision
import Combine

enum PostureState: CustomStringConvertible, Equatable {
    case good
    case slightSlouch
    case severeSlouch
    case unknown
    case cameraError(String)

    var description: String {
        switch self {
        case .good: return "Good"
        case .slightSlouch: return "Slight Slouch"
        case .severeSlouch: return "Severe Slouch"
        case .unknown: return "Initializing..."
        case .cameraError(let msg): return "Error: \(msg)"
        }
    }
}

protocol PostureEngineDelegate: AnyObject {
    func postureEngine(_ engine: PostureEngine, didUpdateState state: PostureState)
}

class PostureEngine: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    private let captureSession = AVCaptureSession()
    private var poseRequest = VNDetectHumanBodyPoseRequest()

    weak var delegate: PostureEngineDelegate?

    private var baselineNeckShoulderDistance: CGFloat = 0
    private var isCalibrated = false
    private var calibrationRequested = false

    func start() {
        DispatchQueue.global(qos: .userInitiated).async {
            self.setupSession()
        }
    }

    func stop() {
        captureSession.stopRunning()
    }

    // Triggered by the UI to set the current posture as the "Good" baseline
    func triggerCalibration() {
        calibrationRequested = true
    }

    private func setupSession() {
        captureSession.beginConfiguration()

        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else {
            print("CRITICAL ERROR: No front camera found.")
            DispatchQueue.main.async {
                self.delegate?.postureEngine(self, didUpdateState: .cameraError("No camera found"))
            }
            captureSession.commitConfiguration()
            return
        }

        do {
            let input = try AVCaptureDeviceInput(device: videoDevice)
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
            }
        } catch {
            print("CRITICAL ERROR: Could not create input: \(error)")
            DispatchQueue.main.async {
                self.delegate?.postureEngine(self, didUpdateState: .cameraError("Input error"))
            }
            captureSession.commitConfiguration()
            return
        }

        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "posture.video.queue"))

        if captureSession.canAddOutput(videoOutput) {
            captureSession.addOutput(videoOutput)
        }

        captureSession.sessionPreset = .medium
        captureSession.commitConfiguration()

        captureSession.startRunning()
        print("PostureEngine: Camera session started successfully.")
    }

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        let requestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])

        do {
            try requestHandler.perform([poseRequest])

            if let observations = poseRequest.results as? [VNHumanBodyPoseObservation],
               let pose = observations.first {
                analyzePosture(pose: pose)
            }
        } catch {
            print("Vision error: \(error)")
        }
    }

    private func analyzePosture(pose: VNHumanBodyPoseObservation) {
        do {
            let nose = try pose.recognizedPoint(.nose)
            let leftShoulder = try pose.recognizedPoint(.leftShoulder)
            let rightShoulder = try pose.recognizedPoint(.rightShoulder)

            guard nose.confidence > 0.5, leftShoulder.confidence > 0.5, rightShoulder.confidence > 0.5 else {
                delegate?.postureEngine(self, didUpdateState: .unknown)
                return
            }

            let shoulderMidpointY = (leftShoulder.location.y + rightShoulder.location.y) / 2
            let verticalDistance = abs(nose.location.y - shoulderMidpointY)

            // Calibrate if requested by UI or if not yet calibrated
            if calibrationRequested || !isCalibrated {
                self.baselineNeckShoulderDistance = verticalDistance
                self.isCalibrated = true
                self.calibrationRequested = false
                print("PostureEngine: Calibrated baseline to \(verticalDistance)")
            }

            let ratio = verticalDistance / baselineNeckShoulderDistance

            if ratio > 0.95 {
                delegate?.postureEngine(self, didUpdateState: .good)
            } else if ratio > 0.8 {
                delegate?.postureEngine(self, didUpdateState: .slightSlouch)
            } else {
                delegate?.postureEngine(self, didUpdateState: .severeSlouch)
            }

        } catch {
            delegate?.postureEngine(self, didUpdateState: .unknown)
        }
    }
}
