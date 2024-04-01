//
//  SceneDelegateTests.swift
//  EssentialAppTests
//
//  Created by Shengjun Xia on 2024/3/27.
//

import XCTest
import EssentialFeediOS
@testable import EssentialApp

final class SceneDelegateTests: XCTestCase {
  
  func test_configureWindow_setsWindowAsKeyAndVisible() {
    let window = UIWindowSpy()
    let sut = SceneDelegate()
    sut.window = window
    sut.configureWindow()
    //window.isKey会在测试环境一直失败，因此改成下面这样
    XCTAssertEqual(window.makeKeyAndVisibleCallCount, 1, "Expected to make window key and visible")
  }
  
  func test_sceneWillConnectToSession_configuresRootViewController() {
    let sut = SceneDelegate()
    sut.window = UIWindow()
    
    //当第三方库 sceneWillConnectToSession方法调不了的话，比如不知道传什么参数，就把这个方法的自己逻辑挪出来抽成一个方法，测试这个方法就好
    sut.configureWindow()
    
    let root = sut.window?.rootViewController
    let rootNavigation = root as? UINavigationController
    let topController = rootNavigation?.topViewController
     
    XCTAssertTrue(sut.window?.rootViewController is UINavigationController)
    XCTAssertTrue(topController is FeedViewController, "Expected a feed view controller as top view controller, got \(String(describing: topController)) instead")
  }
  
  private class UIWindowSpy: UIWindow {
    var makeKeyAndVisibleCallCount = 0
    
    override func makeKeyAndVisible() {
      makeKeyAndVisibleCallCount = 1
    }
  }
}
