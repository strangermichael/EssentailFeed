//
//  FeedLoaderPresentationAdapter.swift
//  EssentialFeediOS
//
//  Created by Shengjun Xia on 2024/2/24.
//

import EssentialFeed
import EssentialFeediOS
import EssentialFeedPresentation

final class FeedLoaderPresentationAdapter: FeedViewControllerDelegate {
  private let feedLoader: FeedLoader
  var presenter: LoadResourcePresenter<[FeedImage], FeedViewAdapter>?
  
  init(feedLoader: FeedLoader) {
    self.feedLoader = feedLoader
  }
  
  func didRequestFeedRefresh() {
    presenter?.didStartLoading()
    feedLoader.load { [weak self] result in
      switch result {
      case let .success(feed):
        self?.presenter?.didFinishLoadingResource(with: feed)
      case let .failure(error):
        self?.presenter?.didFinishLoading(with: error)
      }
    }
  }
}
