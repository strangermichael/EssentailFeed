//
//  RemoteLoader.swift
//  EssentialFeedAPI
//
//  Created by Shengjun Xia on 2024/4/4.
//

import Foundation
import EssentialFeed

public final class RemoteLoader<Resource> {
  private let client: HTTPClient
  private let url: URL
  private let mapper: Mapper
  
  public enum Error: Swift.Error, Equatable {
    case connectivity
    case invalidData
  }
  
  public typealias Result = Swift.Result<Resource, Swift.Error>
  public typealias Mapper = (Data, HTTPURLResponse) throws -> Resource
  
  public init(client: HTTPClient, url: URL, mapper: @escaping Mapper) {
    self.client = client
    self.url = url
    self.mapper = mapper
  }
  
  public func load(completion: @escaping (Result) -> Void) {
    client.get(from: url) {[weak self] result in
      guard let self = self else { return }
      switch result {
      case .success((let response, let data)):
        let result = self.map(data, from: response)
        completion(result)
      case .failure:
        completion(.failure(Error.connectivity))
      }
    }
  }
  
  private func map(_ data: Data, from response: HTTPURLResponse) -> Result {
    do {
      let items = try mapper(data, response)
      return .success(items)
    } catch {
      return .failure(Error.invalidData)
    }
  }
}
