//
//  ImageCommentsPresenter.swift
//  EssentialFeedPresentation
//
//  Created by Shengjun Xia on 2024/4/7.
//

import Foundation
import EssentialFeed

public struct ImageCommentsViewModel: Equatable {
  public let comments: [ImageCommentViewModel]
  
}

public struct ImageCommentViewModel: Equatable {
  public let message: String
  public let date: String
  public let username: String
  
  public init(message: String, date: String, username: String) {
    self.message = message
    self.date = date
    self.username = username
  }
}

public class ImageCommentsPresenter {
  public static var title: String {
    NSLocalizedString("IMAGE_COMMENTS_VIEW_TITLE", tableName: "ImageComments", bundle: Bundle(for: Self.self), comment: "Title for the image comments view")
  }
  
  // to make test predictable
  public static func map(_ comments: [ImageComment], currentDate: Date = Date(), calendar: Calendar = .current, locale: Locale = .current) -> ImageCommentsViewModel {
    let formater = RelativeDateTimeFormatter()
    formater.calendar = calendar
    formater.locale = locale
    return ImageCommentsViewModel(comments: comments.map({ comment in
      ImageCommentViewModel(message: comment.message,
                            date: formater.localizedString(for: comment.createdAt, relativeTo: .init()),
                            username: comment.userName)
    }))
  }
}
