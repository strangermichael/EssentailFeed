//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Shengjun Xia on 2023/12/28.
//

import XCTest
import EssentialFeed
import EssentialFeedCache

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
    
  func test_save_requestCacheInsertionWithtimestampOnSuccessfulDeletion() {
    let timestamp = Date() //use injection to avoid timestamp different
    let (sut, store) = makeSUT(currentDate: { timestamp })
    let items = uniqueImageFeed()
    sut.save(items: items.models) { _ in }
    store.completDeletionSuccessfully()
    XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed, .insert(items.local, timestamp)])
  }
  
  func test_save_failsOnDeletionError(file: StaticString = #filePath, line: UInt = #line) {
    let (sut, store) = makeSUT()
    let deletionError = anyNSError()
    expect(sut, toCompleteWithError: deletionError, when: {
      store.completDeletion(with: deletionError)
    }, file: file, line: line)
  }
  
  func test_save_failsOnInsertionError(file: StaticString = #filePath, line: UInt = #line) {
    let (sut, store) = makeSUT()
    let insertionError = anyNSError()
    expect(sut, toCompleteWithError: insertionError, when: {
      store.completDeletionSuccessfully()
      store.completeInsertion(with: insertionError)
    }, file: file, line: line)
  }
  
  func test_save_succeedsOnSuccessfulCacheInsertion(file: StaticString = #filePath, line: UInt = #line) {
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
    store.completeInsertion(with: anyNSError())
    XCTAssertTrue(receivedResults.isEmpty)
  }
  
  func expect(_ sut: LocalFeedLoader, toCompleteWithError expecedError: Error?, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
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
}
