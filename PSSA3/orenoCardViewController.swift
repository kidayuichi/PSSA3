//
//  orenoCardViewController.swift
//  PSSA3
//
//  Created by user on 2023/06/13.
//

import UIKit

class orenoCardViewController: UIViewController {
    
    @IBOutlet weak var cardIDLabel: UILabel!
    @IBOutlet weak var numLabel: UILabel!
    @IBOutlet weak var cameraSwich: UIButton!
    @IBOutlet weak var stringCheck: UIButton!
    @IBOutlet weak var inputCardID: UITextField!
    @IBOutlet weak var OpenDataBase: UIButton!
    @IBOutlet weak var inputnum: UITextField!
    @IBOutlet weak var dataIn: UIButton!
    @IBOutlet weak var delButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addBackground(name: "BackGroundPicture")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toCardTable" {
            let destinationVC = segue.destination as! cardTableViewController
            if let cardID = inputCardID.text, let cardCount = Int(inputnum.text ?? "") {
                //                print("Input Card ID: \(cardID), Count: \(cardCount)")
                destinationVC.newCardID = cardID
                destinationVC.newCardCount = cardCount
            }
        }
    }
    
    @IBAction func dataIn(_ sender: Any) {
        print("dataInButtonPressed called") // デバッグ用のprint文
        
        // inputCardID.textとinputnum.textが両方とも存在する場合のみデータをappend
        if let pokeID = inputCardID.text, !pokeID.isEmpty, let cardCountStr = inputnum.text, let cardCount = Int(cardCountStr) {
            
            var pokeInfo = UserDefaults.standard.array(forKey: "PokeInfo") as? [[String: Any]] ?? []
            
            // Check if the pokeID already exists in the pokeInfo array
            if let index = pokeInfo.firstIndex(where: { $0["pokeID"] as? String == pokeID }) {
                // If it exists, update the CardCount
                if var existingData = pokeInfo[index] as? [String: Any], let existingCount = existingData["CardCount"] as? Int {
                    existingData["CardCount"] = existingCount + cardCount
                    pokeInfo[index] = existingData
                }
            } else {
                // If it does not exist, append the new data
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
    
}
