//
//  URLSessionHTTPClient.swift
//  EssentialFeed
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
  
  //wrapper应该是适配, decorater是添加新行为一个接口，adpater是适配两个object的接口
  private struct URLSessionTaskWrapper: HTTPClientTask {
    let wrapped: URLSessionTask
    
    func cancel() {
      wrapped.cancel()
    }
  }
  
  public func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
    let task = session.dataTask(with: url) { data, response, error in
      if let error = error {
        completion(.failure(error))
      } else if let data = data, let httpResponse = response as? HTTPURLResponse {
        completion(.success((httpResponse, data)))
      } else {
        completion(.failure(UnexpectedValuesRepresentation()))
      }
    }
    task.resume()
    return URLSessionTaskWrapper(wrapped: task)
  }
}
