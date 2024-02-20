//
//  FeedImageCellController.swift
//  EssentialFeediOS
//
//  Created by Shengjun Xia on 2024/2/20.
//

import UIKit
import EssentailFeed

final class FeedImageCellController {
  private var task: FeedImageDataLoaderTask?
  private let model: FeedImage
  private let imageLoader: FeedImageDataLoader
  
  init(model: FeedImage, imageLoader: FeedImageDataLoader) {
    self.model = model
    self.imageLoader = imageLoader
  }
  
  func view() -> UITableViewCell {
    let cell = FeedImageCell()
    cell.locationContainer.isHidden = model.location == nil
    cell.locationLabel.text = model.location
    cell.descriptionLabel.text = model.description
    cell.feedImageView.image = nil
    cell.feedImageContainer.startShimmering()
    cell.feedImageRetryButton.isHidden = true
    let loadImage = { [weak self, weak cell] in
      guard let self = self else { return }
      self.task = self.imageLoader.loadImageData(from: self.model.url, completion: { [weak cell] result in
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
  
  func preload() {
    task = imageLoader.loadImageData(from: model.url, completion: { _ in })
  }
  
  func cancelLoad() {
    task?.cancel()
  }
}
