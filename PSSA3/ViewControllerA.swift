import UIKit
import AVFoundation
import Vision

class ViewControllerA: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    @IBOutlet weak var PreviewView: UIView!
    @IBOutlet weak var MaskView: UIView!
    @IBOutlet weak var NumberRegionView: UIView!
    @IBOutlet weak var results: UILabel!
    
    private let session = AVCaptureSession()
    let queue = DispatchQueue(label: "buffer queue")
    
    var recognizedText: String = ""
    //切り替えフラグ
    var shouldRestrictRecognitionRegion: Bool = true
    private var regionOfInterest: CGRect = .zero
    private var numberRegionBorderView: UIView?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var maskViewBorder: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer?.videoGravity = .resizeAspectFill
        previewLayer?.frame = UIScreen.main.bounds
        if let previewLayer = previewLayer {
            view.layer.addSublayer(previewLayer)
        }
        
        guard let superview = PreviewView.superview else {
            return
        }
        
        results.backgroundColor = .white
        results.textColor = .black
        results.numberOfLines = 0
        
        PreviewView.translatesAutoresizingMaskIntoConstraints = false
        MaskView.translatesAutoresizingMaskIntoConstraints = false
        NumberRegionView.translatesAutoresizingMaskIntoConstraints = false
        
        maskViewBorder = UIView()
        maskViewBorder?.translatesAutoresizingMaskIntoConstraints = false
        maskViewBorder?.layer.borderWidth = 2.0
        maskViewBorder?.layer.borderColor = UIColor.blue.cgColor
        maskViewBorder?.layer.masksToBounds = true
        view.addSubview(maskViewBorder!)
        
        NSLayoutConstraint.activate([
            PreviewView.topAnchor.constraint(equalTo: superview.topAnchor),
            PreviewView.bottomAnchor.constraint(equalTo: superview.bottomAnchor),
            PreviewView.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
            PreviewView.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
            
            MaskView.widthAnchor.constraint(equalTo: PreviewView.widthAnchor, multiplier: 0.8),
            MaskView.heightAnchor.constraint(equalTo: PreviewView.widthAnchor, multiplier: 0.8 * (7.0/5.0)),
            MaskView.centerXAnchor.constraint(equalTo: PreviewView.centerXAnchor),
            MaskView.centerYAnchor.constraint(equalTo: PreviewView.centerYAnchor),
            
            maskViewBorder!.topAnchor.constraint(equalTo: MaskView.topAnchor),
            maskViewBorder!.bottomAnchor.constraint(equalTo: MaskView.bottomAnchor),
            maskViewBorder!.leadingAnchor.constraint(equalTo: MaskView.leadingAnchor),
            maskViewBorder!.trailingAnchor.constraint(equalTo: MaskView.trailingAnchor),
            
            NumberRegionView.heightAnchor.constraint(equalTo: MaskView.heightAnchor, multiplier: 0.15), // Height is 1/5 of MaskView
                NumberRegionView.bottomAnchor.constraint(equalTo: MaskView.bottomAnchor), // Start at the bottom of MaskView
                NumberRegionView.leadingAnchor.constraint(equalTo: MaskView.leadingAnchor), // Start at the left of MaskView
                NumberRegionView.widthAnchor.constraint(equalTo: MaskView.widthAnchor, multiplier: 0.4), // Width is half of MaskView
        ])
        
        guard let device = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: device) else {
            return
        }
        
        if session.canAddInput(input) {
            session.addInput(input)
        }
        
        let output = AVCaptureVideoDataOutput()
        if session.canAddOutput(output) {
            session.addOutput(output)
        }
        
        output.setSampleBufferDelegate(self, queue: queue)
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = UIScreen.main.bounds
        view.layer.addSublayer(previewLayer)
        
        session.startRunning()
        view.bringSubviewToFront(results)
        view.bringSubviewToFront(maskViewBorder!)
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
        let request = VNRecognizeTextRequest { request, error in
            guard let results = request.results else {
                return
            }
            
            let texts = results.compactMap { $0 as? VNRecognizedTextObservation }.compactMap { $0.topCandidates(1).first?.string }
            
            // If texts are not empty, update the recognizedText. Otherwise, set it as an empty string.
            if !texts.isEmpty {
                texts.forEach {
//                    print($0)
                    self.recognizedText = $0
                }
            } else {
                self.recognizedText = ""
            }
            
            DispatchQueue.main.async {
                self.results.text = self.recognizedText
            }
        }
        request.preferBackgroundProcessing = true
        request.recognitionLanguages = ["en_US"]
        request.usesLanguageCorrection = true
        
        // Only set the region of interest if the flag is set to true
        if self.shouldRestrictRecognitionRegion {
            request.regionOfInterest = self.regionOfInterest
        }
        
        try? handler.perform([request])
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let maskViewBounds = MaskView.bounds
        let numberRegionViewBounds = NumberRegionView.bounds

        // regionOfInterest for NumberRegionView in terms of MaskView coordinates
        let roiX = numberRegionViewBounds.origin.x / maskViewBounds.size.width // should be 0.0 as it starts at the left of MaskView
        let roiY = numberRegionViewBounds.origin.y / maskViewBounds.size.height // should be 0.8 as it starts at 80% down from MaskView
        let roiWidth = numberRegionViewBounds.size.width / maskViewBounds.size.width // should be 0.5 as it's half the width of MaskView
        let roiHeight = numberRegionViewBounds.size.height / maskViewBounds.size.height // should be 0.2 as it's 20% the height of MaskView

        // Convert these MaskView coordinates to PreviewView coordinates
        let convertedROIX = (maskViewBounds.size.height - roiY * maskViewBounds.size.height - roiHeight * maskViewBounds.size.height) / PreviewView.bounds.size.height
        let convertedROIY = roiX * maskViewBounds.size.width / PreviewView.bounds.size.width
        let convertedROIWidth = roiHeight * maskViewBounds.size.height / PreviewView.bounds.size.height
        let convertedROIHeight = roiWidth * maskViewBounds.size.width / PreviewView.bounds.size.width

        regionOfInterest = CGRect(x: convertedROIX, y: convertedROIY, width: convertedROIWidth, height: convertedROIHeight)
//
//
        let convertedFrame = NumberRegionView.convert(NumberRegionView.bounds, to: PreviewView)
//        regionOfInterest = CGRect(x: (PreviewView.bounds.size.height - convertedFrame.origin.y - convertedFrame.size.height) / PreviewView.bounds.size.height,
//                                  y: convertedFrame.origin.x / PreviewView.bounds.size.width,
//                                  width: convertedFrame.size.height / PreviewView.bounds.size.height,
//                                  height: convertedFrame.size.width / PreviewView.bounds.size.width)
//
//        print(regionOfInterest)
        // NumberRegionViewの座標系変換後の枠線を追加して表示
        numberRegionBorderView?.removeFromSuperview()
        numberRegionBorderView = UIView(frame: convertedFrame)
        numberRegionBorderView!.layer.borderWidth = 2.0
        numberRegionBorderView!.layer.borderColor = UIColor.red.cgColor
        numberRegionBorderView!.layer.masksToBounds = true
        view.addSubview(numberRegionBorderView!)
        view.bringSubviewToFront(numberRegionBorderView!)
        
        // Update the frame of maskViewBorder in viewDidLayoutSubviews
        maskViewBorder?.frame = MaskView.frame
        view.bringSubviewToFront(results)
        view.bringSubviewToFront(maskViewBorder!)
    }
}
