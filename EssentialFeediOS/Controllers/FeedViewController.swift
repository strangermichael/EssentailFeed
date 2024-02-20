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
  private var tasks: [IndexPath : FeedImageDataLoaderTask] = [:]
  
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
    let cellModel = tableModel[indexPath.row]
    let cell = FeedImageCell()
    cell.locationContainer.isHidden = cellModel.location == nil
    cell.locationLabel.text = cellModel.location
    cell.descriptionLabel.text = cellModel.description
    cell.feedImageView.image = nil
    cell.feedImageContainer.startShimmering()
    cell.feedImageRetryButton.isHidden = true
    let loadImage = { [weak self, weak cell] in
      guard let self = self else { return }
      self.tasks[indexPath] = self.imageLoader?.loadImageData(from: cellModel.url, completion: { [weak cell] result in
        if let data = try? result.get() {
          let image = UIImage(data: data)
          cell?.feedImageView.image = image
          cell?.feedImageRetryButton.isHidden = (image != nil)
        } else {
          cell?.feedImageRetryButton.isHidden = false
        }
        cell?.feedImageContainer.stopShimmering()
      })
    }
    cell.onRetry = loadImage
    loadImage()
    return cell
  }
  
  public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    cancelTask(forRowAt: indexPath)
  }
  
  public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
    indexPaths.forEach { indexPath in
      let cellModel = tableModel[indexPath.row]
      tasks[indexPath] = imageLoader?.loadImageData(from: cellModel.url, completion: { _ in })
    }
  }
  
  public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
    indexPaths.forEach(cancelTask)
  }
  
  private func cancelTask(forRowAt indexPath: IndexPath) {
    tasks[indexPath]?.cancel()
    tasks[indexPath] = nil
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
