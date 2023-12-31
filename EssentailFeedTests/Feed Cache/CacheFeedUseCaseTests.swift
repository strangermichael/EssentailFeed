//
//  CacheFeedUseCaseTests.swift
//  EssentailFeedTests
//
//  Created by Shengjun Xia on 2023/12/28.
//

import XCTest
import EssentailFeed

final class CacheFeedUseCaseTests: XCTestCase {
  
  func test_init_doesNotMessageSToreUponCreation() {
    let (_, store) = makeSUT()
    XCTAssertEqual(store.receivedMessages, [])
  }
  
  func test_save_requestCacheDeletion() {
    let (sut, store) = makeSUT()
    sut.save(items: uniqueImageFeed().models) { _ in }
    XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed])
  }
  
  func test_save_doesNotRequestCacheInsertionOnDeletionError() {
    let (sut, store) = makeSUT()
    sut.save(items: uniqueImageFeed().models) { _ in }
    store.completDeletion(with: anyNSError())
    XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed])
  }
    
  func test_save_requestCacheInsertionWithTimeStampOnSuccessfulDeletion() {
    let timeStamp = Date() //use injection to avoid timestamp different
    let (sut, store) = makeSUT(currentDate: { timeStamp })
    let items = uniqueImageFeed()
    sut.save(items: items.models) { _ in }
    store.completDeletionSuccessfully()
    XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed, .insert(items.local, timeStamp)])
  }
  
  func test_save_failsOnDeletionError(file: StaticString = #file, line: UInt = #line) {
    let (sut, store) = makeSUT()
    let deletionError = anyNSError()
    expect(sut, toCompleteWithError: deletionError, when: {
      store.completDeletion(with: deletionError)
    }, file: file, line: line)
  }
  
  func test_save_failsOnInsertionError(file: StaticString = #file, line: UInt = #line) {
    let (sut, store) = makeSUT()
    let insertionError = anyNSError()
    expect(sut, toCompleteWithError: insertionError, when: {
      store.completDeletionSuccessfully()
      store.completInsertion(with: insertionError)
    }, file: file, line: line)
  }
  
  func test_save_succeedsOnSuccessfulCacheInsertion(file: StaticString = #file, line: UInt = #line) {
    let (sut, store) = makeSUT()
    expect(sut, toCompleteWithError: nil, when: {
      store.completDeletionSuccessfully()
      store.completInsertionSuccessfully()
    }, file: file, line: line)
  }
  
  func test_save_doesNotDeliverDeletionErrorAfterSUTInstanceHasBeenDeallocated() {
    let store = FeedStoreSpy()
    var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
    var receivedResults: [Error?] = []
    sut?.save(items: [uniqueImage()]) { error in
      receivedResults.append(error)
    }
    sut = nil
    store.completDeletion(with: anyNSError())
    XCTAssertTrue(receivedResults.isEmpty)
  }
  
  func test_save_doesNotDeliverInserrionErrorAfterSUTInstanceHasBeenDeallocated() {
    let store = FeedStoreSpy()
    var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
    var receivedResults: [Error?] = []
    sut?.save(items: [uniqueImage()]) { error in
      receivedResults.append(error)
    }
    store.completDeletionSuccessfully()
    sut = nil
    store.completInsertion(with: anyNSError())
    XCTAssertTrue(receivedResults.isEmpty)
  }
  
  func expect(_ sut: LocalFeedLoader, toCompleteWithError expecedError: Error?, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
    let exp = expectation(description: "wait for save completion")
    var recivedError: Error?
    sut.save(items: [uniqueImage()]) { error in
      recivedError = error
      exp.fulfill()
    }
    action()
    wait(for: [exp], timeout: 1.0)
    XCTAssertEqual(recivedError as NSError?, nil)
  }
  
  //Helper
  private func makeSUT(currentDate: @escaping () -> Date = Date.init) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
    let store = FeedStoreSpy()
    let sut = LocalFeedLoader(store: store, currentDate: currentDate)
    trackForMemoryLeaks(sut)
    trackForMemoryLeaks(store)
    return (sut, store)
  }
  
  private func uniqueImage() -> FeedImage {
    FeedImage(id: UUID(), description: "any", location: "any", imageURL: anyURL())
  }
  
  private func uniqueImageFeed() -> (models: [FeedImage], local: [LocalFeedImage]) {
    let model = [uniqueImage(), uniqueImage()]
    let local = model.map {
      LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url)
    }
    return (model, local)
  }
  
  func anyURL() -> URL {
    URL(string: "http://url.com")!
  }
  
  func anyNSError() -> NSError {
    NSError(domain: "any error", code: 0)
  }
}
