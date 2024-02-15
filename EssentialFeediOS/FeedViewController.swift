//
//  FeedViewController.swift
//  EssentialFeediOS
//
//  Created by Shengjun Xia on 2024/2/3.
//

import UIKit
import EssentailFeed

public protocol FeedImageDataLoaderTask {
  func cancel()
}

public protocol FeedImageDataLoader {
  typealias Result = Swift.Result<Data, Error>
  func loadImageData(from url: URL, completion: @escaping (Result) -> Void) -> FeedImageDataLoaderTask
}

final public class FeedViewController: UITableViewController {
  private var feedLoader: FeedLoader?
  private var tableModel: [FeedImage] = []
  private var imageLoader: FeedImageDataLoader?
  private var tasks: [IndexPath : FeedImageDataLoaderTask] = [:]
  
  public init(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) {
    super.init(nibName: nil, bundle: nil)
    self.feedLoader = feedLoader
    self.imageLoader = imageLoader
  }
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    refreshControl = UIRefreshControl()
    refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
    load()
  }
  
  @objc private func load() {
    refreshControl?.beginRefreshing()
    feedLoader?.load(completion: {[weak self] result in
      switch result {
      case .success(let images):
        self?.tableModel = images
        self?.tableView.reloadData()
      case .failure:
        break
      }
      self?.refreshControl?.endRefreshing()
    })
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
    tasks[indexPath] = imageLoader?.loadImageData(from: cellModel.url, completion: { [weak cell] result in
      if let data = try? result.get() {
        let image = UIImage(data: data)
        cell?.feedImageView.image = image
        cell?.feedImageRetryButton.isHidden = (image != nil)
      } else {
        cell?.feedImageRetryButton.isHidden = false
      }
      cell?.feedImageContainer.stopShimmering()
    })
    return cell
  }
  
  public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    tasks[indexPath]?.cancel()
    tasks[indexPath] = nil
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
