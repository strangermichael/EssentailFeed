//
//  EssentailFeedCacheIntegrationTests.swift
//  EssentailFeedCacheIntegrationTests
//
//  Created by Shengjun Xia on 2024/1/20.
//

import XCTest
import EssentailFeed

final class EssentailFeedCacheIntegrationTests: XCTestCase {
  override func setUp() {
    super.setUp()
    setupEmptyStoreState()
  }
  
  override func tearDown() {
    super.tearDown()
    setupEmptyStoreState()
  }
  
  func test_load_deliversNoItemsOnEmptyCache() {
    let sut = makeSUT()
    expect(sut, toLoad: [])
  }
  
  func test_load_deliversItemsSavedOnASeparateInstance() {
    let sutToPerformSave = makeSUT()
    let sutToPerformLoad = makeSUT()
    let feed = uniqueImageFeed().models
    let saveExp = expectation(description: "Wait for save completion")
    sutToPerformSave.save(items: feed) { saveError in
      XCTAssertNil(saveError, "Expected to save feed successfully")
      saveExp.fulfill()
    }
    wait(for: [saveExp], timeout: 1.0)
    
    expect(sutToPerformLoad, toLoad: feed)
  }
  
  //MARK: - helpers
  private func makeSUT(file: StaticString = #file, line: UInt = #line) -> LocalFeedLoader {
    let storeBundle = Bundle(for: CoreDataFeedStore.self)
    let storeURL = testSpecificStoreURL()
    let store = try! CoreDataFeedStore(storeURL: storeURL, bundle: storeBundle)
    let sut = LocalFeedLoader(store: store, currentDate: Date.init)
    trackForMemoryLeaks(store, file: file, line: line)
    trackForMemoryLeaks(sut, file: file, line: line)
    return sut
  }
  
  private func expect(_ sut: LocalFeedLoader, toLoad expecedFeed: [FeedImage], file: StaticString = #file, line: UInt = #line) {
    let exp = expectation(description: "Wait for load completion")
    sut.load { result in
      switch result {
      case let .success(loadedFeed):
        XCTAssertEqual(loadedFeed, expecedFeed)
      case let .failure(error):
        XCTFail("Expected to get successful feed result, but got \(error) instead")
      }
    }
    exp.fulfill()
    wait(for: [exp], timeout: 1.0)
  }
  
  private func testSpecificStoreURL() -> URL {
    cachesDirectory().appendingPathComponent("\(type(of: self)).store")
  }
  
  private func cachesDirectory() -> URL {
    return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
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
}
