//
//  FeedImageDataLoader.swift
//  EssentialFeediOS
//
//  Created by Shengjun Xia on 2024/2/20.
//

import Foundation

public protocol FeedImageDataLoaderTask {
  func cancel()
}

public protocol FeedImageDataLoader {
  typealias Result = Swift.Result<Data, Error>
  func loadImageData(from url: URL, completion: @escaping (Result) -> Void) -> FeedImageDataLoaderTask
}
