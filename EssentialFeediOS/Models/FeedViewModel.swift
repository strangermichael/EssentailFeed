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
  private var state = State.pending {
    didSet {
      onChange?(self)
    }
  }
  var onChange: ((FeedViewModel) -> Void)?
  
  var isLoading: Bool {
    switch state {
    case .loading: return true
    default: return false
    }
  }
  
  var feed: [FeedImage]? {
    switch state {
    case let .loaded(feed): return feed
    default: return nil
    }
  }
  
  init(feedLoader: FeedLoader) {
    self.feedLoader = feedLoader
  }
  
  private enum State {
    case pending
    case loading
    case loaded([FeedImage])
    case failed
  }
  
  func loadFeed() {
    state = .loading
    feedLoader.load(completion: {[weak self] result in
      switch result {
      case .success(let images):
        self?.state = .loaded(images)
      case .failure:
        self?.state = .failed
      }
    })
  }
}
