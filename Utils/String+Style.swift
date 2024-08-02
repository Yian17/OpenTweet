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
        // Styling for mentions (@username)
        static let mention: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.blue,
        ]
        
        // Styling for links
        static let link: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.blue,
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]
    }
    
    /// Finds ranges of mentions (@username) in the string
    /// - Returns: An array of NSRange for each mention found
    func rangeOfMentions() -> [NSRange] {
        let mentionPattern = "\\B@\\w+\\b"
        return ranges(matching: mentionPattern)
    }
    
    /// Finds ranges of links in the string
    /// - Returns: An array of NSRange for each link found
    func rangesOfLinks() -> [NSRange] {
        guard let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue) else {
            return []
        }
        
        let matches = detector.matches(in: self, options: [], range: NSRange(location: 0, length: self.utf16.count))
        return matches.map { $0.range }
    }
    
    /// Finds ranges matching a given regex pattern in the string
    /// - Parameter pattern: The regex pattern to match
    /// - Returns: An array of NSRange for each match found
    func ranges(matching pattern: String) -> [NSRange] {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
            return []
        }
        let range = NSRange(location: 0, length: self.utf16.count)
        let matches = regex.matches(in: self, options: [], range: range)
        return matches.map { $0.range }
    }
    
    /// Applies tweet styling (mentions and links) to the string
    /// - Parameter fontSize: The base font size for the tweet text
    /// - Returns: An NSAttributedString with styling applied
    func applyingTweetStyling(fontSize: CGFloat = 14) -> NSAttributedString {
        let baseFont = UIFont.systemFont(ofSize: fontSize)
        let baseAttributes: [NSAttributedString.Key: Any] = [.font: baseFont]
        
        let attributedString = NSMutableAttributedString(string: self)
        attributedString.addAttributes(baseAttributes, range: NSRange(location: 0, length: self.utf16.count))
        return attributedString.highlighting(ranges: self.rangeOfMentions(), with: TweetStyling.mention)
            .highlighting(ranges: self.rangesOfLinks(), with: TweetStyling.link)
    }
}

extension NSAttributedString {
    /// Applies given attributes to specified ranges in the attributed string
    /// - Parameters:
    ///   - ranges: An array of NSRange to apply attributes to
    ///   - attributes: The attributes to apply
    /// - Returns: A new NSAttributedString with the attributes applied
    func highlighting(ranges: [NSRange], with attributes: [NSAttributedString.Key: Any]) -> NSAttributedString {
        let mutableAttributedString = NSMutableAttributedString(attributedString: self)
        for range in ranges {
            mutableAttributedString.addAttributes(attributes, range: range)
        }
        return mutableAttributedString
    }
}

