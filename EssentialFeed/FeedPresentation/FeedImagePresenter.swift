//
//  FeedImagePresenter.swift
//  EssentialFeed
//
//  Created by Shengjun Xia on 2024/3/10.
//

import Foundation

public final class FeedImagePresenter<View: FeedImageView, Image> where View.Image == Image {
  private let view: View
  private let imageTransformer: (Data) -> Image?
  
  public init(view: View, imageTransformer: @escaping (Data) -> Image?) {
    self.view = view
    self.imageTransformer = imageTransformer
  }
  
  public func didStartLoadingImageData(for model: FeedImage) {
    view.display(FeedImageViewModel(
      description: model.description,
      location: model.location,
      image: nil,
      isLoading: true,
      shouldRetry: false))
  }
  
  public func didFinishLoadingImageData(with error: Error, for model: FeedImage) {
    view.display(FeedImageViewModel(
      description: model.description,
      location: model.location,
      image: nil,
      isLoading: false,
      shouldRetry: true))
  }
  
  private struct InvalidImageDataError: Error {}
  
  public func didFinishLoadingImageData(with data: Data, for model: FeedImage) {
    guard let image = imageTransformer(data) else {
      return didFinishLoadingImageData(with: InvalidImageDataError(), for: model)
    }
    
    view.display(FeedImageViewModel(
      description: model.description,
      location: model.location,
      image: image,
      isLoading: false,
      shouldRetry: false))
  }
}
