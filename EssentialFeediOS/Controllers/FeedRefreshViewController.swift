//
//  FeedRefreshViewController.swift
//  EssentialFeediOS
//
//  Created by Shengjun Xia on 2024/2/20.
//

import UIKit
import EssentailFeed

final class FeedRefreshViewController: NSObject {
  private(set) lazy var view: UIRefreshControl = {
    let view = UIRefreshControl()
    view.addTarget(self, action: #selector(refresh), for: .valueChanged)
    return view
  }()
  
  private let feedLoader: FeedLoader
  var onRefresh: (([FeedImage]) -> Void)?
  
  init(feedLoader: FeedLoader) {
    self.feedLoader = feedLoader
  }
  
  @objc func refresh() {
    view.beginRefreshing()
    feedLoader.load(completion: {[weak self] result in
      switch result {
      case .success(let images):
        self?.onRefresh?(images)
      case .failure:
        break
      }
      self?.view.endRefreshing()
    })
  }
}
