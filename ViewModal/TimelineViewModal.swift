//
//  TimelineViewmodel.swift
//  OpenTweet
//
//  Created by Wu Yian on 2024-07-30.
//  Copyright © 2024 OpenTable, Inc. All rights reserved.
//

import Foundation

class TimelineViewmodel {
    private var tweets: [Tweetmodel] = []
    
    private let serviceProvider: ServiceProtocol
    
    init(dataProvider: ServiceProtocol = Service()) {
        self.serviceProvider = dataProvider
    }
    
    func tweet(at index: Int) -> TweetViewmodel {
        return TweetViewmodel(tweet: tweets[index])
    }
    
    func getNumberOfRowsInSection() -> Int {
        return tweets.count
    }
    
    func fetchTimeline() {
        if let timeline = serviceProvider.fetchTweets() {
            print(timeline)
            tweets = timeline.tweets
        }
    }
}

class TweetViewmodel {
    private let serviceProvider: ServiceProtocol
    let tweet: Tweetmodel
    
    init(tweet: Tweetmodel, dataProvier: ServiceProtocol = Service()) {
        self.tweet = tweet
        self.serviceProvider = dataProvier
    }
    
    var authorName: String {
        tweet.author
    }
    
    var content: String {
        tweet.content
    }
    
    var dateString: String {
        let isoDateFormatter = ISO8601DateFormatter()
        if let date = isoDateFormatter.date(from: tweet.date) {
            let newDateFormatter = DateFormatter()
            newDateFormatter.dateFormat = "MMM d, yyyy HH:mm"
            return newDateFormatter.string(from: date)
        } else {
            return tweet.date
        }
    }
    
    func fetchAvatar(completion: @escaping (Result<Data, Error>) -> Void) {
        guard let urlString = tweet.avatar else {
            completion(.failure(RequestError.urlError))
            return
        }
        
        serviceProvider.fetchImage(from: urlString, completion: completion)
    }
}
