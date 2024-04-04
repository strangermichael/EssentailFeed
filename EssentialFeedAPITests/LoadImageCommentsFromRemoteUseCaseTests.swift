//
//  LoadImageCommentsFromRemoteUseCaseTests.swift
//  EssentialFeedAPITests
//
//  Created by Shengjun Xia on 2024/4/4.
//

import XCTest
import EssentialFeed
import EssentialFeedAPI

final class LoadImageCommentsFromRemoteUseCaseTests: XCTestCase {
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
  
  func test_load_deliverErrorOnNon2xxHTTPResponse() {
    let (sut, client) = makeSUT()
    let samples = [199, 150, 300, 400, 500]
    samples.enumerated().forEach { index, code in
      expect(sut: sut, toCompleteWithResult: failure(.invalidData)) {
        let json = makeItemsJSON([])
        client.complete(withStatusCode: code, data: json, at: index)
      }
    }
  }
  
  func test_load_deliverErrorOn2xxResponeWithInvalidJSON() {
    let (sut, client) = makeSUT()
    let invalidData = Data("invalid json".utf8)
    let samples = [200, 201, 250, 280, 299]
    samples.enumerated().forEach { index, code in
      expect(sut: sut, toCompleteWithResult: failure(.invalidData)) {
        client.complete(withStatusCode: code, data: invalidData, at: index)
      }
    }
  }
  
  func test_load_deliverNoItemsOn2xxResponseWithEmptyJSONList() {
    let (sut, client) = makeSUT()
    let emptyListJSON = makeItemsJSON([])
    let samples = [200, 201, 250, 280, 299]
    samples.enumerated().forEach { index, code in
      expect(sut: sut, toCompleteWithResult: .success([])) {
        client.complete(withStatusCode: code, data: emptyListJSON, at: index)
      }
    }
  }
  
  func test_load_deliverItemsOn200HTTPResponseWithJSONItems() {
    let (sut, client) = makeSUT()
    let item1 = makeItem(id: UUID(),
                         message: "a messgae",
                         createdAt: (Date(timeIntervalSince1970: 1598627222), "2020-08-28T15:07:02+00:00"),
                         userName: "a user name")
    let item2 = makeItem(id: UUID(),
                         message: "another message",
                         createdAt: (Date(timeIntervalSince1970: 1577881882), "2020-01-01T12:31:22+00:00"),
                         userName: "another user name")
    
    expect(sut: sut, toCompleteWithResult: .success([item1.model, item2.model])) {
      let json = makeItemsJSON([item1, item2].map { $0.json })
      client.complete(withStatusCode: 200, data: json)
    }
  }
  
  func test_load_doesNotDeliverResultAfterSutDeinit() {
    let url = URL(string: "https://url.com")!
    let client = HTTPClientSpy()
    var sut: RemoteImageCommentLoader? = RemoteImageCommentLoader(client: client, url: url)
    
    var capturedResults: [RemoteImageCommentLoader.Result] = []
    sut?.load {
      capturedResults.append($0)
    }
    sut = nil
    client.complete(withStatusCode: 200, data: makeItemsJSON([]))
    XCTAssertTrue(capturedResults.isEmpty)
  }
  
  //MARK: - Helper
  func makeSUT(url: URL = URL(string: "https://a-url.com")!, file: StaticString = #file, line: UInt = #line) -> (sut: RemoteImageCommentLoader, client: HTTPClientSpy) {
    let client = HTTPClientSpy()
    let sut = RemoteImageCommentLoader(client: client, url: url)
    trackForMemoryLeaks(sut)
    trackForMemoryLeaks(client)
    return (sut, client)
  }
  
  //iso8601String: 不在工厂里做格式化原因是 时区变了测试可能会失败 所以传固定字符串
  func makeItem(id: UUID, message: String, createdAt: (date: Date, iso8601String: String), userName: String) -> (model: ImageComment, json: [String: Any]) {
    let item = ImageComment(id: id,
                            message: message,
                            createdAt: createdAt.date,
                            userName: userName)
    let json = [
      "id": id.uuidString,
      "message": message,
      "created_at": createdAt.iso8601String,
      "author": [
        "username": userName
      ]
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
  
  func expect(sut: RemoteImageCommentLoader, toCompleteWithResult expectedResult: RemoteImageCommentLoader.Result, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
    
    let exp = expectation(description: "wait for load completion")
    sut.load { actualResult in
      switch (actualResult, expectedResult) {
      case let (.success(receivedItems), .success(expectedItems)):
        XCTAssertEqual(receivedItems, expectedItems, file: file, line: line)
      case let (.failure(receivedError as RemoteImageCommentLoader.Error), .failure(expectedError as RemoteImageCommentLoader.Error)):
        XCTAssertEqual(receivedError, expectedError, file: file, line: line)
      default:
        XCTFail("expected: \(expectedResult) but got: \(actualResult)")
      }
      exp.fulfill()
    }
    action()
    wait(for: [exp], timeout: 1.0)
  }
  
  func failure(_ error: RemoteImageCommentLoader.Error) -> RemoteImageCommentLoader.Result {
    .failure(error)
  }
}
