//
//  FeedUIIntegrationTests+LoaderSpy.swift
//  EssentialFeediOSTests
//
//  Created by Shengjun Xia on 2024/2/24.
//

import Foundation
import EssentialFeed
import EssentialFeediOS

extension FeedUIIntegrationTests {
  class LoaderSpy: FeedLoader, FeedImageDataLoader {
    var loadFeedCallCount: Int {
      feedRequests.count
    }
    
    private var imageRequests = [(url: URL, completion: (FeedImageDataLoader.Result) -> Void)]()
    var loadedImageURLs: [URL] {
      imageRequests.map{ $0.url }
    }
    
    private(set) var cancelledImageURLs: [URL] = []
    
    private var feedRequests: [(FeedLoader.Result) -> Void] = []
    
    func load(completion: @escaping (FeedLoader.Result) -> Void) {
      feedRequests.append(completion)
    }
    
    func completeFeedLoading(with images: [FeedImage] = [], at index: Int = 0) {
      feedRequests[index](.success(images))
    }
    
    func completFeedloadingWithError(at index: Int) {
      feedRequests[index](.failure(anyNSError()))
    }
    
    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
      imageRequests.append((url, completion))
      return TaskSpy {[weak self] in self?.cancelledImageURLs.append(url) }
    }
    
    func completeImageLoading(with imageData: Data = Data(), at index: Int = 0) {
      imageRequests[index].completion(.success(imageData))
    }
    
    func completeImageLoadingWithError(at index: Int = 0) {
      imageRequests[index].completion(.failure(anyNSError()))
    }
    
    private struct TaskSpy: FeedImageDataLoaderTask {
      let cancelCallBack: () -> Void
      
      func cancel() {
        cancelCallBack()
      }
    }
  }
}
