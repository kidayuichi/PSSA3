import UIKit

class MenuViewController: UIViewController ,
                           UITableViewDelegate{

    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var orenoCard: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 左スワイプジェスチャーレコグナイザーを追加
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeGesture(_:)))
        swipeGesture.direction = .left
        self.view.addGestureRecognizer(swipeGesture)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // メニュー画面の位置
        let menuPosition = self.menuView.layer.position
        // 初期位置設定
        self.menuView.layer.position.x = -self.menuView.frame.width
        // 表示アニメーション
        UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseOut, animations: {
            self.menuView.layer.position.x = menuPosition.x
        }, completion: nil)
    }

    // メニュー外をタップした場合に非表示にする
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        for touch in touches {
            if touch.view?.tag == 1 {
                UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn, animations: {
                    self.menuView.layer.position.x = -self.menuView.frame.width
                }, completion: { _ in
                    self.dismiss(animated: true, completion: nil)
                })
            }
        }
    }

    @objc func handleSwipeGesture(_ gesture: UISwipeGestureRecognizer) {
        if gesture.direction == .left {
            // スワイプが左方向の場合にはメニューを閉じる
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn, animations: {
                self.menuView.layer.position.x = -self.menuView.frame.width
            }, completion: { _ in
                self.dismiss(animated: true, completion: nil)
            })
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
