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
  
  init(primary: FeedImageDataLoader) {
    self.primary = primary
  }
  
  func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
    primary.loadImageData(from: url, completion: completion)
  }
}

class FeedImageLoaderWithFallbackCompositeTests: XCTestCase {
  
  func test_load_deliversPrimaryImageOnPrimarySuccess() {
    let primaryImageData = imageData(color: .red)
    let primaryResult: FeedImageDataLoader.Result = .success(primaryImageData)
    let primaryLoader = FeedImageDataLoaderStub(result: primaryResult)
    let sut = FeedImageLoaderWithFallbackComposite(primary: primaryLoader)
    
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
  
  //MARK: - Helper
  func anyURL() -> URL {
    URL(string: "http://url.com")!
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
