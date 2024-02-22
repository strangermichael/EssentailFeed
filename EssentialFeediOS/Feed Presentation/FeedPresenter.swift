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
  private let feedView: FeedView
  private let loadingView: FeedLoadingView
  
  init(feedView: FeedView, loadingView: FeedLoadingView) {
    self.feedView = feedView
    self.loadingView = loadingView
  }
  
  func didStartLoadingFeed() {
    loadingView.display(viewModel: FeedLoadingViewModel(isLoading: true))
  }
  
  func didFinishLoadingFeed(with feed: [FeedImage]) {
    feedView.display(viewModel: FeedViewModel(feed: feed))
    loadingView.display(viewModel: FeedLoadingViewModel(isLoading: false))
  }
  
  func didFinishLoadingFeed(with error: Error) {
    loadingView.display(viewModel: FeedLoadingViewModel(isLoading: false))
  }
}

