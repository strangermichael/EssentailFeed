//
//  FeedLocalizationTests.swift
//  EssentialFeediOSTests
//
//  Created by Shengjun Xia on 2024/2/24.
//

import XCTest
import EssentialFeed
@testable import EssentialFeediOS

final class FeedLocalizationTests: XCTestCase {
  
  func test_localizedStrings_haveKeysAndValuesForAllSupportedLocalizations() {
    let table = "Feed"
    let presentationBundle = Bundle(for: FeedPresenter.self)
    let localizationBundles = allLocalizationBundles(in: presentationBundle)
    let localizedStringKeys = allLocalizedStringKeys(in: localizationBundles, table: table)
    //localizationBundles就是一个语言一个bundle, 确保每个语言的bundle里有所有的key
    //确保每个语言的bundle里都有所有的key 和 content
    localizationBundles.forEach { (bundle, localization) in
      localizedStringKeys.forEach { key in
        let localizedString = bundle.localizedString(forKey: key, value: nil, table: table)
        if localizedString == key {
          let language = Locale.current.localizedString(forLanguageCode: localization) ?? ""
          XCTFail("Missing \(language) (\(localization)) localized string for key: '\(key)' in table: '\(table)'")
        }
      }
    }
  }
  
  
  //MARK: - Helpers
  private typealias LocalizedBundle = (bundle: Bundle, localization: String)
  
  // 获取每个语言的bundle
  private func allLocalizationBundles(in bundle: Bundle, file: StaticString = #file, line: UInt = #line) -> [LocalizedBundle] {
    return bundle.localizations.compactMap { localization in
      //localizations表示项目里设置的所有要支持的语言, 确保有这么个文件
      guard let path = bundle.path(forResource: localization, ofType: "lproj"),
            let localizedBundle = Bundle(path: path) else {
        XCTFail("Couldn't find bundle for localization: \(localization)", file: file, line: line)
        return nil
      }
      return (localizedBundle, localization)
    }
  }
  
  // 拿到每个语言的strings文件(bundle + table来定位)里的所有的key再去重
  private func allLocalizedStringKeys(in bundles: [LocalizedBundle], table: String, file: StaticString = #file, line: UInt = #line) -> Set<String> {
    bundles.reduce([]) { acc, current in
      guard let path = current.bundle.path(forResource: table, ofType: "strings"),
            let strings = NSDictionary(contentsOfFile: path),
            let keys = strings.allKeys as? [String] else {
        XCTFail("Couldn't load localized string for localization: \(current.localization)", file: file, line: line)
        return acc
      }
      return acc.union(Set(keys))
    }
  }
}
