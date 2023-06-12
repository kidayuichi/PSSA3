//
//  addBackground.swift
//  PSSA3
//
//  Created by user on 2023/06/12.
//

import UIKit
extension UIView {
    func addBackground(name: String) {
        // スクリーンサイズの取得
        let width = UIScreen.main.bounds.size.width
        let height = UIScreen.main.bounds.size.height
        //後で調べる
        if let viewController = self.parentViewController {
            if let navigationController = viewController.navigationController {
                //ナビバーの高さ
                let navigationBarHeight = navigationController.navigationBar.frame.size.height
                
                //ステータスバーの高さ
                var statusBarHeight: CGFloat = 0.0
                if #available(iOS 13.0, *) {
                    let windowScene = UIApplication.shared.connectedScenes
                        .first { $0.activationState == .foregroundActive } as? UIWindowScene
                    let statusBarManager = windowScene?.statusBarManager
                    statusBarHeight = statusBarManager?.statusBarFrame.height ?? 60.0
                } else {
                    statusBarHeight = UIApplication.shared.statusBarFrame.height
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
    }
}

// UIViewControllerを取得するための拡張
extension UIResponder {
    var parentViewController: UIViewController? {
        return next as? UIViewController ?? next?.parentViewController
    }
}
