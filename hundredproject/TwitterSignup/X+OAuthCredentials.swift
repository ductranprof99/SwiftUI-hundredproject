//
//  OAuthCredentials.swift
//  hundredproject
//
//  Created by Duc Tran  on 18/11/24.
//


import Foundation

/// A structure containing OAuth key and secret tokens
public struct OAuthCredentials: Codable {
  /// The public OAuth key (also referred to as the OAuth application key or access token)
  public let key: String
  
  /// The private OAuth secrey (also referred to as the OAuth application secret or access token secret)
  public let secret: String
  
  /// An optional User ID
  public let userId: String?
  
  /// Coding keys for decoding oauth token responses from the Twitter API
  enum CodingKeys: String, CodingKey {
    case key = "oauth_token"
    case secret = "oauth_token_secret"
    case userId = "user_id"
  }
  
  /// Initialise an OAuth token from a known key, secret, and optional user ID
  public init(key: String, secret: String, userId: String? = nil) {
    self.key = key
    self.secret = secret
    self.userId = userId
  }
}

internal protocol EntityObject: Codable {
  var start: Int { get }
  var end: Int { get }
}

internal protocol Expandable: Codable {
  associatedtype Expansions: Expansion
}

internal protocol Fielded {
  associatedtype Field: PartialKeyPath<Self>
  static func fieldName(field: Field) -> String?
  static var fieldParameterName: String { get }
}


internal protocol Expansion {
  var rawValue: String { get }
  var fields: URLQueryItem? { get }
}
