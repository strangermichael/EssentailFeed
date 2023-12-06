//
//  URLSessionHTTPClientTests.swift
//  EssentailFeedTests
//
//  Created by Shengjun Xia on 2023/12/5.
//

import XCTest
import EssentailFeed

protocol HTTPSession {
  func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask
}

protocol URLSessionDataTask {
  func resume()
}

class URLSessionHTTPClient {
  private let session: HTTPSession
  
  init(session: HTTPSession) {
    self.session = session
  }
  
  func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
    session.dataTask(with: url) { _, _, error in
      if let error = error {
        completion(.failure(error))
      }
    }.resume()
  }
  
}

class URLSessionHTTPClientTests: XCTestCase {
  
  func test_getFromURL_resumeDataTaskWithURL() {
    let url = URL(string: "http://url.com")!
    let session = HTTPSessionSpy()
    let task = URLSessionDataTaskSpy()
    session.stub(url: url, task: task)
    
    let sut = URLSessionHTTPClient(session: session)
    sut.get(from: url, completion: { _ in })
    XCTAssertEqual(task.resumeCallCount, 1)
  }
  
  func test_getFromURL_failsOnRequestError() {
    let url = URL(string: "http://url.com")!
    let error = NSError(domain: "any error", code: 1)
    let session = HTTPSessionSpy()
    session.stub(url: url, error: error)
    
    let sut = URLSessionHTTPClient(session: session)
    let exp = expectation(description: "wait for completion")
    sut.get(from: url) { result in
      switch result {
      case let .failure(recivedError as NSError):
        XCTAssertEqual(recivedError, error)
      default:
        XCTFail("Expect failure with error:\(error), got: \(result)")
      }
      exp.fulfill()
    }
    wait(for: [exp], timeout: 1.0)
  }
  
  
  class HTTPSessionSpy: HTTPSession {
    private var stubs: [URL: Stub] = [ : ]
    private struct Stub {
      let task: URLSessionDataTask
      let error: Error?
    }
    
    func stub(url: URL, task: URLSessionDataTask = FakeURLSessionDataTask(), error: Error? = nil) {
      stubs[url] = Stub(task: task, error: error)
    }
    
    func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
      guard let stub = stubs[url] else {
        fatalError("Couldn't find stub for \(url)")
      }
      completionHandler(nil, nil, stub.error)
      return stub.task
    }
    
  }
  
  class FakeURLSessionDataTask: URLSessionDataTask {
    func resume() { }
  }
  
  class URLSessionDataTaskSpy: URLSessionDataTask {
    var resumeCallCount = 0
    
    func resume() {
      resumeCallCount += 1
    }
  }
}
