import UIKit

class cardTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var newCardID: String?
    var newCardCount: Int?
    
    @IBOutlet weak var tableView: UITableView!
    
    var pokeInfo = UserDefaults.standard.array(forKey: "PokeInfo") as? [[String: Any]] ?? []
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Update the pokeInfo each time the view appears
        pokeInfo = UserDefaults.standard.array(forKey: "PokeInfo") as? [[String: Any]] ?? []
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pokeInfo.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .white
        
        let cardLabel = UILabel()
        cardLabel.text = "Card Name"
        cardLabel.translatesAutoresizingMaskIntoConstraints = false // 追加
        headerView.addSubview(cardLabel)

        let countLabel = UILabel()
        countLabel.text = "Card Count"
        countLabel.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(countLabel)

        NSLayoutConstraint.activate([
            cardLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 30),
            countLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -50),
            cardLabel.trailingAnchor.constraint(equalTo: countLabel.leadingAnchor, constant: -30),
            // 以下2行で垂直方向の位置を調整します。headerViewの上下中心に合わせる例です。
            cardLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            countLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
        ])

        cardLabel.backgroundColor = UIColor.white
        countLabel.backgroundColor = UIColor.white

        return headerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:"Cell", for: indexPath)
        
        let cardLabel = cell.contentView.viewWithTag(1) as! UILabel
        let countLabel = cell.contentView.viewWithTag(2) as! UILabel
        
        let cellData = pokeInfo[indexPath.row]
        
        cardLabel.text = cellData["pokeID"] as? String
        if let cellCount = cellData["CardCount"] as? Int {
            countLabel.text = String(cellCount) // 数値を文字列に変換
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath:IndexPath) -> CGFloat {
        return 50
    }
    //枚数書き換えと消す機能
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let alert = UIAlertController(title: "Update Card Count", message: "Enter new card count", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.keyboardType = .numberPad
        }
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            if let textField = alert.textFields?.first, let newText = textField.text, let newCount = Int(newText) {
                self.pokeInfo[indexPath.row]["CardCount"] = newCount
                UserDefaults.standard.set(self.pokeInfo, forKey: "PokeInfo")
                tableView.reloadData()
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            pokeInfo.remove(at: indexPath.row)
            UserDefaults.standard.set(pokeInfo, forKey: "PokeInfo")
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}
