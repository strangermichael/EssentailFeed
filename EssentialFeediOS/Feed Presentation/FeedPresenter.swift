//
//  FeedPresenter.swift
//  EssentialFeediOS
//
//  Created by Shengjun Xia on 2024/2/22.
//

import Foundation
import EssentailFeed

protocol FeedView {
  func display(isLoading: Bool)
  func display(feed: [FeedImage])
}

final class FeedPresenter {
  private let feedLoader: FeedLoader
  var view: FeedView?
  
  init(feedLoader: FeedLoader) {
    self.feedLoader = feedLoader
  }
  
  func loadFeed() {
    view?.display(isLoading: true)
    feedLoader.load(completion: {[weak self] result in
      switch result {
      case .success(let images):
        self?.view?.display(feed: images)
      case .failure:
        break
      }
      self?.view?.display(isLoading: false)
    })
  }
}

