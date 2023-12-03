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
    sut.load { _ in }
    
    //Assert
    XCTAssertEqual(client.requestedURLs, [url])
  }
  
  
  func test_loadTwice_requestDataTwice() {
    let url = URL(string: "https://url.com")!
    let (sut, client) = makeSUT(url: url)
    
    sut.load { _ in }
    sut.load { _ in }
    
    XCTAssertEqual(client.requestedURLs, [url, url])
  }
  
  func test_load_deliverErrorOnClientError() {
    let (sut, client) = makeSUT()
    except(sut: sut, toCompleteWithResult: .failure(.connectivity)) {
      client.complete(error: NSError(domain: "Test", code: 0), at: 0)
    }
  }
  
  func test_load_deliverErrorOnNon200HTTPResponse() {
    let (sut, client) = makeSUT()
    let samples = [199, 201, 300, 400, 500]
    samples.enumerated().forEach { index, code in
      except(sut: sut, toCompleteWithResult: .failure(.invalidData)) {
        client.complete(withStatusCode: code, data: Data(), at: index)
      }
    }
  }
  
  func test_load_deliverErrorOn200ResponeWithInvalidJSON() {
    let (sut, client) = makeSUT()
    let invalidData = Data("invalid json".utf8)
    except(sut: sut, toCompleteWithResult: .failure(.invalidData)) {
      client.complete(withStatusCode: 200, data: invalidData, at: 0)
    }
  }
  
  func test_load_deliverNoItemsOn200ResponseWithEmptyJSONList() {
    let (sut, client) = makeSUT()
    let emptyListJSON = Data("{\"items\": []}".utf8)
    except(sut: sut, toCompleteWithResult: .success([])) {
      client.complete(withStatusCode: 200, data: emptyListJSON, at: 0)
    }
  }
  
  //MARK: - Helper
  func makeSUT(url: URL = URL(string: "https://a-url.com")!) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
    let client = HTTPClientSpy()
    let sut = RemoteFeedLoader(client: client, url: url)
    return (sut, client)
  }
  
  func except(sut: RemoteFeedLoader, toCompleteWithResult result: RemoteFeedLoader.Result, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
    var capturedResults: [RemoteFeedLoader.Result] = []
    sut.load {
      capturedResults.append($0)
    }
    action()
    XCTAssertEqual(capturedResults, [result], file: file, line: line) //to report exact line and file
  }
  
  class HTTPClientSpy: HTTPClient {
    var requestedURLs: [URL] {
      messages.map { $0.url }
    }
    
    var messages: [(url: URL, completion: (HTTPClientResult) -> Void)] = []
    
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
      messages.append((url, completion))
    }
    
    func complete(error: Error, at index: Int) {
      messages[index].completion(.failure(error))
    }
    
    func complete(withStatusCode code: Int, data: Data, at index: Int = 0) {
      let response = HTTPURLResponse(url: requestedURLs[index],
                                     statusCode: code,
                                     httpVersion: nil,
                                     headerFields: nil)!
      messages[index].completion(.success(response, data))
    }
  }
}
