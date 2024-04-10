//
//  FeedImageCellController.swift
//  EssentialFeediOS
//
//  Created by Shengjun Xia on 2024/2/20.
//

import UIKit
import EssentialFeed
import EssentialFeedPresentation

public protocol FeedImageCellControllerDelegate {
  func didRequestImage()
  func didCancelImageRequest()
}

public final class FeedImageCellController: NSObject, FeedImageView, CellController {
  private let delegate: FeedImageCellControllerDelegate
  private var cell: FeedImageCell?
  
  public init(delegate: FeedImageCellControllerDelegate) {
    self.delegate = delegate
  }
  
  public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    cell = tableView.dequeueReusableCell()
    delegate.didRequestImage()
    return cell!
  }
  
  public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    1
  }
  
  public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
    delegate.didRequestImage()
  }
  
  public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
    cancelLoad()
  }
  
  public func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    cancelLoad()
  }
  
  private func cancelLoad() {
    releaseCellForReuse()
    delegate.didCancelImageRequest()
  }
  
  //持有cell的问题是，比如cell里有一个是异步请求图片，图片回来之后 这个cell可能被用来展示其他数据了，但是图回来后的completion block可能被刷新成之前数据的url
  private func releaseCellForReuse() {
    cell = nil
  }
  
  public func display(_ viewModel: FeedImageViewModel<UIImage>) {
    cell?.locationContainer.isHidden = !viewModel.hasLocation
    cell?.locationLabel.text = viewModel.location
    cell?.descriptionLabel.text = viewModel.description
    cell?.feedImageView.setImageAnimated(viewModel.image)
    cell?.feedImageContainer.isShimmering = viewModel.isLoading
    cell?.feedImageRetryButton.isHidden = !viewModel.shouldRetry
    cell?.onRetry = delegate.didRequestImage
  }
}
