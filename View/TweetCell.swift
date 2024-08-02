//
//  TweetCell.swift
//  OpenTweet
//
//  Created by Wu Yian on 2024-07-30.
//  Copyright © 2024 OpenTable, Inc. All rights reserved.
//

import Foundation
import UIKit

class TweetCell: UITableViewCell {
    
    // MARK: Constants
    struct Constant {
        static let reuseIdentifier = "TweetCell"
        static let blankProfileImage = "blankProfile"
    }
    
    // Constants for view layout and animation
    private struct ViewConstants {
        static let sidePadding = CGFloat(16)
        static let scaleFactor = CGFloat(1.05)
        static let ipadScaleXFactor = CGFloat(1.02)
        static let verticalStackSpacing = CGFloat(8)
        static let horizontalStackSpacing = CGFloat(12)
        static let imageSize = CGFloat(40)
        static let animationDuration = 0.3
    }

    // MARK: UI Components
    private let avatarView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = ViewConstants.imageSize/2
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let authorLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let contentTextView: UITextView = {
        let textView = UITextView()
        textView.isScrollEnabled = false
        textView.isEditable = false
        textView.backgroundColor = .clear
        textView.textContainerInset = .zero
        textView.dataDetectorTypes = .link
        textView.textContainer.lineFragmentPadding = 0
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var verticalStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [authorLabel, contentTextView, dateLabel])
        stackView.axis = .vertical
        stackView.spacing = ViewConstants.verticalStackSpacing
        stackView.alignment = .leading
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var horizontalStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [avatarView, verticalStackView])
        stackView.axis = .horizontal
        stackView.spacing = ViewConstants.horizontalStackSpacing
        stackView.alignment = .leading
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    // MARK: Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        buildUIAndSetUpConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: View Setup
    private func buildUIAndSetUpConstraints() {
        contentView.addSubview(horizontalStackView)
                
        NSLayoutConstraint.activate([
            horizontalStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: ViewConstants.sidePadding),
            horizontalStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: ViewConstants.sidePadding),
            horizontalStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -ViewConstants.sidePadding),
            horizontalStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -ViewConstants.sidePadding),
            
            avatarView.widthAnchor.constraint(equalToConstant: ViewConstants.imageSize),
            avatarView.heightAnchor.constraint(equalToConstant: ViewConstants.imageSize)
        ])
    }
    
    func configure(with tweetViewModel: TweetViewModel) {
        authorLabel.text = tweetViewModel.authorName
        contentTextView.attributedText = tweetViewModel.attributedContent(fontSize: 16)
        dateLabel.text = tweetViewModel.dateString
        
        /*
         There is no retain cycle currently, as tweetViewModel is instantiated within a
         function and its lifecycle ends when the function completes.
         Adding [weak self] to ensure safety in case of future changes.
         */
        tweetViewModel.fetchAvatar { [weak self] result in
            switch result {
            case .success(let data):
                DispatchQueue.main.async {
                    self?.avatarView.image = UIImage(data: data)
                }
            case .failure(_):
                DispatchQueue.main.async {
                    self?.setDefaultAvatar()
                }
            }
        }
        self.isAccessibilityElement = true
        self.accessibilityLabel = tweetViewModel.accessibilityLabel
        self.accessibilityHint = tweetViewModel.accessibilityHint
    }
    
    private func setDefaultAvatar() {
        self.avatarView.image = UIImage(named: Constant.blankProfileImage)
        self.avatarView.tintColor = .white
        self.avatarView.backgroundColor = .gray
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        if highlighted {
            highlight()
        } else {
            unhighlight()
        }
    }
    
    private func highlight() {
        UIView.animate(withDuration: ViewConstants.animationDuration) {
            let scaleFactor: CGFloat = self.isIpad ? ViewConstants.ipadScaleXFactor : ViewConstants.scaleFactor
            self.transform = CGAffineTransform(scaleX: scaleFactor, y: ViewConstants.scaleFactor)
            self.contentView.backgroundColor = UIColor.systemGray6
        }
    }
    
    private func unhighlight() {
        UIView.animate(withDuration: ViewConstants.animationDuration) {
            self.transform = .identity
            self.contentView.backgroundColor = .clear
        }
    }
    
    private var isIpad: Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }
}
