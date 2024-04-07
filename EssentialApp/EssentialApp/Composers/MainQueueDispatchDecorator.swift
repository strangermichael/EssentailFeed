//
//  MainQueueDispatchDecorator.swift
//  EssentialFeediOS
//
//  Created by Shengjun Xia on 2024/2/24.
//

import Foundation
import EssentialFeed

//adding behavior without changing interface
final class MainQueueDispatchDecorator<T> {
  private let decoratee: T
  
  init(decoratee: T) {
    self.decoratee = decoratee
  }
  
  func dispatch(completion: @escaping () -> Void) {
    guard Thread.isMainThread else {
      return DispatchQueue.main.async(execute: completion)
    }
    completion()
  }
}
  
extension MainQueueDispatchDecorator: ResourceLoader where T == FeedLoader {
  func load(completion: @escaping (FeedLoader.Result) -> Void) {
    decoratee.load { [weak self] result in
      self?.dispatch(completion: {
        completion(result)
      })
    }
  }
}


extension MainQueueDispatchDecorator: FeedImageDataLoader where T == FeedImageDataLoader {
  func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
    decoratee.loadImageData(from: url) { [weak self] result in
      self?.dispatch {
        completion(result)
      }
    }
  }
}
