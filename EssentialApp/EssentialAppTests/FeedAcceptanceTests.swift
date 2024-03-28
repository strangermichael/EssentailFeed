//
//  FeedAcceptanceTests.swift
//  EssentialAppTests
//
//  Created by Shengjun Xia on 2024/3/28.
//

import XCTest
import EssentialFeed
import EssentialFeediOS
@testable import EssentialApp

final class FeedAcceptanceTests: XCTestCase {
  
  func test_onLaunch_displaysRemoteFeedWhenCustomerHasConnectivity() {
    let store = InMemoryFeedStore.empty
    let httpClient = HTTPClientStub.online(response)
    let feed = launch(httpClient: httpClient, store: store)
    XCTAssertEqual(feed.numberOfRenderedFeedImageViews(), 2)
    XCTAssertEqual(feed.simulateFeedImageViewVisible(at: 0)?.renderedImage, makeImageData())
    XCTAssertEqual(feed.simulateFeedImageViewVisible(at: 1)?.renderedImage, makeImageData())
  }
  
  func test_onLaunch_displaysCachedRemoteFeedWhenCustomerHasNoConnectivity() {
    //没有状态, 用的InMemoryFeedStore 很爽
    let sharedStore = InMemoryFeedStore.empty
    let onlineFeed = launch(httpClient: .online(response), store: sharedStore)
    onlineFeed.simulateFeedImageViewVisible(at: 0)
    onlineFeed.simulateFeedImageViewVisible(at: 1)
    
    let offlineFeed = launch(httpClient: .offline, store: sharedStore)
    
    XCTAssertEqual(offlineFeed.numberOfRenderedFeedImageViews(), 2)
    XCTAssertEqual(offlineFeed.simulateFeedImageViewVisible(at: 0)?.renderedImage, makeImageData())
    XCTAssertEqual(offlineFeed.simulateFeedImageViewVisible(at: 1)?.renderedImage, makeImageData())
  }
  
  private func launch(
    httpClient: HTTPClientStub = .offline,
    store: InMemoryFeedStore = .empty
  ) -> FeedViewController {
    let sut = SceneDelegate(httpClient: httpClient, store: store)
    sut.window = UIWindow()
    sut.configureWindow()
    
    let nav = sut.window?.rootViewController as? UINavigationController
    return nav?.topViewController as! FeedViewController
  }
  
  private class HTTPClientStub: HTTPClient {
    private class Task: HTTPClientTask {
      func cancel() {}
    }
    
    private let stub: (URL) -> HTTPClient.Result
    
    init(stub: @escaping (URL) -> HTTPClient.Result) {
      self.stub = stub
    }
    
    func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
      completion(stub(url))
      return Task()
    }
    
    static var offline: HTTPClientStub {
      HTTPClientStub(stub: { _ in .failure(NSError(domain: "offline", code: 0)) })
    }
    
    static func online(_ stub: @escaping (URL) -> (HTTPURLResponse, Data)) -> HTTPClientStub {
      HTTPClientStub { url in .success(stub(url)) }
    }
  }
  
  private class InMemoryFeedStore: FeedStore, FeedImageDataStore {
    private var feedCache: CachedFeed?
    private var feedImageDataCache: [URL: Data] = [:]
    
    func deleteCachedFeed(completion: @escaping FeedStore.DeletionCompletion) {
      feedCache = nil
      completion(nil)
    }
    
    func insert(items feed: [LocalFeedImage], timestamp: Date, completion: @escaping FeedStore.InsertionCompletion) {
      feedCache = CachedFeed(feed: feed, timestamp: timestamp)
      completion(.success(()))
    }
    
    func retrieve(completion: @escaping FeedStore.RetrievalCompletion) {
      completion(.success(feedCache))
    }
    
    func insert(_ data: Data, for url: URL, completion: @escaping (FeedImageDataStore.InsertionResult) -> Void) {
      feedImageDataCache[url] = data
      completion(.success(()))
    }
    
    func retrieve(dataForURL url: URL, completion: @escaping (FeedImageDataStore.RetrievalResult) -> Void) {
      completion(.success(feedImageDataCache[url]))
    }
    
    static var empty: InMemoryFeedStore {
      InMemoryFeedStore()
    }
  }
  
  private func response(for url: URL) -> (HTTPURLResponse, Data) {
    let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
    return (response, makeData(for: url))
  }
  
  private func makeData(for url: URL) -> Data {
    switch url.absoluteString {
    case "http://image.com":
      return makeImageData()
      
    default:
      return makeFeedData()
    }
  }
  
  private func makeImageData() -> Data {
    return UIImage.make(withColor: .red).pngData()!
  }
  
  private func makeFeedData() -> Data {
    return try! JSONSerialization.data(withJSONObject: ["items": [
      ["id": UUID().uuidString, "image": "http://image.com"],
      ["id": UUID().uuidString, "image": "http://image.com"]
    ]])
  }

}
