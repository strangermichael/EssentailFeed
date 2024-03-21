//
//  URLProtocolStub.swift
//  EssentialFeedTests
//
//  Created by Shengjun Xia on 2024/3/21.
//

import Foundation

class URLProtocolStub: URLProtocol {
  private static var stub: Stub?
  private static var requestObserver: ((URLRequest) -> Void)?
  private struct Stub {
    let data: Data?
    let response: URLResponse?
    let error: Error?
  }
  
  static func stub(data: Data?, response: URLResponse?, error: Error?) {
    stub = Stub(data: data, response: response, error: error)
  }
  
  static func startInterceptingRequests() {
    URLProtocol.registerClass(URLProtocolStub.self)
  }
  
  static func observeRequests(observer: @escaping (URLRequest) -> Void) {
    requestObserver = observer
  }
  
  static func stopInterceptingRequests() {
    URLProtocol.unregisterClass(URLProtocolStub.self)
    stub = nil
    requestObserver = nil
  }
  
  override class func canInit(with request: URLRequest) -> Bool {
    return true
  }
  
  override class func canonicalRequest(for request: URLRequest) -> URLRequest {
    request
  }
  
  override func startLoading() {
    if let requestObserver = URLProtocolStub.requestObserver {
      client?.urlProtocolDidFinishLoading(self)
      requestObserver(request)
      return
    }
    let stub = URLProtocolStub.stub
    if let data = stub?.data {
      client?.urlProtocol(self, didLoad: data)
    }
    
    if let response = stub?.response {
      client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
    }
    
    if let error = stub?.error {
      client?.urlProtocol(self, didFailWithError: error)
    }
    client?.urlProtocolDidFinishLoading(self)
  }
  
  override func stopLoading() { }
}
