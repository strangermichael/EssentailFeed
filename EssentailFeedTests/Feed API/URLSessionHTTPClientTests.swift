//
//  URLSessionHTTPClientTests.swift
//  EssentailFeedTests
//
//  Created by Shengjun Xia on 2023/12/5.
//

import XCTest
import EssentailFeed

class URLSessionHTTPClient {
  private let session: URLSession
  
  init(session: URLSession = URLSession.shared) {
    self.session = session
  }
  
  func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
    session.dataTask(with: url) { _, _, error in
      if let error = error {
        completion(.failure(error))
      }
    }.resume()
  }
  
}

class URLSessionHTTPClientTests: XCTestCase {
  
  
  func test_getFromURL_failsOnRequestError() {
    URLProtocolStub.startInterceptingRequests()
    let url = URL(string: "http://url.com")!
    let error = NSError(domain: "any error", code: 1)
    URLProtocolStub.stub(data: nil, response: nil, error: error)
    
    let sut = URLSessionHTTPClient()
    let exp = expectation(description: "wait for completion")
    sut.get(from: url) { result in
      switch result {
      case let .failure(recivedError as NSError):
        //Since iOS 14, URLSession replaces received errors with a new error instance containing the data task in the  userInfo dictionary.
        //So we cannot compare the errors for equality anymore:
        XCTAssertEqual(recivedError.code, error.code)
        XCTAssertEqual(recivedError.domain, error.domain)
      default:
        XCTFail("Expect failure with error:\(error), got: \(result)")
      }
      exp.fulfill()
    }
    wait(for: [exp], timeout: 1.0)
    URLProtocolStub.stopInterceptingRequests()
  }
  
  
  class URLProtocolStub: URLProtocol {
    private static var stub: Stub?
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
    
    static func stopInterceptingRequests() {
      URLProtocol.unregisterClass(URLProtocolStub.self)
      stub = nil
    }
    
    override class func canInit(with request: URLRequest) -> Bool {
      true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
      request
    }
    
    override func startLoading() {
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
}
