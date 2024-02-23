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
  @IBOutlet private var view: UIRefreshControl?
  var delegate: FeedRefreshViewControllerDelegate?
  
  @IBAction func refresh() {
    delegate?.didRequestFeedRefresh()
  }
  
  func display(viewModel: FeedLoadingViewModel) {
    viewModel.isLoading ? view?.beginRefreshing() : view?.endRefreshing()
  }
}
