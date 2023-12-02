//
//  RemoteFeedLoaderTests.swift
//  EssentailFeedTests
//
//  Created by Shengjun Xia on 2023/10/19.
//

import XCTest

class RemoteFeedLoader {
  private let client: HTTPClient
  
  init(client: HTTPClient) {
    self.client = client
  }
  
  func load() {
    client.get(from: URL(string: "google.com")!)
  }
}

protocol HTTPClient {
  func get(from url: URL)
}

class HTTPClientSpy: HTTPClient {
  var requestedURL: URL?
  
  func get(from url: URL) {
    requestedURL = url
  }
}

final class RemoteFeedLoaderTests: XCTestCase {
  
  //naming rule:  test + actionName + result
  func test_init_notDoNetworkRequest() {
    let client = HTTPClientSpy()
    let _ = RemoteFeedLoader(client: client)
    XCTAssertNil(client.requestedURL)
  }
  
  func test_load_requestDataFromURL() {
    //Arrange
    let client = HTTPClientSpy()
    let sut = RemoteFeedLoader(client: client)
    
    //Act
    sut.load()
    
    //Assert
    XCTAssertNotNil(client.requestedURL)
  }
  
}
