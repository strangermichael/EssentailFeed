//
//  WeakRefVirtualProxy.swift
//  EssentialFeediOS
//
//  Created by Shengjun Xia on 2024/2/24.
//

import UIKit

final class WeakRefVirtualProxy<T: AnyObject> {
  private weak var object: T?
  
  init(_ object: T) {
    self.object = object
  }
}

extension WeakRefVirtualProxy: FeedLoadingView where T: FeedLoadingView {
  func display(viewModel: FeedLoadingViewModel) {
    object?.display(viewModel: viewModel)
  }
}

extension WeakRefVirtualProxy: FeedImageView where T: FeedImageView, T.Image == UIImage {
  func display(_ model: FeedImageViewModel<UIImage>) {
    object?.display(model)
  }
}
