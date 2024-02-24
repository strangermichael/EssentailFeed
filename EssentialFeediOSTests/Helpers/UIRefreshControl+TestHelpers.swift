//
//  UIRefreshControl+TestHelpers.swift
//  EssentialFeediOSTests
//
//  Created by Shengjun Xia on 2024/2/24.
//

import UIKit

extension UIControl {
  func simulatePullToRefresh() {
    simulate(event: .valueChanged)
  }
}
