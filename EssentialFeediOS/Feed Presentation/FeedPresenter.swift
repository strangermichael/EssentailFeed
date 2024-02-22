//
//  FeedPresenter.swift
//  EssentialFeediOS
//
//  Created by Shengjun Xia on 2024/2/22.
//

import Foundation
import EssentailFeed

protocol FeedLoadingView: AnyObject {
  func display(isLoading: Bool)
}

protocol FeedView {
  func display(feed: [FeedImage])
}

final class FeedPresenter {
  private let feedLoader: FeedLoader
  var feedView: FeedView?
  weak var loadingView: FeedLoadingView?
  
  init(feedLoader: FeedLoader) {
    self.feedLoader = feedLoader
  }
  
  func loadFeed() {
    loadingView?.display(isLoading: true)
    feedLoader.load(completion: {[weak self] result in
      switch result {
      case .success(let images):
        self?.feedView?.display(feed: images)
      case .failure:
        break
      }
      self?.loadingView?.display(isLoading: false)
    })
  }
}

