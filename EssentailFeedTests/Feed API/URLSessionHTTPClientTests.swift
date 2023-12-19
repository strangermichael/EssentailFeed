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
  
  override func setUp() {
    super.setUp()
    URLProtocolStub.startInterceptingRequests()
  }
  
  override func tearDown() {
    super.tearDown()
    URLProtocolStub.stopInterceptingRequests()
  }
  
  func test_getFromURL_performGetRequestFromURL() {
    let url = anyURL()
    let exp = expectation(description: "wait for request")
    URLProtocolStub.observeRequests { receivedRequest in
      XCTAssertEqual(receivedRequest.url, url)
      XCTAssertEqual(receivedRequest.httpMethod, "GET")
      exp.fulfill()
    }
    makeSUT().get(from: url, completion: { _ in })
    wait(for: [exp], timeout: 1.0)
  }
  
  func test_getFromURL_failsOnRequestError() {
    let url = anyURL()
    let error = NSError(domain: "any error", code: 1)
    URLProtocolStub.stub(data: nil, response: nil, error: error)
    
    let sut = makeSUT()
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
  }
  
  func anyURL() -> URL {
    URL(string: "http://url.com")!
  }
  
  func makeSUT(file: StaticString = #file, line: UInt = #line) -> URLSessionHTTPClient {
    let sut = URLSessionHTTPClient()
    trackForMemoryLeaks(sut, file: file, line: line)
    return sut
  }
  
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
      requestObserver?(request)
      return true
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
