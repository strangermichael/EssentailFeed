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
      case .success(let response, let data):
        if response.statusCode == 200,
           let root = try? JSONDecoder().decode(Root.self, from: data) {
          completion(.success(root.items.map { $0.item }))
        } else {
          completion(.failure(.invalidData))
        }
      case .failure(let error):
        completion(.failure(.connectivity))
      }
    }
  }
}

private struct Root: Decodable {
  let items: [Item]
  
}

private struct Item: Decodable {
  public let id: UUID
  public let description: String?
  public let location: String?
  public let image: URL
  
  var item: FeedItem {
    FeedItem(id: id, description: description, location: location, imageURL: image)
  }
}
