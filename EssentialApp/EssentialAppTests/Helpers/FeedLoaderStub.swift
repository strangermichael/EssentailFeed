//
//  FeedLoaderStub.swift
//  EssentialAppTests
//
//  Created by Shengjun Xia on 2024/3/25.
//

import EssentialFeed

class FeedLoaderStub: FeedLoader {
  private let result: FeedLoader.Result
  
  init(result: FeedLoader.Result) {
    self.result = result
  }
  
  func load(completion: @escaping (FeedLoader.Result) -> Void) {
    completion(result)
  }
}
