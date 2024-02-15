//
//  FeedImageCell.swift
//  EssentialFeediOS
//
//  Created by Shengjun Xia on 2024/2/8.
//

import UIKit

public class FeedImageCell: UITableViewCell {
  public let locationContainer = UIView()
  public let locationLabel = UILabel()
  public let descriptionLabel = UILabel()
  public let feedImageContainer = UIView()
  public let feedImageView = UIImageView()
  public private(set) lazy var feedImageRetryButton: UIButton = {
    let btn = UIButton()
    btn.addTarget(self, action: #selector(retryButtonTapped), for: .touchUpInside)
    return btn
  }()
  
  public var onRetry: (() -> Void)?
  
  @objc func retryButtonTapped() {
    onRetry?()
  }
}
