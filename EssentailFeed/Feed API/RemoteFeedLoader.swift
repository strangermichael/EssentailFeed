//
//  RemoteFeedLoader.swift
//  EssentailFeed
//
//  Created by Shengjun Xia on 2023/12/3.
//

import Foundation

public enum HTTPClientResult {
  case success(HTTPURLResponse)
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
  
  public init(client: HTTPClient, url: URL) {
    self.client = client
    self.url = url
  }
  
  public func load(completion: @escaping (Error) -> Void) {
    client.get(from: url) { result in
      switch result {
      case .success(let response):
        completion(.invalidData)
      case .failure(let error):
        completion(.connectivity)
      }
    }
  }
}
