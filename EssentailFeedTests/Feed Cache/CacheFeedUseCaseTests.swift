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
    sut.save(items: uniqueItems().models) { _ in }
    XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed])
  }
  
  func test_save_doesNotRequestCacheInsertionOnDeletionError() {
    let (sut, store) = makeSUT()
    sut.save(items: uniqueItems().models) { _ in }
    store.completDeletion(with: anyNSError())
    XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed])
  }
    
  func test_save_requestCacheInsertionWithTimeStampOnSuccessfulDeletion() {
    let timeStamp = Date() //use injection to avoid timestamp different
    let (sut, store) = makeSUT(currentDate: { timeStamp })
    let items = uniqueItems()
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
    sut?.save(items: [uniqueItem()]) { error in
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
    sut?.save(items: [uniqueItem()]) { error in
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
    sut.save(items: [uniqueItem()]) { error in
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
  
  private func uniqueItem() -> FeedItem {
    FeedItem(id: UUID(), description: "any", location: "any", imageURL: anyURL())
  }
  
  private func uniqueItems() -> (models: [FeedItem], local: [LocalFeedItem]) {
    let model = [uniqueItem(), uniqueItem()]
    let local = model.map {
      LocalFeedItem(id: $0.id, description: $0.description, location: $0.location, imageURL: $0.imageURL)
    }
    return (model, local)
  }
  
  func anyURL() -> URL {
    URL(string: "http://url.com")!
  }
  
  func anyNSError() -> NSError {
    NSError(domain: "any error", code: 0)
  }
  
  private class FeedStoreSpy: FeedStore {
    enum ReceivedMessage: Equatable {
      case deleteCachedFeed
      case insert([LocalFeedItem], Date)
    }
    
    private(set) var receivedMessages = [ReceivedMessage]()
    private var deletionCompletions: [DeletionCompletion] = []
    private var insertionCompletions: [InsertionCompletion] = []
    
    func deleteCachedFeed(completion: @escaping DeletionCompletion) {
      deletionCompletions.append(completion)
      receivedMessages.append(.deleteCachedFeed)
    }
    
    func completDeletion(with error: Error, at index: Int = 0) {
      deletionCompletions[index](error)
    }
    
    func completDeletionSuccessfully(at index: Int = 0) {
      deletionCompletions[index](nil)
    }
    
    func completInsertion(with error: Error, at index: Int = 0) {
      insertionCompletions[index](error)
    }
    
    func completInsertionSuccessfully(at index: Int = 0) {
      insertionCompletions[index](nil)
    }
    
    func insert(items: [LocalFeedItem], timeStamp: Date, completion: @escaping InsertionCompletion) {
      insertionCompletions.append(completion)
      receivedMessages.append(.insert(items, timeStamp))
    }
  }
}
