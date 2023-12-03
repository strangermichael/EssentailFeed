//
//  RemoteFeedLoader.swift
//  EssentailFeed
//
//  Created by Shengjun Xia on 2023/12/3.
//

import Foundation

public protocol HTTPClient {
  //shouldn't use RemoteFeedLoader.Error here, since it's domain error
  func get(from url: URL, completion: @escaping (Error) -> Void)
}

public final class RemoteFeedLoader {
  private let client: HTTPClient
  private let url: URL
  
  public enum Error: Swift.Error {
    case connectivity
  }
  
  public init(client: HTTPClient, url: URL) {
    self.client = client
    self.url = url
  }
  
  public func load(completion: @escaping (Error) -> Void = { _ in }) {
    client.get(from: url) { error in
      completion(.connectivity)
    }
  }
}
