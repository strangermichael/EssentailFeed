//
//  FeedImageDataLoaderWithFallbackComposite.swift
//  EssentialApp
//
//  Created by Shengjun Xia on 2024/3/23.
//
import Foundation
import EssentialFeed

public class FeedImageDataLoaderWithFallbackComposite: FeedImageDataLoader {
  private let primary: FeedImageDataLoader
  private let fallback: FeedImageDataLoader
  
  public init(primary: FeedImageDataLoader, fallback: FeedImageDataLoader) {
    self.primary = primary
    self.fallback = fallback
  }
  
  private class TaskWrapper: FeedImageDataLoaderTask {
    var wrapped: FeedImageDataLoaderTask?
    
    func cancel() {
      wrapped?.cancel()
    }
  }
  
  //巧妙实现了返回不同的task, 因为只要访问的时候是对的就可以
  public func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
    let task = TaskWrapper()
    task.wrapped = primary.loadImageData(from: url) {[weak self] result in
      switch result {
      case .success:
        completion(result)
      case .failure:
        task.wrapped = self?.fallback.loadImageData(from: url, completion: completion)
      }
    }
    return task
  }
}
