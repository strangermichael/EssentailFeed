//
//  FeedPresenter.swift
//  EssentialFeediOS
//
//  Created by Shengjun Xia on 2024/2/22.
//

import Foundation
import EssentailFeed

//benefit, only need to change view model if add new property
struct FeedLoadingViewModel {
  let isLoading: Bool
}

protocol FeedLoadingView {
  func display(viewModel: FeedLoadingViewModel)
}

struct FeedViewModel {
  let feed: [FeedImage]
}

protocol FeedView {
  func display(viewModel: FeedViewModel)
}

final class FeedPresenter {
  private let feedLoader: FeedLoader
  var feedView: FeedView?
  var loadingView: FeedLoadingView?
  
  init(feedLoader: FeedLoader) {
    self.feedLoader = feedLoader
  }
  
  func loadFeed() {
    loadingView?.display(viewModel: FeedLoadingViewModel(isLoading: true))
    feedLoader.load(completion: {[weak self] result in
      switch result {
      case .success(let images):
        self?.feedView?.display(viewModel: FeedViewModel(feed: images))
      case .failure:
        break
      }
      self?.loadingView?.display(viewModel: FeedLoadingViewModel(isLoading: false))
    })
  }
}

