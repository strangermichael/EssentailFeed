//
//  FeedImageCell+TestHelpers.swift
//  EssentialFeediOSTests
//
//  Created by Shengjun Xia on 2024/2/24.
//

import Foundation
import EssentialFeediOS

extension FeedImageCell {
  var isShowingLocation: Bool {
    return !locationContainer.isHidden
  }
  
  var locationText: String? {
    locationLabel.text
  }
  
  var descriptionText: String? {
    descriptionLabel.text
  }
  
  var isShowingImageLoadingIndicator: Bool {
    feedImageContainer.isShimmering
  }
  
  var renderedImage: Data? {
    feedImageView.image?.pngData()
  }
  
  var isShowingRetryAction: Bool {
    !feedImageRetryButton.isHidden
  }
  
  func simulateRetryAction() {
    feedImageRetryButton.simulateTap()
  }
}
