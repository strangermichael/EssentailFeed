//
//  RemoteFeedLoader.swift
//  EssentailFeed
//
//  Created by Shengjun Xia on 2023/12/3.
//

import Foundation

public final class RemoteFeedLoader: FeedLoader {
  private let client: HTTPClient
  private let url: URL
  
  public enum Error: Swift.Error, Equatable {
    case connectivity
    case invalidData
  }
  
  public typealias Result = LoadFeedResult
  
  public init(client: HTTPClient, url: URL) {
    self.client = client
    self.url = url
  }
  
  public func load(completion: @escaping (Result) -> Void) {
    client.get(from: url) {[weak self] result in
      guard self != nil else { return }
      switch result {
      case .success(let response, let data):
        completion(FeedItemMapper.map(data, response))
      case .failure:
        completion(.failure(Error.connectivity))
      }
    }
  }
}
