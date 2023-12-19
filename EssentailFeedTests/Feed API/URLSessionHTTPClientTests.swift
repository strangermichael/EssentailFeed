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
  
  struct UnexpectedValuesRepresentation: Error {}
  
  func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
    session.dataTask(with: url) { data, response, error in
      if let error = error {
        completion(.failure(error))
      } else if let data = data, let httpResponse = response as? HTTPURLResponse {
        completion(.success(httpResponse, data))
      } else {
        completion(.failure(UnexpectedValuesRepresentation()))
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
    let requestError = NSError(domain: "any error", code: 1)
    let receivedError = resultErrorFor(data: nil, response: nil, error: requestError) as? NSError
    XCTAssertEqual(receivedError?.code, requestError.code)
    XCTAssertEqual(receivedError?.domain, requestError.domain)
  }
  
  func test_getFromURL_failsOnAllInvalidRepresentationCases() {
    let anyData = anyData()
    let anyError = anyNSError()
    let nonHTTPURLResponse = nonHTTPUrlResponse()
    let anyHTTPURLResponse = anyHTTPURLResponse()
    
    XCTAssertNotNil(resultErrorFor(data: nil, response: nil, error: nil))
    XCTAssertNotNil(resultErrorFor(data: nil, response: nonHTTPURLResponse, error: nil))
    XCTAssertNotNil(resultErrorFor(data: anyData, response: nil, error: nil))
    XCTAssertNotNil(resultErrorFor(data: anyData, response: nil, error: anyError))
    XCTAssertNotNil(resultErrorFor(data: nil, response: nonHTTPURLResponse, error: anyError))
    XCTAssertNotNil(resultErrorFor(data: nil, response: anyHTTPURLResponse, error: anyError))
    XCTAssertNotNil(resultErrorFor(data: anyData, response: nonHTTPURLResponse, error: anyError))
    XCTAssertNotNil(resultErrorFor(data: anyData, response: anyHTTPURLResponse, error: anyError))
    XCTAssertNotNil(resultErrorFor(data: anyData, response: nonHTTPURLResponse, error: nil))
  }
  
  //if stub nil data and got data and httpresponse and no error, system will replace empty data instead of nil
  func test_getFromURL_succeedsWithEmptyDataOnHTTPURLResponseWithNilData() {
    let response = anyHTTPURLResponse()
    URLProtocolStub.stub(data: nil, response: response, error: nil)
    let exp = expectation(description: "wait for completion")
    makeSUT().get(from: anyURL()) { result in
      switch result {
      case let .success(receivedResponse, receivedData):
        XCTAssertEqual(receivedResponse.url, response.url)
        XCTAssertEqual(receivedResponse.statusCode, response.statusCode)
        XCTAssertEqual(receivedData, Data())
      default:
        XCTFail("Expected success, got: \(result) instead")
      }
      exp.fulfill()
    }
    wait(for: [exp], timeout: 1.0)
  }
  
  func test_getFromURL_succeedsOnHTTPURLResponseWithData() {
    let data = anyData()
    let response = anyHTTPURLResponse()
    URLProtocolStub.stub(data: data, response: response, error: nil)
    let exp = expectation(description: "wait for completion")
    makeSUT().get(from: anyURL()) { result in
      switch result {
      case let .success(receivedResponse, receivedData):
        XCTAssertEqual(receivedResponse.url, response.url)
        XCTAssertEqual(receivedResponse.statusCode, response.statusCode)
        XCTAssertEqual(receivedData, data)
      default:
        XCTFail("Expected success, got: \(result) instead")
      }
      exp.fulfill()
    }
    wait(for: [exp], timeout: 1.0)
  }
  
  // MARK: - Helpers
  func anyURL() -> URL {
    URL(string: "http://url.com")!
  }
  
  func anyData() -> Data {
    Data("any data".utf8)
  }
  
  func anyNSError() -> NSError {
    NSError(domain: "any error", code: 0)
  }
  
  func anyHTTPURLResponse() -> HTTPURLResponse {
    HTTPURLResponse(url: anyURL(), statusCode: 200, httpVersion: nil, headerFields: nil)!
  }
  
  func nonHTTPUrlResponse() -> URLResponse {
    URLResponse(url: anyURL(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
  }
  
  func makeSUT(file: StaticString = #file, line: UInt = #line) -> URLSessionHTTPClient {
    let sut = URLSessionHTTPClient()
    trackForMemoryLeaks(sut, file: file, line: line)
    return sut
  }
  
  private func resultErrorFor(data: Data?, response: URLResponse?, error: Error?, file: StaticString = #file, line: UInt = #line) -> Error? {
    let url = anyURL()
    URLProtocolStub.stub(data: data, response: response, error: error)
    
    let sut = makeSUT(file: file, line: line)
    let exp = expectation(description: "wait for completion")
    var receivedError: Error?
    sut.get(from: url) { result in
      switch result {
      case let .failure(error):
        receivedError = error
      default:
        XCTFail("Expect failure, got: \(result)", file: file, line: line)
      }
      exp.fulfill()
    }
    wait(for: [exp], timeout: 1.0)
    return receivedError
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
