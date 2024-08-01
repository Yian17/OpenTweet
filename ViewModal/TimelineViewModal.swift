//
//  TimelineViewmodel.swift
//  OpenTweet
//
//  Created by Wu Yian on 2024-07-30.
//  Copyright © 2024 OpenTable, Inc. All rights reserved.
//

import Foundation
import UIKit

class TimelineViewModel {
    var tweets: [TweetModel] = []
    
    private let serviceProvider: ServiceProtocol
    
    init(dataProvider: ServiceProtocol = Service()) {
        self.serviceProvider = dataProvider
    }
    
    func tweet(at index: Int) -> TweetViewModel {
        return TweetViewModel(tweet: tweets[index])
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

    func thread(for tweet: TweetModel) -> [TweetModel] {
        if tweet.inReplyTo != nil {
            // If it's a reply, find the tweet it's replying to
            let parent = tweets.filter { $0.id == tweet.inReplyTo }
            return parent + [tweet]
        } else {
            // If it's a root tweet, return it and all its direct replies
            let replies = tweets.filter { $0.inReplyTo == tweet.id }
            return [tweet] + replies
        }
    }
}

class TweetViewModel {
    // Error message used for unit testing
    var errorMessage = ""
    private let serviceProvider: ServiceProtocol
    let tweet: TweetModel
    
    init(tweet: TweetModel, dataProvier: ServiceProtocol = Service()) {
        self.tweet = tweet
        self.serviceProvider = dataProvier
    }
    
    var authorName: String {
        tweet.author
    }
    
    func attributedContent() -> NSAttributedString {
        tweet.content.applyingTweetStyling()
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
            self.setErrorMessage(error: RequestError.urlError)
            completion(.failure(RequestError.urlError))
            return
        }
        serviceProvider.fetchImage(from: urlString) { [weak self] result in
            switch result {
            case .failure(let error):
                self?.setErrorMessage(error: error)
                completion(.failure(error))
            case .success(let data):
                completion(.success(data))
            }
        }
    }
    
    func setErrorMessage(error:Error) {
        switch error {
        case RequestError.decodeError:
            errorMessage = "decodeError"
        case RequestError.noData:
            errorMessage = "noData"
        case RequestError.urlError:
            errorMessage = "urlError"
        case RequestError.noResponse:
            errorMessage = "noResponseFile"
        case RequestError.serializeError:
            errorMessage = "serializeError"
        default:
            errorMessage = ""
        }
    }
}
