import UIKit
import Vision
import VisionKit

class orenoCardViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, VNDocumentCameraViewControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var cardIDLabel: UILabel!
    @IBOutlet weak var numLabel: UILabel!
    @IBOutlet weak var cameraSwich: UIButton!
    @IBOutlet weak var stringCheck: UIButton!
    @IBOutlet weak var inputCardID: UITextField!
    @IBOutlet weak var OpenDataBase: UIButton!
    @IBOutlet weak var inputnum: UITextField!
    @IBOutlet weak var dataIn: UIButton!
    @IBOutlet weak var delButton: UIButton!
    @IBOutlet weak var ocrtext: UITextView!

    var resultingText = ""
    var requests = [VNRequest]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addBackground(name: "BackGroundPicture")
        setupVision()
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toCardTable" {
            let destinationVC = segue.destination as! cardTableViewController
            if let cardID = inputCardID.text, let cardCount = Int(inputnum.text ?? "") {
                destinationVC.newCardID = cardID
                destinationVC.newCardCount = cardCount
            }
        }
    }
    
    @IBAction func dataIn(_ sender: Any) {
        print("ボタン押した")
        
        // inputCardID.textとinputnum.textが両方とも存在する場合のみデータをappend
        if let pokeID = inputCardID.text, !pokeID.isEmpty, let cardCountStr = inputnum.text, let cardCount = Int(cardCountStr) {
            
            var pokeInfo = UserDefaults.standard.array(forKey: "PokeInfo") as? [[String: Any]] ?? []
            
            if let index = pokeInfo.firstIndex(where: { $0["pokeID"] as? String == pokeID }) {
                var existingData = pokeInfo[index]
                if let existingCount = existingData["CardCount"] as? Int {
                    existingData["CardCount"] = existingCount + cardCount
                    pokeInfo[index] = existingData
                }
            } else {
                let newPokeData = ["pokeID": pokeID, "PokeName": "", "CardCount": cardCount] as [String : Any]
                pokeInfo.append(newPokeData)
            }
            
            UserDefaults.standard.set(pokeInfo, forKey: "PokeInfo")
            print(pokeInfo)
        } else {
            print("Either pokeID or cardCount is missing or invalid.")
        }
    }
    
    @IBAction func delButtonPush(_ sender: Any) {
        UserDefaults.standard.removeObject(forKey: "PokeInfo")
    }
    
    @IBAction func cameraON(_ sender: UIButton) {
            let documentCameraViewController = VNDocumentCameraViewController()
            documentCameraViewController.delegate = self
            present(documentCameraViewController, animated: true)
        }

        func setupVision() {
            let textRecognitionRequest = VNRecognizeTextRequest { request, _ in
                guard let observations = request.results as? [VNRecognizedTextObservation] else {
                    print("The observations are of an unexpected type.")
                    return
                }
                let maximumCandidates = 1
                for observation in observations {
                    guard let candidate = observation.topCandidates(maximumCandidates).first else { continue }
                    self.resultingText += candidate.string + "\n"
                }
            }
            textRecognitionRequest.recognitionLevel = .accurate
            self.requests = [textRecognitionRequest]
        }
        
        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
            controller.dismiss(animated: true)

            let textRecognitionWorkQueue = DispatchQueue(label: "TextRecognitionQueue", qos: .userInitiated, attributes: [], autoreleaseFrequency: .workItem)
            textRecognitionWorkQueue.async {
                self.resultingText = ""
                for pageIndex in 0 ..< scan.pageCount {
                    let image = scan.imageOfPage(at: pageIndex)
                    if let cgImage = image.cgImage {
                        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])

                        do {
                            try requestHandler.perform(self.requests)
                        } catch {
                            print(error)
                        }
                    }
                }
                DispatchQueue.main.async(execute: {
                    self.ocrtext.text = self.resultingText
                    self.inputCardID.text = self.resultingText
                    self.inputnum.text = "1"
                })
            }
        }
    }
