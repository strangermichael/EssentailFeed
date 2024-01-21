//
//  URLSessionHTTPClient.swift
//  EssentailFeed
//
//  Created by Shengjun Xia on 2023/12/19.
//

import Foundation

public class URLSessionHTTPClient: HTTPClient {
  private let session: URLSession
  
  public init(session: URLSession = URLSession.shared) {
    self.session = session
  }
  
  private struct UnexpectedValuesRepresentation: Error {}
  
  public func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) {
    session.dataTask(with: url) { data, response, error in
      if let error = error {
        completion(.failure(error))
      } else if let data = data, let httpResponse = response as? HTTPURLResponse {
        completion(.success((httpResponse, data)))
      } else {
        completion(.failure(UnexpectedValuesRepresentation()))
      }
    }.resume()
  }
}
