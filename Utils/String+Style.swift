//
//  String+Format.swift
//  OpenTweet
//
//  Created by Wu Yian on 2024-07-31.
//  Copyright © 2024 OpenTable, Inc. All rights reserved.
//

import Foundation
import UIKit

extension String {
    struct TweetStyling {
        static let mention: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.blue,
            .font: UIFont.boldSystemFont(ofSize: 14)
        ]
        
        static let link: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.blue,
            .font: UIFont.boldSystemFont(ofSize: 14),
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]
    }
    
    func rangeOfMentions() -> [NSRange] {
        let mentionPattern = "\\B@\\w+\\b"
        return ranges(matching: mentionPattern)
    }
    
    func rangesOfLinks() -> [NSRange] {
        guard let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue) else {
            return []
        }
        
        let matches = detector.matches(in: self, options: [], range: NSRange(location: 0, length: self.utf16.count))
        return matches.map { $0.range }
    }
    
    func ranges(matching pattern: String) -> [NSRange] {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
            return []
        }
        let range = NSRange(location: 0, length: self.utf16.count)
        let matches = regex.matches(in: self, options: [], range: range)
        return matches.map { $0.range }
    }
    
    func applyingTweetStyling() -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: self)
        return attributedString.highlighting(ranges: self.rangeOfMentions(), with: TweetStyling.mention)
            .highlighting(ranges: self.rangesOfLinks(), with: TweetStyling.link)
    }
}

extension NSAttributedString {    
    func highlighting(ranges: [NSRange], with attributes: [NSAttributedString.Key: Any]) -> NSAttributedString {
        let mutableAttributedString = NSMutableAttributedString(attributedString: self)
        for range in ranges {
            mutableAttributedString.addAttributes(attributes, range: range)
        }
        return mutableAttributedString
    }
}

