//
//  TweetViewModelTests.swift
//  OpenTweetTests
//
//  Created by Wu Yian on 2024-08-01.
//  Copyright © 2024 OpenTable, Inc. All rights reserved.
//

import XCTest
@testable import OpenTweet

final class TweetViewModelTests: XCTestCase {
    var mockTimelineViewModel: TimelineViewModel?
    var mockTweetViewModel: TweetViewModel?
    var mockService: MockService?

    override func setUp() {
        super.setUp()
        mockService = MockService()
        mockTimelineViewModel = TimelineViewModel(dataProvider: mockService ?? MockService())
        mockTimelineViewModel?.fetchTimeline()
        
        mockTweetViewModel = TweetViewModel(tweet: mockTimelineViewModel?.tweets[1] ?? TweetModel(id: "", author: "", content: "", date: "", inReplyTo: nil, avatar: nil, images: nil), dataProvier: mockService ?? MockService())
    }
    
    override func tearDown() {
        super.tearDown()
        mockService = nil
        mockTimelineViewModel = nil
        mockTweetViewModel = nil
    }
    
    func testFetchAvatarFail() {
        mockService?.mockError = RequestError.noData
        mockTweetViewModel?.fetchAvatar(completion: { result in
            switch result {
            case .success(let url):
                print("Url Fetched: \(url)")
            case .failure(let error):
                print("Error: \(error)")
            }
        })
        XCTAssertEqual(mockTweetViewModel?.errorMessage, "noData")
    }
    
    func testFetchAvatarSuccess() {
        mockService?.mockError = nil
        var imageData: Data?
        mockTweetViewModel?.fetchAvatar(completion: { result in
            switch result {
            case .success(let data):
                imageData = data
            case .failure(let error):
                print("Error: \(error)")
            }
        })
        XCTAssertTrue(imageData != nil)
    }
    
    func testDateStringFormat() {
        XCTAssertEqual(mockTweetViewModel?.dateString, "Sep 30, 2020 13:41")
    }
}
