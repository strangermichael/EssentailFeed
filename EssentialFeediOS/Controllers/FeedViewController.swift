//
//  FeedViewController.swift
//  EssentialFeediOS
//
//  Created by Shengjun Xia on 2024/2/3.
//

import UIKit
import EssentailFeed

final public class FeedViewController: UITableViewController, UITableViewDataSourcePrefetching {
  private var refreshController: FeedRefreshViewController?
  private var tableModel: [FeedImage] = [] {
    didSet {
      tableView.reloadData()
    }
  }
  private var imageLoader: FeedImageDataLoader?
  private var cellControllers: [IndexPath : FeedImageCellController] = [:]
  
  public init(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) {
    super.init(nibName: nil, bundle: nil)
    self.refreshController = FeedRefreshViewController(feedLoader: feedLoader)
    self.imageLoader = imageLoader
  }
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    refreshControl = refreshController?.view
    refreshController?.onRefresh = { [weak self] images in
      self?.tableModel = images
    }
    tableView.prefetchDataSource = self
    refreshController?.refresh()
  }
  
  public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    tableModel.count
  }
  
  public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    cellController(forRowAt: indexPath).view()
  }
  
  public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    removeCellController(forRowAt: indexPath)
  }
  
  public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
    indexPaths.forEach { indexPath in
      cellController(forRowAt: indexPath).preload()
    }
  }
  
  public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
    indexPaths.forEach(removeCellController)
  }
  
  private func cellController(forRowAt indexPath: IndexPath) -> FeedImageCellController {
    let cellModel = tableModel[indexPath.row]
    let cellController = FeedImageCellController(model: cellModel, imageLoader: imageLoader!)
    cellControllers[indexPath] = cellController
    return cellController
  }
  
  private func removeCellController(forRowAt indexPath: IndexPath) {
    cellControllers[indexPath] = nil
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
