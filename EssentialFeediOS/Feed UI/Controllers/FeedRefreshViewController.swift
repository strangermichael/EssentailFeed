//
//  FeedRefreshViewController.swift
//  EssentialFeediOS
//
//  Created by Shengjun Xia on 2024/2/20.
//

import UIKit

//only depends on viewModel
final class FeedRefreshViewController: NSObject, FeedLoadingView {
  private(set) lazy var view = loadView()
  private let presenter: FeedPresenter
  
  init(presenter: FeedPresenter) {
    self.presenter = presenter
  }
  
  @objc func refresh() {
    presenter.loadFeed()
  }
  
  private func loadView() -> UIRefreshControl {
    let view = UIRefreshControl()
    view.addTarget(self, action: #selector(refresh), for: .valueChanged)
    return view
  }
  
  func display(isLoading: Bool) {
    isLoading ? view.beginRefreshing() : view.endRefreshing()
  }
}
