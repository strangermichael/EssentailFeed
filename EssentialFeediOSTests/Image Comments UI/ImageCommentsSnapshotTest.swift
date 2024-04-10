//
//  ImageCommentsSnapshotTest.swift
//  EssentialFeediOSTests
//
//  Created by Shengjun Xia on 2024/4/9.
//

import XCTest
import EssentialFeediOS
import EssentialFeedPresentation

final class ImageCommentsSnapshotTest: XCTestCase {
  func test_feedWithContent() {
    let sut = makeSUT()
    sut.display(cellControllers: comments())
    record(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "IMAGE_COMMENTS_light")
    record(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "IMAGE_COMMENTS_dark")
  }
  
  //MARK: - Helper
  private func makeSUT() -> ListViewController {
    let bundle = Bundle(for: ListViewController.self)
    let storyboard = UIStoryboard(name: "Comment", bundle: bundle)
    let controller = storyboard.instantiateInitialViewController() as! ListViewController
    controller.loadViewIfNeeded()
    controller.tableView.showsVerticalScrollIndicator = false
    controller.tableView.showsHorizontalScrollIndicator = false
    return controller
  }
  
  private func comments() -> [CellController] {
    [
      ImageCommentCellController(model:
                                  ImageCommentViewModel(message: "The East Side Gallery is an open-air gallery in Berlin. It consists of a series of murals painted directly on a 1,316 m long remnant of the Berlin Wall, located near the centre of Berlin, on Mühlenstraße in Friedrichshain-Kreuzberg. The gallery has official status as a Denkmal, or heritage-protected landmark.",
                                                        date: "1000 years ago",
                                                        username: "a long long long long username")),
      
      ImageCommentCellController(model:
                                  ImageCommentViewModel(message: "East Side Gallery \nMemorial in Berlin, Germany",
                                                        date: "10 days ago",
                                                        username: "a username")),
      
      ImageCommentCellController(model:
                                  ImageCommentViewModel(message: "nice",
                                                        date: "1 hour ago",
                                                        username: "a."))
    ]
  }
}
