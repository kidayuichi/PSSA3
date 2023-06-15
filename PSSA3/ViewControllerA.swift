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
            
            NumberRegionView.heightAnchor.constraint(equalTo: MaskView.heightAnchor, multiplier: 0.15),
            NumberRegionView.bottomAnchor.constraint(equalTo: MaskView.bottomAnchor),
            NumberRegionView.leadingAnchor.constraint(equalTo: MaskView.leadingAnchor),
            NumberRegionView.widthAnchor.constraint(equalTo: MaskView.widthAnchor, multiplier: 0.4),
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
        
        if self.shouldRestrictRecognitionRegion {
            request.regionOfInterest = self.regionOfInterest
        }
        
        try? handler.perform([request])
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let maskViewBounds = MaskView.bounds
        let numberRegionViewBounds = NumberRegionView.bounds

        let roiX = numberRegionViewBounds.origin.x / maskViewBounds.size.width
        let roiY = numberRegionViewBounds.origin.y / maskViewBounds.size.height
        let roiWidth = numberRegionViewBounds.size.width / maskViewBounds.size.width
        let roiHeight = numberRegionViewBounds.size.height / maskViewBounds.size.height

        let convertedROIX = (maskViewBounds.size.height - roiY * maskViewBounds.size.height - roiHeight * maskViewBounds.size.height) / PreviewView.bounds.size.height
        let convertedROIY = roiX * maskViewBounds.size.width / PreviewView.bounds.size.width
        let convertedROIWidth = roiHeight * maskViewBounds.size.height / PreviewView.bounds.size.height
        let convertedROIHeight = roiWidth * maskViewBounds.size.width / PreviewView.bounds.size.width

        regionOfInterest = CGRect(x: convertedROIX, y: convertedROIY, width: convertedROIWidth, height: convertedROIHeight)

        let convertedFrame = NumberRegionView.convert(NumberRegionView.bounds, to: PreviewView)
//        print(regionOfInterest)

        // NumberRegionViewの座標系変換後の枠線を追加して表示
        numberRegionBorderView?.removeFromSuperview()
        numberRegionBorderView = UIView(frame: convertedFrame)
        numberRegionBorderView!.layer.borderWidth = 2.0
        numberRegionBorderView!.layer.borderColor = UIColor.red.cgColor
        numberRegionBorderView!.layer.masksToBounds = true
        view.addSubview(numberRegionBorderView!)
        view.bringSubviewToFront(numberRegionBorderView!)
        
        maskViewBorder?.frame = MaskView.frame
        view.bringSubviewToFront(results)
        view.bringSubviewToFront(maskViewBorder!)
    }
}
