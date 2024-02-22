//
//  FeedRefreshViewController.swift
//  EssentialFeediOS
//
//  Created by Shengjun Xia on 2024/2/20.
//

import UIKit

//only depends on viewModel
final class FeedRefreshViewController: NSObject {
  private(set) lazy var view: UIRefreshControl = binded(UIRefreshControl())
  
  private let viewModel: FeedViewModel
  
  init(viewModel: FeedViewModel) {
    self.viewModel = viewModel
  }
  
  @objc func refresh() {
    viewModel.loadFeed()
  }
  
  private func binded(_ view: UIRefreshControl) -> UIRefreshControl {
    viewModel.onLoadingStateChange = { [weak view] isLoading in
      isLoading ? view?.beginRefreshing() : view?.endRefreshing()
    }
    view.addTarget(self, action: #selector(refresh), for: .valueChanged)
    return view
  }
}
