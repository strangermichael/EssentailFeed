//
//  RemoteLoader<String>Tests.swift
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
  
  func test_load_deliverErrorOnMapperError() {
    let (sut, client) = makeSUT { _, _ in
      throw anyNSError()
    }
    let invalidData = Data("invalid json".utf8)
    expect(sut: sut, toCompleteWithResult: failure(.invalidData)) {
      client.complete(withStatusCode: 200, data: invalidData, at: 0)
    }
  }
  
  func test_load_deliverMappedResource() {
    let resource = "a resource"
    let (sut, client) = makeSUT { data, _ in
      String(data: data, encoding: .utf8)!
    }
    
    expect(sut: sut, toCompleteWithResult: .success(resource)) {
      client.complete(withStatusCode: 200, data: Data(resource.utf8))
    }
  }
  
  func test_load_doesNotDeliverResultAfterSutDeinit() {
    let url = URL(string: "https://url.com")!
    let client = HTTPClientSpy()
    var sut: RemoteLoader<String>? = RemoteLoader<String>(client: client, url: url) { _, _ in
      "any"
    }
    
    var capturedResults: [RemoteLoader<String>.Result] = []
    sut?.load {
      capturedResults.append($0)
    }
    sut = nil
    client.complete(withStatusCode: 200, data: makeItemsJSON([]))
    XCTAssertTrue(capturedResults.isEmpty)
  }
  
  //MARK: - Helper
  //测试用范型的类 可以选一个简单的类型
  func makeSUT(url: URL = URL(string: "https://a-url.com")!,
               mapper: @escaping RemoteLoader<String>.Mapper = { _, _ in "any" },
               file: StaticString = #filePath,
               line: UInt = #line) -> (sut: RemoteLoader<String>, client: HTTPClientSpy) {
    let client = HTTPClientSpy()
    let sut = RemoteLoader<String>(client: client, url: url, mapper: mapper)
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
  
  func expect(sut: RemoteLoader<String>, toCompleteWithResult expectedResult: RemoteLoader<String>.Result, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
    
    let exp = expectation(description: "wait for load completion")
    sut.load { actualResult in
      switch (actualResult, expectedResult) {
      case let (.success(receivedItems), .success(expectedItems)):
        XCTAssertEqual(receivedItems, expectedItems, file: file, line: line)
      case let (.failure(receivedError as RemoteLoader<String>.Error), .failure(expectedError as RemoteLoader<String>.Error)):
        XCTAssertEqual(receivedError, expectedError, file: file, line: line)
      default:
        XCTFail("expected: \(expectedResult) but got: \(actualResult)")
      }
      exp.fulfill()
    }
    action()
    wait(for: [exp], timeout: 1.0)
  }
  
  func failure(_ error: RemoteLoader<String>.Error) -> RemoteLoader<String>.Result {
    .failure(error)
  }

}
