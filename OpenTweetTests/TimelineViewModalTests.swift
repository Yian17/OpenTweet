//
//  OpenTweetTests.swift
//  OpenTweetTests
//
//  Created by Olivier Larivain on 9/30/16.
//  Copyright © 2016 OpenTable, Inc. All rights reserved.
//

import XCTest
@testable import OpenTweet

class TimelineViewModelTests: XCTestCase {
    var mockTimelineViewModel: TimelineViewModel?
    var mockService: MockService?
    
    override func setUp() {
        super.setUp()
        mockService = MockService()
        mockTimelineViewModel = TimelineViewModel(dataProvider: mockService ?? MockService())
    }
    
    override func tearDown() {
        super.tearDown()
        mockService = nil
        mockTimelineViewModel = nil
    }
    
    func testFetchTweets() {
        mockTimelineViewModel?.fetchTimeline()
        let tweetsList = mockTimelineViewModel?.tweets
        
        XCTAssertEqual(tweetsList?.count, 7)
        XCTAssertEqual(tweetsList?[0].id, "00001")
        XCTAssertEqual(tweetsList?[0].author, "@randomInternetStranger")
        XCTAssertEqual(tweetsList?[0].date, "2020-09-29T14:41:00-08:00")
        XCTAssertEqual(tweetsList?[0].content, "Man, I'm hungry. I probably should book a table at a restaurant or something. Wonder if there's an app for that?")
        XCTAssertEqual(tweetsList?[0].avatar, "https://i.imgflip.com/ohrrn.jpg")
        XCTAssertEqual(tweetsList?[0].inReplyTo, nil)
    }
    
    func testRowNumber() {
        mockTimelineViewModel?.fetchTimeline()
        XCTAssertEqual(mockTimelineViewModel?.getNumberOfRowsInSection(), 7)
    }
}


class MockService: ServiceProtocol {
    var mockError: Error?
    
    func fetchTweets() -> TimelineModel? {
        if let path = Bundle.main.path(forResource: "timeline", ofType: "json"),
        let data = try? Data(contentsOf: URL(fileURLWithPath: path)),
        let dataObject = try? JSONDecoder().decode(TimelineModel.self, from: data) {
            return dataObject
        }
        return nil
    }
    
    func fetchImage(from urlString: String, completion: @escaping (Result<Data, any Error>) -> Void) {
        if let error = self.mockError {
            completion(.failure(error))
            return
        } else {
            completion(.success(Data()))
        }
    }
}
