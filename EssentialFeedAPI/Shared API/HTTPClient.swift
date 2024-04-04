//
//  HTTPClient.swift
//  EssentialFeed
//
//  Created by Shengjun Xia on 2023/12/3.
//

import Foundation

public protocol HTTPClientTask {
  func cancel()
}

public protocol HTTPClient {
  typealias Result = Swift.Result<(HTTPURLResponse, Data), Error>
  //shouldn't use RemoteFeedLoader.Error here, since it's domain error
  ///The completion handler can be invoked in any thread
  ///Clients are responsible to dispacth to appropriate thread
  @discardableResult
  func get(from url: URL, completion: @escaping (Result) -> Void) -> HTTPClientTask
}
