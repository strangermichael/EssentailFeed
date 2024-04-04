//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Shengjun Xia on 2023/12/3.
//

import Foundation
import EssentialFeed

public final class RemoteFeedLoader: FeedLoader {
  private let client: HTTPClient
  private let url: URL
  
  public enum Error: Swift.Error, Equatable {
    case connectivity
    case invalidData
  }
  
  public typealias Result = FeedLoader.Result
  
  public init(client: HTTPClient, url: URL) {
    self.client = client
    self.url = url
  }
  
  public func load(completion: @escaping (Result) -> Void) {
    client.get(from: url) {[weak self] result in
      guard self != nil else { return }
      switch result {
      case .success((let response, let data)):
        let result = RemoteFeedLoader.map(data, from: response)
        completion(result)
      case .failure:
        completion(.failure(Error.connectivity))
      }
    }
  }
  
  private static func map(_ data: Data, from response: HTTPURLResponse) -> Result {
    do {
      let items = try FeedItemMapper.map(data, response)
      return .success(items)
    } catch {
      return .failure(error)
    }
  }
}