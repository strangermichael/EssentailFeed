//
//  FeedImageCellController.swift
//  EssentialFeediOS
//
//  Created by Shengjun Xia on 2024/2/20.
//

import UIKit
import EssentailFeed

protocol FeedImageCellControllerDelegate {
  func didRequestImage()
  func didCancelImageRequest()
}

final class FeedImageCellController: FeedImageView {
  private let delegate: FeedImageCellControllerDelegate
  private var cell: FeedImageCell?
  
  init(delegate: FeedImageCellControllerDelegate) {
    self.delegate = delegate
  }
  
  func view(in tableView: UITableView) -> UITableViewCell {
    cell = tableView.dequeueReusableCell()
    delegate.didRequestImage()
    return cell!
  }
  
  func preload() {
    delegate.didRequestImage()
  }
  
  func cancelLoad() {
    releaseCellForReuse()
    delegate.didCancelImageRequest()
  }
  
  //持有cell的问题是，比如cell里有一个是异步请求图片，图片回来之后 这个cell可能被用来展示其他数据了，但是图回来后的completion block可能被刷新成之前数据的url
  private func releaseCellForReuse() {
    cell = nil
  }
  
  func display(_ viewModel: FeedImageViewModel<UIImage>) {
    cell?.locationContainer.isHidden = !viewModel.hasLocation
    cell?.locationLabel.text = viewModel.location
    cell?.descriptionLabel.text = viewModel.description
    cell?.feedImageView.setImageAnimated(viewModel.image)
    cell?.feedImageContainer.isShimmering = viewModel.isLoading
    cell?.feedImageRetryButton.isHidden = !viewModel.shouldRetry
    cell?.onRetry = delegate.didRequestImage
  }
}
