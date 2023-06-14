import UIKit
extension UIView {
    
    func addBackground(name: String) {
        // スクリーンサイズの取得
        let width = UIScreen.main.bounds.size.width
        let height = UIScreen.main.bounds.size.height

        //ナビバーとステータスバーの高さを取得
        var navigationBarHeight: CGFloat = 0
        var statusBarHeight: CGFloat = 0
        if let viewController = self.parentViewController {
            if let navigationController = viewController.navigationController {
                navigationBarHeight = navigationController.navigationBar.frame.size.height
            }
            if #available(iOS 13.0, *) {
                let windowScene = UIApplication.shared.connectedScenes
                    .first { $0.activationState == .foregroundActive } as? UIWindowScene
                let statusBarManager = windowScene?.statusBarManager
                statusBarHeight = statusBarManager?.statusBarFrame.height ?? 60.0
            } else {
                statusBarHeight = UIApplication.shared.statusBarFrame.height
            }
        }
        
        let heightPositionTop = navigationBarHeight + statusBarHeight
        let heightPositionBottom = height - heightPositionTop

        // スクリーンサイズにあわせてimageViewの配置
        let imageViewBackground = UIImageView(frame: CGRect(x: 0, y: heightPositionTop, width: width, height: heightPositionBottom))
        imageViewBackground.image = UIImage(named: name)
        imageViewBackground.contentMode = UIView.ContentMode.scaleAspectFill

        // subviewをメインビューに追加
        self.addSubview(imageViewBackground)
        // 加えたsubviewを、最背面に設置する
        self.sendSubviewToBack(imageViewBackground)
    }
}

// UIViewControllerを取得するための拡張
extension UIResponder {
    var parentViewController: UIViewController? {
        return next as? UIViewController ?? next?.parentViewController
    }
}
