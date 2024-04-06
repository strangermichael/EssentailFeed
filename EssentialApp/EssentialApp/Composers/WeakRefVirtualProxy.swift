//
//  WeakRefVirtualProxy.swift
//  EssentialFeediOS
//
//  Created by Shengjun Xia on 2024/2/24.
//

import UIKit
import EssentialFeed
import EssentialFeedPresentation

final class WeakRefVirtualProxy<T: AnyObject> {
  private weak var object: T?
  
  init(_ object: T) {
    self.object = object
  }
}

extension WeakRefVirtualProxy: ResourceLoadingView where T: ResourceLoadingView {
  func display(viewModel: ResourceLoadingViewModel) {
    object?.display(viewModel: viewModel)
  }
}

extension WeakRefVirtualProxy: FeedImageView where T: FeedImageView, T.Image == UIImage {
  func display(_ model: FeedImageViewModel<UIImage>) {
    object?.display(model)
  }
}

extension WeakRefVirtualProxy: ResourceErrorView where T: ResourceErrorView {
  func display(_ model: ResourceErrorViewModel) {
    object?.display(model)
  }
}

