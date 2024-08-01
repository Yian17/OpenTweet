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
    
    struct Constant {
        static let reuseIdentifier = "TweetCell"
        static let blankProfileImage = "blankProfile"
    }
        
    private var avatarView = UIImageView()
    private let authorLabel = UILabel()
    private let contentLabel = UILabel()
    private let dateLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func commonInit() {
        buildUI()
        setUpConstraints()
    }
    
    func buildUI() {
        avatarView.contentMode = .scaleAspectFill
        avatarView.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        avatarView.layer.cornerRadius = avatarView.bounds.height/2
        avatarView.clipsToBounds = true
        avatarView.translatesAutoresizingMaskIntoConstraints = false
        
        
        authorLabel.font = UIFont.boldSystemFont(ofSize: 16)
        authorLabel.translatesAutoresizingMaskIntoConstraints = false
        
        contentLabel.font = UIFont.systemFont(ofSize: 14)
        contentLabel.numberOfLines = 0
        contentLabel.translatesAutoresizingMaskIntoConstraints = false
        
        dateLabel.font = UIFont.systemFont(ofSize: 12)
        dateLabel.textColor = .gray
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(avatarView)
        contentView.addSubview(authorLabel)
        contentView.addSubview(contentLabel)
        contentView.addSubview(dateLabel)
    }
    
    func setUpConstraints() {
        NSLayoutConstraint.activate([
            avatarView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            avatarView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            avatarView.widthAnchor.constraint(equalToConstant: avatarView.frame.width),
            avatarView.heightAnchor.constraint(equalToConstant: avatarView.frame.height),
            
            authorLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            authorLabel.leadingAnchor.constraint(equalTo: avatarView.trailingAnchor, constant: 16),
            authorLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
        
            contentLabel.topAnchor.constraint(equalTo: authorLabel.bottomAnchor, constant: 8),
            contentLabel.leadingAnchor.constraint(equalTo: authorLabel.leadingAnchor),
            contentLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
                        
            dateLabel.topAnchor.constraint(equalTo: contentLabel.bottomAnchor, constant: 8),
            dateLabel.leadingAnchor.constraint(equalTo: authorLabel.leadingAnchor),
            dateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            dateLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])
    }
    
    func configure(with tweetViewmodel: TweetViewmodel) {
        authorLabel.text = tweetViewmodel.authorName
        contentLabel.attributedText = tweetViewmodel.attributedContent()
        dateLabel.text = tweetViewmodel.dateString
        
        /*
         There is no retain cycle currently, as tweetViewModel is instantiated within a
         function and its lifecycle ends when the function completes.
         Adding [weak self] to ensure safety in case of future changes.
         */
        tweetViewmodel.fetchAvatar { [weak self] result in
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
    }
    
    func setDefaultAvatar() {
        self.avatarView.image = UIImage(named: Constant.blankProfileImage)
        self.avatarView.tintColor = .white
        self.avatarView.backgroundColor = .gray
    }
}
