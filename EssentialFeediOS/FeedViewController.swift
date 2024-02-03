//
//  FeedViewController.swift
//  EssentialFeediOS
//
//  Created by Shengjun Xia on 2024/2/3.
//

import UIKit
import EssentailFeed

final public class FeedViewController: UITableViewController {
  private var loader: FeedLoader?
  
  public init(loader: FeedLoader) {
    super.init(nibName: nil, bundle: nil)
    self.loader = loader
  }
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    refreshControl = UIRefreshControl()
    refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
    load()
  }
  
  @objc private func load() {
    refreshControl?.beginRefreshing()
    loader?.load(completion: {[weak self] _ in
      self?.refreshControl?.endRefreshing()
    })
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
