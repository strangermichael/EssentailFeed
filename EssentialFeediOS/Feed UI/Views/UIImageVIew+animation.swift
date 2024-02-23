//
//  UIImageVIew+animation.swift
//  EssentialFeediOS
//
//  Created by Shengjun Xia on 2024/2/23.
//

import UIKit

extension UIImageView {
  func setImageAnimated(_ newImage: UIImage?) {
    image = newImage
    guard newImage != nil else { return }
    alpha = 0
    UIView.animate(withDuration: 0.25) {
      self.alpha = 1
    }
  }
}

