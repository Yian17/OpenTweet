//
//  TimelineViewmodel.swift
//  OpenTweet
//
//  Created by Wu Yian on 2024-07-30.
//  Copyright © 2024 OpenTable, Inc. All rights reserved.
//

import Foundation
import UIKit

// MARK: - TimelineViewModel
class TimelineViewModel {
    /// Array of tweets in the timeline
    var tweets: [TweetModel] = []
    
    private let serviceProvider: ServiceProtocol
    
    /// Initializes the view model with a data provider
    /// - Parameter dataProvider: The service to use for fetching data
    init(dataProvider: ServiceProtocol = Service()) {
        self.serviceProvider = dataProvider
    }
    
    /// Retrieves a specific tweet from the timeline
    /// - Parameter index: The index of the tweet
    /// - Returns: The TweetModel at the specified index
    func tweet(at index: Int) -> TweetModel {
        return tweets[index]
    }
    
    /// Returns the number of tweets in the timeline
    /// - Returns: The count of tweets
    func getNumberOfRowsInSection() -> Int {
        return tweets.count
    }
    
    /// Fetches the timeline of tweets from the service provider
    func fetchTimeline() {
        if let timeline = serviceProvider.fetchTweets() {
            tweets = timeline.tweets
        }
    }

    /// Returns an array of tweets representing a thread, including the given tweet and its replies or parent
    /// - Parameter tweet: The tweet to get the thread for
    /// - Returns: An array of tweets in the thread
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

// MARK: - TweetViewModel
class TweetViewModel {
    // Error message used for unit testing
    var errorMessage = ""
    private let serviceProvider: ServiceProtocol
    var isInTimeline: Bool
    let tweet: TweetModel
    
    /// Initializes the view model with a tweet and service provider
    /// - Parameters:
    ///   - tweet: The tweet model
    ///   - isInTimeline: Whether the tweet is in the timeline view
    ///   - dataProvider: The service to use for fetching data
    init(tweet: TweetModel, isInTimeline: Bool = false, dataProvier: ServiceProtocol = Service()) {
        self.tweet = tweet
        self.serviceProvider = dataProvier
        self.isInTimeline = isInTimeline
    }
    
    var authorName: String {
        tweet.author
    }
    
    /// Returns an attributed string of the tweet content with highlighted mentions and links
    /// - Parameter fontSize: The font size to use
    /// - Returns: An attributed string of the tweet content
    func attributedContent(fontSize: CGFloat = 14) -> NSAttributedString {
        tweet.content.applyingTweetStyling(fontSize: fontSize)
    }
    
    /// Formats the tweet's date string
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
    
    var accessibilityLabel: String {
        return "\(authorName) tweeted: \(tweet.content). Posted on \(dateString)"
    }
    
    var accessibilityHint: String? {
        return isInTimeline ? "Double tap to view the thread" : nil
    }
    
    /// Fetches the avatar image for the tweet's author
    /// - Parameter completion: A closure to call with the result of the fetch
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
    
    private func setErrorMessage(error:Error) {
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
