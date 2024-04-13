//
//  ImageLoader.swift
//  EssentialFeed
//
//  Created by Shengjun Xia on 2024/4/13.
//

import Foundation

public protocol ImageCommentLoader {
  typealias Result = Swift.Result<[ImageComment], Error>
  func load(completion: @escaping (Result) -> Void)
}
