//
//  RemoteFeedLoaderTests.swift
//  EssentailFeedTests
//
//  Created by Shengjun Xia on 2023/10/19.
//

import XCTest

class RemoteFeedLoader {
  private let client: HTTPClient
  private let url: URL
  
  init(client: HTTPClient, url: URL) {
    self.client = client
    self.url = url
  }
  
  func load() {
    client.get(from: url)
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
    let url = URL(string: "a-url.com")!
    let client = HTTPClientSpy()
    let _ = RemoteFeedLoader(client: client, url: url)
    XCTAssertNil(client.requestedURL)
  }
  
  func test_load_requestDataFromURL() {
    //Arrange
    let url = URL(string: "a-url.com")!
    let client = HTTPClientSpy()
    let sut = RemoteFeedLoader(client: client, url: url)
    
    //Act
    sut.load()
    
    //Assert
    XCTAssertEqual(client.requestedURL, url)
  }
  
}
