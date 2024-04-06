//
//  SharedLocalizationTestHelpers.swift
//  EssentialFeedPresentationTests
//
//  Created by Shengjun Xia on 2024/4/6.
//

import Foundation
import XCTest

typealias LocalizedBundle = (bundle: Bundle, localization: String)

func assertLocalizedKeyAndValuesExist(in presentationBundle: Bundle, _ table: String, file: StaticString = #file, line: UInt = #line) {
  let localizationBundles = allLocalizationBundles(in: presentationBundle, file: file, line: line)
  let localizedStringKeys = allLocalizedStringKeys(in: localizationBundles, table: table, file: file, line: line)
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

// 获取每个语言的bundle
func allLocalizationBundles(in bundle: Bundle, file: StaticString = #file, line: UInt = #line) -> [LocalizedBundle] {
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
func allLocalizedStringKeys(in bundles: [LocalizedBundle], table: String, file: StaticString = #file, line: UInt = #line) -> Set<String> {
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
