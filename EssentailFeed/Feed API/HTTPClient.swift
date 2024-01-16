//
//  HTTPClient.swift
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
  ///The completion handler can be invoked in any thread
  ///Clients are responsible to dispacth to appropriate thread
  func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void)
}
