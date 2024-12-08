//
//  X+User.swift
//  hundredproject
//
//  Created by Duc Tran  on 18/11/24.
//

import Foundation

/// The user object contains Twitter user account metadata describing the referenced user.
public struct User: Codable, Identifiable {
    public typealias ID = String
    
    /// The unique identifier of this user.
    public let id: ID
    
    /// The name of the user, as they’ve defined it on their profile. Not necessarily a person’s name. Typically capped at 50 characters, but subject to change.
    public let name: String
    
    /// The Twitter screen name, handle, or alias that this user identifies themselves with. Usernames are unique but subject to change. Typically a maximum of 15 characters long, but some historical accounts may exist with longer names.
    public let username: String
    
    /// The URL to the profile image for this user, as shown on the user's profile.
    public let profileImageUrl: URL?
    
    /// A URL to larger version of the user's profile image
    public var profileImageUrlLarger: URL? {
        if let urlString = profileImageUrl?.absoluteString.replacingOccurrences(of: "_normal", with: "_x96") {
            return URL(string: urlString)
        } else {
            return profileImageUrl
        }
    }
    
    /// A URL to the original, unmodified version of the user's profile image. This image may be very large.
    public var profileImageUrlOriginal: URL? {
        if let urlString = profileImageUrl?.absoluteString.replacingOccurrences(of: "_normal", with: "_original") {
            return URL(string: urlString)
        } else {
            return profileImageUrl
        }
    }
    
    public struct Includes: Codable {
       
    }
}

extension User: Fielded {
    /// Additional fields that can be requested for User objects
    public typealias Field = PartialKeyPath<User>
    
    static internal func fieldName(field: PartialKeyPath<User>) -> String? {
        switch field {
        case \.profileImageUrl: return "profile_image_url"
        default: return nil
        }
    }
    
    static internal var fieldParameterName = "user.fields"
}
