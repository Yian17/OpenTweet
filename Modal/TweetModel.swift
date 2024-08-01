//
//  TweetModel.swift
//  OpenTweet
//
//  Created by Wu Yian on 2024-07-30.
//  Copyright © 2024 OpenTable, Inc. All rights reserved.
//

import Foundation

struct TweetModel: Codable {
    let id: String
    let author: String
    let content: String
    let date: String
    
    // Following are optional
    let inReplyTo: String?
    let avatar: String?
    let images: [String]?
}
