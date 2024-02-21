//
//  FeedRefreshViewController.swift
//  EssentialFeediOS
//
//  Created by Shengjun Xia on 2024/2/20.
//

import UIKit
import EssentailFeed

final class FeedRefreshViewController: NSObject {
  private(set) lazy var view: UIRefreshControl = binded(UIRefreshControl())
  
  private let viewModel: FeedViewModel
  var onRefresh: (([FeedImage]) -> Void)?
  
  init(feedLoader: FeedLoader) {
    self.viewModel = FeedViewModel(feedLoader: feedLoader)
  }
  
  @objc func refresh() {
    viewModel.loadFeed()
  }
  
  private func binded(_ view: UIRefreshControl) -> UIRefreshControl {
    viewModel.onChange = { [weak self] viewModel in
      viewModel.isLoading ? self?.view.beginRefreshing() : self?.view.endRefreshing()
      if let feed = viewModel.feed {
        self?.onRefresh?(feed)
      }
    }
    view.addTarget(self, action: #selector(refresh), for: .valueChanged)
    return view
  }
}
