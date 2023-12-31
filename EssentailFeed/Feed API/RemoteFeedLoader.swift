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
        let result = RemoteFeedLoader.map(data, from: response)
        completion(result)
      case .failure:
        completion(.failure(Error.connectivity))
      }
    }
  }
  
  private static func map(_ data: Data, from response: HTTPURLResponse) -> Result {
    do {
      let items = try FeedItemMapper.map(data, response).toModels()
      return .success(items)
    } catch {
      return .failure(error)
    }
  }
}

private extension Array where Element == RemoteFeedItem {
  func toModels() -> [FeedImage] {
    map {
      FeedImage(id: $0.id, description: $0.description, location: $0.location, imageURL: $0.image)
    }
  }
}
