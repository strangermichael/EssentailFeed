//
//  ImageCommentCellController.swift
//  EssentialFeediOS
//
//  Created by Shengjun Xia on 2024/4/9.
//

import UIKit
import EssentialFeedPresentation

public class ImageCommentCellController: CellController {
  private let model: ImageCommentViewModel
  
  public init(model: ImageCommentViewModel) {
    self.model = model
  }
  
  public func view(in tableView: UITableView) -> UITableViewCell {
    let cell: ImageCommentCell = tableView.dequeueReusableCell()
    cell.messageLabel.text = model.message
    cell.userNameLabel.text = model.username
    cell.dateLabel.text = model.date
    return cell
  }
  
  public func preload() {
    
  }
  
  public func cancelLoad() {
    
  }
  
}
