//
//  TimelineModel.swift
//  OpenTweet
//
//  Created by Wu Yian on 2024-07-30.
//  Copyright © 2024 OpenTable, Inc. All rights reserved.
//

import Foundation

struct Timelinemodel: Codable {
    let tweets: [TweetModel]
    
    enum CodingKeys: String, CodingKey {
        case tweets = "timeline"
    }
}
