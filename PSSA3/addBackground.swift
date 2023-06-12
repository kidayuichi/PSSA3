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

            // スクリーンサイズにあわせてimageViewの配置
            let imageViewBackground = UIImageView(frame: CGRect(x: 0, y: 110, width: width, height: height - 110))
            //imageViewに背景画像を表示
            imageViewBackground.image = UIImage(named: name)

            // 画像の表示モードを変更。
            imageViewBackground.contentMode = UIView.ContentMode.scaleAspectFill

            // subviewをメインビューに追加
            self.addSubview(imageViewBackground)
            // 加えたsubviewを、最背面に設置する
            self.sendSubviewToBack(imageViewBackground)
        }
    }
