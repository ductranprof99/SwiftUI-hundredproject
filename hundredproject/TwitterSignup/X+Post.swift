//
//  X+Post.swift
//  hundredproject
//
//  Created by Duc Tran  on 18/11/24.
//

import Foundation

public struct PostTweetResponse: Codable {
    /// The unique ID of the new Tweet
    public let id: String
    
    /// The text content of the new Tweet
    public let text: String
}

/// A mutable Tweet object for creating new Tweets via the `postTweet` method
public struct MutableTweet: Codable {
    /// Text of the Tweet being created. This field is required if `media.mediaIds` is not present.
    public var text: String?
    
    /// A JSON object that contains media information being attached to created Tweet. This is mutually exclusive from Quote Tweet ID and Poll.
    public var media: MutableMedia?
    
    /// A JSON object that contains options for a Tweet with a poll. This is mutually exclusive from Media and Quote Tweet ID.
    public var poll: MutablePoll?
    
    /// Link to the Tweet being quoted.
    public var quoteTweetId: String?
    
    /// Information about the Tweet this Tweet is replying to
    public var reply: Reply?
    
    /// Settings to indicate who can reply to the Tweet. Options include "mentionedUsers" and "following". If the field isn’t specified, it will default to everyone.
    public var replySettings: ReplyAudience?
    
    /// An object describing how to form a reply to a Tweet
    public struct Reply: Codable {
        /// An array of User IDs to exclude from the replying Tweet
        public var excludeReplyUserIds: [User.ID]?
        
        /// The ID of the Tweet that this Tweet is replying to
        public var inReplyToTweetId: String?
        
        public init(inReplyToTweetId: String, excludeReplyUserIds: [User.ID]? = nil) {
            self.inReplyToTweetId = inReplyToTweetId
            self.excludeReplyUserIds = excludeReplyUserIds
        }
    }
    
    public init(text: String? = nil,
                media: MutableMedia? = nil,
                poll: MutablePoll? = nil,
                quoteTweetId:  String? = nil,
                reply: Reply? = nil,
                replySettings: ReplyAudience? = nil) {
        self.text = text
        self.media = media
        self.poll = poll
        self.quoteTweetId = quoteTweetId
        self.reply = reply
        self.replySettings = replySettings
    }
}

/// A mutable Media object for posting media with `MutableTweet`
public struct MutableMedia: Codable {
    /// A list of Media IDs being attached to the Tweet.
    public var mediaIds: [String]?
    
    /// A list of User IDs being tagged in the Tweet with Media. If the user you're tagging doesn't have photo-tagging enabled, their names won't show up in the list of tagged users even though the Tweet is successfully created.
    public var taggedUserIds: [User.ID]?
    
    public init(mediaIds: [String], taggedUserIds: [User.ID]? = nil) {
        self.mediaIds = mediaIds
        self.taggedUserIds = taggedUserIds
    }
}

/// A mutable Poll object for posting polls with `MutableTweet`
public struct MutablePoll: Codable {
    /// Duration of the poll in minutes for a Tweet with a poll.
    public var durationMinutes: Int
    
    /// A list of poll options for a Tweet with a poll.
    public var options: [String]
    
    /// Initialize a new ``MutablePoll`` with the specified options and duration. This initializer throws if there are less than 2 or more than 4 poll options.
    public init(options: [String], durationMinutes: Int = 60 * 24) throws {
        guard options.count > 1 && options.count <= 4 else {
            throw TwiftError.RangeOutOfBoundsError(min: 2, max: 4, fieldName: "options.count", actual: options.count)
        }
        self.options = options
        self.durationMinutes = durationMinutes
    }
}

public enum ReplyAudience: String, Codable {
    /// Everyone on Twitter can reply to the associated Tweet
    case everyone
    
    /// Only users who follow the Tweet author can reply
    case following
    
    /// Only users mentioned in the Tweet can reply
    case mentionedUsers
}
