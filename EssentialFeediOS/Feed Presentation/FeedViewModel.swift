//
//  FeedViewModel.swift
//  EssentialFeediOS
//
//  Created by Shengjun Xia on 2024/2/21.
//

import Foundation
import EssentailFeed

final class FeedViewModel {
  typealias Observer<T> = (T) -> Void
  private let feedLoader: FeedLoader
  var onFeedLoaded: Observer<[FeedImage]>?
  var onLoadingStateChange: Observer<Bool>?
  
  init(feedLoader: FeedLoader) {
    self.feedLoader = feedLoader
  }
  
  func loadFeed() {
    onLoadingStateChange?(true)
    feedLoader.load(completion: {[weak self] result in
      switch result {
      case .success(let images):
        self?.onFeedLoaded?(images)
      case .failure:
        break
      }
      self?.onLoadingStateChange?(false)
    })
  }
}
