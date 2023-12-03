//
//  RemoteFeedLoader.swift
//  EssentailFeed
//
//  Created by Shengjun Xia on 2023/12/3.
//

import Foundation

public enum HTTPClientResult {
  case success(HTTPURLResponse, Data)
  case failure(Error)
}

public protocol HTTPClient {
  //shouldn't use RemoteFeedLoader.Error here, since it's domain error
  func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void)
}

public final class RemoteFeedLoader {
  private let client: HTTPClient
  private let url: URL
  
  public enum Error: Swift.Error {
    case connectivity
    case invalidData
  }
  
  public enum Result: Equatable {
    case success([FeedItem])
    case failure(Error)
  }
  
  public init(client: HTTPClient, url: URL) {
    self.client = client
    self.url = url
  }
  
  public func load(completion: @escaping (Result) -> Void) {
    client.get(from: url) { result in
      switch result {
      case .success(_, let data):
        if let _ = try? JSONSerialization.jsonObject(with: data) {
          completion(.success([]))
        } else {
          completion(.failure(.invalidData))
        }
      case .failure(let error):
        completion(.failure(.connectivity))
      }
    }
  }
}
