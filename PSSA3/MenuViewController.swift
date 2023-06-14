import UIKit

class MenuViewController: UIViewController ,
                           UITableViewDelegate{
    @IBOutlet weak var oreButton: UIButton!
    
    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var orenoCard: UILabel!
    
    var cardList = [String]()
    var cardNumList = [NSNumber]()

    var backgroundImageView: UIImageView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let imageViewBackground = UIImageView()
            imageViewBackground.image = UIImage(named: "BackGroundPicture")
            imageViewBackground.contentMode = .scaleToFill  // Changed here
            view.addSubview(imageViewBackground)
            view.sendSubviewToBack(imageViewBackground)
            self.backgroundImageView = imageViewBackground
        
        // 左スワイプジェスチャーレコグナイザーを追加
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeGesture(_:)))
        swipeGesture.direction = .left
        self.view.addGestureRecognizer(swipeGesture)
        
//        oreButton.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
//        self.view.addSubview(oreButton)
    }

//    @objc func didTapButton() {
//        let orenoCardViewController = self.storyboard?.instantiateViewController(withIdentifier: "orenoCardViewController") as! orenoCardViewController
//            self.navigationController?.pushViewController(orenoCardViewController, animated: true)
//        }
    
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // Adjust the frame of the background image view
        let width = UIScreen.main.bounds.size.width
        let height = UIScreen.main.bounds.size.height
        let navigationBarHeight = self.navigationController?.navigationBar.frame.size.height ?? 0
        let statusBarHeight: CGFloat
        if #available(iOS 13.0, *) {
            let windowScene = UIApplication.shared.connectedScenes
                .first { $0.activationState == .foregroundActive } as? UIWindowScene
            statusBarHeight = windowScene?.statusBarManager?.statusBarFrame.height ?? 0
        } else {
            statusBarHeight = UIApplication.shared.statusBarFrame.height
        }
        let heightPositionTop = navigationBarHeight + statusBarHeight
        backgroundImageView?.frame = CGRect(x: 0, y: heightPositionTop, width: width, height: height)  // Changed here
    }
}
