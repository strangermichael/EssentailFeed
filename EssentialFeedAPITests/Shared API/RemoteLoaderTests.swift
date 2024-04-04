//
//  RemoteLoaderTests.swift
//  EssentialFeedAPITests
//
//  Created by Shengjun Xia on 2024/4/4.
//

import XCTest
import EssentialFeed
import EssentialFeedAPI

final class RemoteLoaderTests: XCTestCase {
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
    expect(sut: sut, toCompleteWithResult: failure(.connectivity)) {
      client.complete(with: NSError(domain: "Test", code: 0), at: 0)
    }
  }
  
  func test_load_deliverErrorOnNon200HTTPResponse() {
    let (sut, client) = makeSUT()
    let samples = [199, 201, 300, 400, 500]
    samples.enumerated().forEach { index, code in
      expect(sut: sut, toCompleteWithResult: failure(.invalidData)) {
        let json = makeItemsJSON([])
        client.complete(withStatusCode: code, data: json, at: index)
      }
    }
  }
  
  func test_load_deliverErrorOn200ResponeWithInvalidJSON() {
    let (sut, client) = makeSUT()
    let invalidData = Data("invalid json".utf8)
    expect(sut: sut, toCompleteWithResult: failure(.invalidData)) {
      client.complete(withStatusCode: 200, data: invalidData, at: 0)
    }
  }
  
  func test_load_deliverNoItemsOn200ResponseWithEmptyJSONList() {
    let (sut, client) = makeSUT()
    let emptyListJSON = makeItemsJSON([])
    expect(sut: sut, toCompleteWithResult: .success([])) {
      client.complete(withStatusCode: 200, data: emptyListJSON, at: 0)
    }
  }
  
  func test_load_deliverItemsOn200HTTPResponseWithJSONItems() {
    let (sut, client) = makeSUT()
    let item1 = makeItem(id: UUID(),
                         description: nil,
                         location: nil,
                         imageURL: URL(string: "https://url.com")!)
    let item2 = makeItem(id: UUID(),
                         description: "a descrption",
                         location: "location",
                         imageURL: URL(string: "https://anotherUrl.com")!)
    
    expect(sut: sut, toCompleteWithResult: .success([item1.model, item2.model])) {
      let json = makeItemsJSON([item1, item2].map { $0.json })
      client.complete(withStatusCode: 200, data: json)
    }
  }
  
  func test_load_doesNotDeliverResultAfterSutDeinit() {
    let url = URL(string: "https://url.com")!
    let client = HTTPClientSpy()
    var sut: RemoteLoader? = RemoteLoader(client: client, url: url)
    
    var capturedResults: [RemoteLoader.Result] = []
    sut?.load {
      capturedResults.append($0)
    }
    sut = nil
    client.complete(withStatusCode: 200, data: makeItemsJSON([]))
    XCTAssertTrue(capturedResults.isEmpty)
  }
  
  //MARK: - Helper
  func makeSUT(url: URL = URL(string: "https://a-url.com")!, file: StaticString = #file, line: UInt = #line) -> (sut: RemoteLoader, client: HTTPClientSpy) {
    let client = HTTPClientSpy()
    let sut = RemoteLoader(client: client, url: url)
    trackForMemoryLeaks(sut)
    trackForMemoryLeaks(client)
    return (sut, client)
  }
  
  func makeItem(id: UUID, description: String? = nil, location: String? = nil, imageURL: URL) -> (model: FeedImage, json: [String: Any]) {
    let item = FeedImage(id: id,
                        description: description,
                        location: location,
                        imageURL: imageURL)
    let json = [
      "id": item.id.uuidString,
      "description": item.description,
      "location": item.location,
      "image": item.url.absoluteString
    ].compactMapValues { $0 }
    return (item, json)
  }
  
  private func makeItemsJSON(_ items: [[String: Any]]) -> Data {
    let itemsJSON = [
      "items": items
    ]
    let json = try! JSONSerialization.data(withJSONObject: itemsJSON)
    return json
  }
  
  func expect(sut: RemoteLoader, toCompleteWithResult expectedResult: RemoteLoader.Result, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
    
    let exp = expectation(description: "wait for load completion")
    sut.load { actualResult in
      switch (actualResult, expectedResult) {
      case let (.success(receivedItems), .success(expectedItems)):
        XCTAssertEqual(receivedItems, expectedItems, file: file, line: line)
      case let (.failure(receivedError as RemoteLoader.Error), .failure(expectedError as RemoteLoader.Error)):
        XCTAssertEqual(receivedError, expectedError, file: file, line: line)
      default:
        XCTFail("expected: \(expectedResult) but got: \(actualResult)")
      }
      exp.fulfill()
    }
    action()
    wait(for: [exp], timeout: 1.0)
  }
  
  func failure(_ error: RemoteLoader.Error) -> RemoteLoader.Result {
    .failure(error)
  }

}
