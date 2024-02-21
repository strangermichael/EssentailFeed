//
//  FeedViewModel.swift
//  EssentialFeediOS
//
//  Created by Shengjun Xia on 2024/2/21.
//

import Foundation
import EssentailFeed

final class FeedViewModel {
  private let feedLoader: FeedLoader
  var onChange: ((FeedViewModel) -> Void)?
  var onFeedLoaded: (([FeedImage]) -> Void)?
  
  private(set) var isLoading: Bool = false {
    didSet {
      onChange?(self)
    }
  }
  
  init(feedLoader: FeedLoader) {
    self.feedLoader = feedLoader
  }
  
  func loadFeed() {
    isLoading = true
    feedLoader.load(completion: {[weak self] result in
      switch result {
      case .success(let images):
        self?.onFeedLoaded?(images)
      case .failure:
        break
      }
      self?.isLoading = false
    })
  }
}
