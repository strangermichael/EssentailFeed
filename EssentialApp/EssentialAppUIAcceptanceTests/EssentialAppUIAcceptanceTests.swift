//
//  EssentialAppUIAcceptanceTests.swift
//  EssentialAppUIAcceptanceTests
//
//  Created by Shengjun Xia on 2024/3/26.
//

import XCTest

final class EssentialAppUIAcceptanceTests: XCTestCase {
  
  func test_onlaunch_displaysRemoteFeedWhenCustomerHasConnectivity() {
    let app = XCUIApplication()
    app.launch()
    app.waitForExistence(timeout: 5) //有时候接口没完成 或者 cell不可见 这个时候等一会儿确保UI都有
    let feedCells = app.cells.matching(identifier: "feed-image-cell")
    XCTAssertEqual(feedCells.count, 22)
    let appImage = app.images.matching(identifier: "feed-image-view").firstMatch
    XCTAssertTrue(appImage.exists)
  }
  
  
  func test_onLaunch_displaysCachedRemoteFeedWhenCustomerHasNoConnectivity() {
    let onlineApp = XCUIApplication()
    onlineApp.launch()
    onlineApp.waitForExistence(timeout: 5)
    
    let offlineApp = XCUIApplication()
    offlineApp.launchArguments = ["-connectivity", "offline"]
    offlineApp.launch()
    offlineApp.waitForExistence(timeout: 5)
    
    let cachedCells = offlineApp.cells.matching(identifier: "feed-image-cell")
    XCTAssertEqual(cachedCells.count, 22)
    let firstCachedImage = offlineApp.images.matching(identifier: "feed-image-view").firstMatch
    XCTAssertTrue(firstCachedImage.exists)
  }
}