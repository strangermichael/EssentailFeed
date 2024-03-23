//
//  FeedImageLoaderWithFallbackCompositeTests.swift
//  EssentialAppTests
//
//  Created by Shengjun Xia on 2024/3/23.
//

import XCTest
import EssentialFeed

class FeedImageLoaderWithFallbackComposite: FeedImageDataLoader {
  private let primary: FeedImageDataLoader
  private let fallback: FeedImageDataLoader
  
  init(primary: FeedImageDataLoader, fallback: FeedImageDataLoader) {
    self.primary = primary
    self.fallback = fallback
  }
  
  func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
    primary.loadImageData(from: url) {[weak self] result in
      switch result {
      case .success:
        completion(result)
      case .failure:
        self?.fallback.loadImageData(from: url, completion: completion)
      }
    }
  }
}

class FeedImageLoaderWithFallbackCompositeTests: XCTestCase {
  
  func test_load_deliversPrimaryImageOnPrimarySuccess() {
    let primaryImageData = imageData(color: .red)
    let fallbackImageData = imageData(color: .blue)
    let primaryResult: RemoteFeedImageDataLoader.Result = .success(primaryImageData)
    let sut = makeSUT(primaryResult: primaryResult, fallbackResult: .success(fallbackImageData))
    
    let exp = expectation(description: "Wait for load completion")
    _ = sut.loadImageData(from: anyURL()) { result in
      switch result {
      case let .success(receivedData):
        XCTAssertEqual(primaryImageData, receivedData)
      case .failure:
        XCTFail("Expected to got \(primaryResult), but got \(result) instead")
      }
      exp.fulfill()
    }
    wait(for: [exp], timeout: 1.0)
  }
  
  func test_load_deliversFallbackImageOnPrimaryFailure() {
    let fallbackImageData = imageData(color: .blue)
    let primaryResult: RemoteFeedImageDataLoader.Result = .failure(anyNSError())
    let fallbackResult: RemoteFeedImageDataLoader.Result = .success(fallbackImageData)
    let sut = makeSUT(primaryResult: primaryResult, fallbackResult: fallbackResult)
    let exp = expectation(description: "Wait for load completion")
    _ = sut.loadImageData(from: anyURL()) { result in
      switch result {
      case let .success(receivedData):
        XCTAssertEqual(receivedData, fallbackImageData)
      case .failure:
        XCTFail("Expected to got \(fallbackResult), but got \(result) instead")
      }
      exp.fulfill()
    }
    wait(for: [exp], timeout: 1.0)
  }
  
  //MARK: - Helper
  func makeSUT(primaryResult: FeedImageDataLoader.Result, fallbackResult: FeedImageDataLoader.Result, file: StaticString = #file, line: UInt = #line) -> FeedImageLoaderWithFallbackComposite {
    let primaryLoader = FeedImageDataLoaderStub(result: primaryResult)
    let fallbackLoader = FeedImageDataLoaderStub(result: fallbackResult)
    let sut = FeedImageLoaderWithFallbackComposite(primary: primaryLoader, fallback: fallbackLoader)
    trackForMemoryLeaks(primaryLoader)
    trackForMemoryLeaks(sut)
    return sut
  }
  
  private func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #file, line: UInt = #line) {
    addTeardownBlock { [weak instance] in
      XCTAssertNil(instance, "Instance should have been deallocated. Potential memory leak.", file: file, line: line)
    }
  }
  
  private func imageData(color: UIColor) -> Data {
    UIImage.make(withColor: color).pngData()!
  }
  
  private class FeedImageDataLoaderStub: FeedImageDataLoader {
    private let result: FeedImageDataLoader.Result
    init(result: FeedImageDataLoader.Result) {
      self.result = result
    }
    
    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
      completion(result)
      return FeedImageDataLoaderTaskMock()
    }
  }
  
  private class FeedImageDataLoaderTaskMock: FeedImageDataLoaderTask {
    func cancel() {
      
    }
  }
}

extension UIImage {
  static func make(withColor color: UIColor) -> UIImage {
    let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
    let format = UIGraphicsImageRendererFormat()
    format.scale = 1
    return UIGraphicsImageRenderer(size: rect.size, format: format).image { rendererContext in
      color.setFill()
      rendererContext.fill(rect)
    }
  }
}
