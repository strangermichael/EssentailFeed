//
//  RemoteFeedLoaderTests.swift
//  EssentailFeedTests
//
//  Created by Shengjun Xia on 2023/10/19.
//

import XCTest
import EssentailFeed

final class RemoteFeedLoaderTests: XCTestCase {
  
  //naming rule:  test + actionName + result
  func test_init_notDoNetworkRequest() {
    let (_, client) = makeSUT()
    XCTAssertEqual(client.requestedURLs, [])
  }
  
  func test_load_requestDataFromURL() {
    //Arrange
    let url = URL(string: "https://url.com")!
    let (sut, client) = makeSUT(url: url)
    
    //Act
    sut.load()
    
    //Assert
    XCTAssertEqual(client.requestedURLs, [url])
  }
  
  
  func test_loadTwice_requestDataTwice() {
    let url = URL(string: "https://url.com")!
    let (sut, client) = makeSUT(url: url)
    
    sut.load()
    sut.load()
    
    XCTAssertEqual(client.requestedURLs, [url, url])
  }
  
  func test_load_deliverErrorOnClientError() {
    let (sut, client) = makeSUT()
    client.error = NSError(domain: "Test", code: 0)
    var capturedErrors: [RemoteFeedLoader.Error] = []
    sut.load {
      capturedErrors.append($0)
    }
    XCTAssertEqual(capturedErrors, [.connectivity])
  }
  
  //MARK: - Helper
  func makeSUT(url: URL = URL(string: "https://a-url.com")!) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
    let client = HTTPClientSpy()
    let sut = RemoteFeedLoader(client: client, url: url)
    return (sut, client)
  }
  
  class HTTPClientSpy: HTTPClient {
    var requestedURLs: [URL] = []
    var error: Error?
    
    func get(from url: URL, completion: @escaping (Error) -> Void) {
      requestedURLs.append(url)
      if let error = error {
        completion(error)
      }
    }
  }
}
