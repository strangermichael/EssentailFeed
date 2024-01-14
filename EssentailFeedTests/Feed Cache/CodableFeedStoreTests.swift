//
//  CodableFeedStoreTests.swift
//  EssentailFeedTests
//
//  Created by Shengjun Xia on 2024/1/13.
//

import XCTest
import EssentailFeed

class CodableFeedStore {
  private let storeURL: URL
  
  init(storeURL: URL) {
    self.storeURL = storeURL
  }
  
  private struct Cache: Codable {
    let feed: [CodableFeedImage]
    let timestamp: Date
    
    var localFeed: [LocalFeedImage] {
      feed.map { $0.local }
    }
  }
  
  private struct CodableFeedImage: Codable {
    private let id: UUID
    private let description: String?
    private let location: String?
    private let url: URL
    
    init(_ image: LocalFeedImage) {
      id = image.id
      description = image.description
      location = image.location
      url = image.url
    }
    
    var local: LocalFeedImage {
      LocalFeedImage(id: id, description: description, location: location, url: url)
    }
  }
  
  func retrieve(completion: @escaping FeedStore.RetrievalCompletion) {
    guard let data = try? Data(contentsOf: storeURL) else {
      completion(.empty)
      return
    }
    let decoder = JSONDecoder()
    let cache = try! decoder.decode(Cache.self, from: data)
    completion(.found(feed: cache.localFeed, timeStamp: cache.timestamp))
  }
  
  func insert(items: [LocalFeedImage], timeStamp: Date, completion: @escaping FeedStore.InsertionCompletion) {
    let encoder = JSONEncoder()
    let encoded = try! encoder.encode(Cache(feed: items.map { CodableFeedImage($0) }, timestamp: timeStamp))
    try! encoded.write(to: storeURL)
    completion(nil)
  }
}

final class CodableFeedStoreTests: XCTestCase {
  
  override func setUp() {
    super.setUp()
    setupEmptyStoreState()
  }
  
  override func tearDown() {
    super.tearDown()
    setupEmptyStoreState()
  }
  
  func test_retrieve_deliversEmptyOnEmptyCache() {
    let sut = makeSUT()
    let exp = expectation(description: "wait for cache retrieval")
    sut.retrieve { result in
      switch result {
      case .empty:
        break
      default:
        XCTFail("Expected empty, got \(result) instead")
      }
      exp.fulfill()
    }
    wait(for: [exp], timeout: 1.0)
  }
  
  func test_retrieve_hasNoSideEffectsOnEmptyCache() {
    let sut = makeSUT()
    let exp = expectation(description: "Wait for cache retrieval")
    sut.retrieve { firstResult in
      sut.retrieve { secondResult in
        switch (firstResult, secondResult) {
        case (.empty, .empty):
          break
        default:
          XCTFail("Expected retriving twice from empty cache to deliver empty result, got \(firstResult) and \(secondResult) instead")
        }
        exp.fulfill()
      }
    }
    wait(for: [exp], timeout: 1.0)
  }
  
  func test_retrieveAfterInsertingToEmptyCache_deliversInsertedValues() {
    let sut = makeSUT()
    let feed = uniqueImageFeed().local
    let timestamp = Date()
    let exp = expectation(description: "Wait for cache retrieval")
    sut.insert(items: feed, timeStamp: timestamp) { insertionError in
      XCTAssertNil(insertionError, "Expected feed to be inserted successfully")
      sut.retrieve { retrieveResult in
        switch retrieveResult {
        case let .found(retrivedFeed, retrivedTimestamp):
          XCTAssertEqual(retrivedFeed, feed)
          XCTAssertEqual(retrivedTimestamp, timestamp)
        default:
          XCTFail("Expected found with \(feed) and \(timestamp), but got \(retrieveResult) instead")
        }
        exp.fulfill()
      }
    }
    wait(for: [exp], timeout: 1.0)
  }
  
  func test_retrieve_hasNoSideEffectsOnNonEmptyCache() {
    let sut = makeSUT()
    let feed = uniqueImageFeed().local
    let timestamp = Date()
    let exp = expectation(description: "Wait for cache retrieval")
    sut.insert(items: feed, timeStamp: timestamp) { insertionError in
      XCTAssertNil(insertionError, "Expected feed to be inserted successfully")
      sut.retrieve { firstResult in
        sut.retrieve { secondResult in
          switch (firstResult, secondResult) {
          case let (.found(firstFound), .found(secondFound)):
            XCTAssertEqual(firstFound.feed, secondFound.feed)
            XCTAssertEqual(firstFound.timeStamp, secondFound.timeStamp)
          default:
            XCTFail("Expected retriving twice from nonempty cache to deliver same result with \(firstResult), but got \(secondResult) instead")
          }
          exp.fulfill()
        }
      }
    }
    wait(for: [exp], timeout: 1.0)
  }
  
  //- MARK: Helpers
  private func makeSUT(file: StaticString = #file, line: UInt = #line) -> CodableFeedStore {
    let sut = CodableFeedStore(storeURL: testSpecificStoreURL())
    trackForMemoryLeaks(sut, file: file, line: line)
    return sut
  }
  
  private func setupEmptyStoreState() {
    deleteStoreArtifacts()
  }
  
  private func undoStoreSideEffects() {
    deleteStoreArtifacts()
  }
  
  private func deleteStoreArtifacts() {
    try? FileManager.default.removeItem(at: testSpecificStoreURL())
  }
  
  private func testSpecificStoreURL() -> URL {
    FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("\(type(of: self)).store")
  }
}
