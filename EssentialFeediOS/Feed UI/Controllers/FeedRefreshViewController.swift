//
//  FeedRefreshViewController.swift
//  EssentialFeediOS
//
//  Created by Shengjun Xia on 2024/2/20.
//

import UIKit

protocol FeedRefreshViewControllerDelegate: AnyObject {
  func didRequestFeedRefresh()
}

//only depends on viewModel
final class FeedRefreshViewController: NSObject, FeedLoadingView {
  private(set) lazy var view = loadView()
  private let delegate: FeedRefreshViewControllerDelegate
  
  init(delegate: FeedRefreshViewControllerDelegate) {
    self.delegate = delegate
  }
  
  @objc func refresh() {
    delegate.didRequestFeedRefresh()
  }
  
  private func loadView() -> UIRefreshControl {
    let view = UIRefreshControl()
    view.addTarget(self, action: #selector(refresh), for: .valueChanged)
    return view
  }
  
  func display(viewModel: FeedLoadingViewModel) {
    viewModel.isLoading ? view.beginRefreshing() : view.endRefreshing()
  }
}
