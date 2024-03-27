//
//  UIRefreshControl+Helpers.swift
//  EssentialFeediOS
//
//  Created by Shengjun Xia on 2024/3/9.
//

import UIKit

extension UIRefreshControl {
  func update(isRefreshing: Bool) {
    isRefreshing ? beginRefreshing() : endRefreshing()
  }
}
