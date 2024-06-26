//
//  URLSessionHTTPClientTests.swift
//  EssentialFeedTests
//
//  Created by Shengjun Xia on 2023/12/5.
//

import XCTest
import EssentialFeed
import EssentialFeedAPI

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
    let recivedResponse = resultValuesFor(data: nil, response: response, error: nil)
    let emptyData = Data()
    XCTAssertEqual(recivedResponse?.response.url, response.url)
    XCTAssertEqual(recivedResponse?.response.statusCode, response.statusCode)
    XCTAssertEqual(recivedResponse?.data, emptyData)
  }
  
  func test_getFromURL_succeedsOnHTTPURLResponseWithData() {
    let data = anyData()
    let response = anyHTTPURLResponse()
    let recivedResponse = resultValuesFor(data: data, response: response, error: nil)
    URLProtocolStub.stub(data: data, response: response, error: nil)
    XCTAssertEqual(recivedResponse?.response.url, response.url)
    XCTAssertEqual(recivedResponse?.response.statusCode, response.statusCode)
    XCTAssertEqual(recivedResponse?.data, data)
  }
  
  // MARK: - Helpers  
  func anyHTTPURLResponse() -> HTTPURLResponse {
    HTTPURLResponse(url: anyURL(), statusCode: 200, httpVersion: nil, headerFields: nil)!
  }
  
  func nonHTTPUrlResponse() -> URLResponse {
    URLResponse(url: anyURL(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
  }
  
  func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> HTTPClient {
    let sut = URLSessionHTTPClient()
    trackForMemoryLeaks(sut, file: file, line: line)
    return sut
  }
  
  private func resultErrorFor(data: Data?, response: URLResponse?, error: Error?, file: StaticString = #filePath, line: UInt = #line) -> Error? {
    let result = resultFor(data: data, response: response, error: error)
    var receivedError: Error?
    switch result {
    case let .failure(error):
      receivedError = error
    default:
      XCTFail("Expect failure, got: \(result)", file: file, line: line)
    }
    return receivedError
  }
  
  private func resultValuesFor(data: Data?, response: URLResponse?, error: Error?, file: StaticString = #filePath, line: UInt = #line) -> (data: Data?, response: HTTPURLResponse)? {
    let result = resultFor(data: data, response: response, error: error)
    var receivedValues: (data: Data?, response: HTTPURLResponse)?
    switch result {
    case let .success((response, data)):
      receivedValues = (data, response)
    default:
      XCTFail("Expect success, got: \(result)", file: file, line: line)
    }
    return receivedValues
  }
  
  private func resultFor(data: Data?, response: URLResponse?, error: Error?, file: StaticString = #filePath, line: UInt = #line) -> HTTPClient.Result {
    let url = anyURL()
    URLProtocolStub.stub(data: data, response: response, error: error)
    
    let sut = makeSUT(file: file, line: line)
    let exp = expectation(description: "wait for completion")
    var receivedResult: HTTPClient.Result!
    sut.get(from: url) { result in
      receivedResult = result
      exp.fulfill()
    }
    wait(for: [exp], timeout: 1.0)
    return receivedResult
  }
}
