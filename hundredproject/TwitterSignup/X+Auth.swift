//
//  AuthenticationType.swift
//  hundredproject
//
//  Created by Duc Tran  on 18/11/24.
//


import Foundation
import AuthenticationServices

extension Twift {
    /// The available authentication types for initializing new `Twift` client instances
    public enum AuthenticationType {
        /// OAuth 1.0a User Access Token authentication.
        ///
        /// User credentials can be obtained by calling ``Twift.Authentication().requestUserCredentials()``
        @available(*, deprecated, message: "OAuth 1.0a authentication will be removed in a future stable version of Twift. Use the `AuthenticationType.oauth2UserContext` instead.")
        case userAccessTokens(clientCredentials: OAuthCredentials,
                              userCredentials: OAuthCredentials)
        
        
        /// OAuth 2.0 User Context authentication.
        ///
        /// When this authentication method is used, the `oauth2User` access token may be automatically refreshed by the client if it has expired.
        case oauth2UserAuth(_ oauth2User: OAuth2User, onRefresh: ((OAuth2User) -> Void)?)
        
        /// App-only authentication
        case appOnly(bearerToken: String)
    }
    
    /// A convenience enum for representing ``AuthenticationType`` without associated values in auth-related errors
    public enum AuthenticationTypeRepresentation: String {
        /// A value representing ``AuthenticationType.userAccessTokens(_, _)``
        @available(*, deprecated, message: "OAuth 1.0a authentication will be removed in a future stable version of Twift. Use the `AuthenticationType.oauth2UserContext` instead.")
        case userAccessTokens
        
        /// A value representing ``AuthenticationType.oauth2UserContext(_)``
        case oauth2UserAuth
        
        /// A value representing ``AuthenticationType.appOnly(_)``
        case appOnly
    }
    
    /// A convenience class for acquiring user access token
    public class Authentication: NSObject, ASWebAuthenticationPresentationContextProviding {
        public func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
            return ASPresentationAnchor()
        }
    }
}

extension Twift.Authentication {
    /// Authenticates the user using Twitter's OAuth 2.0 PKCE flow.
    /// - Parameters:
    ///   - clientId: The client ID for your Twitter API app
    ///   - redirectUri: The URI to redirect users to after completing authentication.
    ///   - scope: The user access scopes for your authentication. For automatic token refreshing, ensure that `offlineAccess` is included in the scope.
    ///   - presentationContextProvider: Optional presentation context provider. When not provided, this function will handle the presentation context itself.
    /// - Returns: A tuple containing the authenticated user access tokens or any encoutered error.
    @_disfavoredOverload
    @available(*, deprecated, message: "Use throwing 'authenticateUser' function instead")
    public func authenticateUser(clientId: String,
                                 redirectUri: URL,
                                 scope: Set<OAuth2Scope>,
                                 presentationContextProvider: ASWebAuthenticationPresentationContextProviding? = nil
    ) async -> (OAuth2User?, Error?) {
        do {
            let oauthUser: OAuth2User = try await authenticateUser(clientId: clientId, redirectUri: redirectUri, scope: scope, presentationContextProvider: presentationContextProvider)
            return (oauthUser, nil)
        } catch {
            return (nil, error)
        }
    }
    
    /// Authenticates the user using Twitter's OAuth 2.0 PKCE flow.
    /// - Parameters:
    ///   - clientId: The client ID for your Twitter API app
    ///   - redirectUri: The URI to redirect users to after completing authentication.
    ///   - scope: The user access scopes for your authentication. For automatic token refreshing, ensure that `offlineAccess` is included in the scope.
    ///   - presentationContextProvider: Optional presentation context provider. When not provided, this function will handle the presentation context itself.
    /// - Returns: The authenticated user access tokens.
    @MainActor
    public func authenticateUser(clientId: String,
                                 redirectUri: URL,
                                 scope: Set<OAuth2Scope>,
                                 presentationContextProvider: ASWebAuthenticationPresentationContextProviding? = nil
    ) async throws -> OAuth2User {
        let state = UUID().uuidString
        
        let authUrlQueryItems: [URLQueryItem] = [
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "client_id", value: clientId),
            URLQueryItem(name: "redirect_uri", value: redirectUri.absoluteString),
            URLQueryItem(name: "scope", value: scope.map(\.rawValue).joined(separator: " ")),
            URLQueryItem(name: "state", value: state),
            URLQueryItem(name: "code_challenge", value: "challenge"),
            URLQueryItem(name: "code_challenge_method", value: "plain"),
        ]
        
        var authUrl = URLComponents()
        authUrl.scheme = "https"
        authUrl.host = "twitter.com"
        authUrl.path = "/i/oauth2/authorize"
        authUrl.queryItems = authUrlQueryItems
        
        let returnedUrl: URL = try await withCheckedThrowingContinuation { continuation in
            guard let authUrl = authUrl.url else {
                return continuation.resume(throwing: TwiftError.UnknownError(nil))
            }
            
            let authSession = ASWebAuthenticationSession(url: authUrl, callbackURLScheme: redirectUri.scheme) { (url, error) in
                if let error = error {
                    return continuation.resume(throwing: error)
                }
                if let url = url {
                    return continuation.resume(returning: url)
                }
                return continuation.resume(throwing: TwiftError.UnknownError("There was a problem authenticating the user: no URL was returned from the first authentication step."))
            }
            
            authSession.presentationContextProvider = presentationContextProvider ?? self
            authSession.start()
        }
        
        let returnedUrlComponents = URLComponents(string: returnedUrl.absoluteString)
        
        let returnedState = returnedUrlComponents?.queryItems?.first(where: { $0.name == "state" })?.value
        guard let returnedState = returnedState,
              returnedState == state else {
            throw TwiftError.UnknownError("There was a problem authenticating the user: the state values for the first authentication step are not equal.")
        }
        
        let returnedCode = returnedUrlComponents?.queryItems?.first(where: { $0.name == "code" })?.value
        guard let returnedCode = returnedCode else {
            throw TwiftError.UnknownError("There was a problem authenticating the user: no request token was found in the returned URL.")
        }
        
        var codeRequest = URLRequest(url: URL(string: "https://api.twitter.com/2/oauth2/token")!)
        let body = [
            "code": returnedCode,
            "grant_type": "authorization_code",
            "client_id": clientId,
            "redirect_uri": redirectUri.absoluteString,
            "code_verifier": "challenge"
        ]
        
        let encodedBody = OAuthHelper.httpBody(forFormParameters: body)
        
        codeRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        codeRequest.httpMethod = "POST"
        codeRequest.httpBody = encodedBody
        
        do {
            let (data, _) = try await URLSession.shared.data(for: codeRequest)
            
            var oauth2User = try JSONDecoder().decode(OAuth2User.self, from: data)
            oauth2User.clientId = clientId
            
            return oauth2User
        } catch {
            print(error.localizedDescription)
        }
        
        throw TwiftError.UnknownError("Unable to fetch and decode the OAuth 2.0 user context.")
    }
}

/// An OAuth 2.0 user authentication object
public struct OAuth2User: Codable {
    /// The client ID for which this OAuth token is valid
    public var clientId: String?
    
    /// The current access token, valid until `expiresAt`
    public var accessToken: String
    
    /// The refresh token, used to renew authentication once the `accessToken` has expired. Only available when `scope` includes `offlineAccess`.
    public var refreshToken: String?
    
    /// The date at which the `accessToken` expires.
    public var expiresAt: Date
    
    /// The scope of permissions for this access token.
    public var scope: Set<OAuth2Scope>
    
    /// Whether or not the access token has expired (i.e. whether `expiresAt` is in the past).
    public var expired: Bool {
        expiresAt < .now
    }
    
    internal enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        
        case expiresIn = "expires_in"
        case expiresAt = "expires_at"
        case clientId = "client_id"
        case scope
    }
    
    /// Initialises a new OAuth2User object from a decoder
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        accessToken = try values.decode(String.self, forKey: .accessToken)
        refreshToken = try values.decodeIfPresent(String.self, forKey: .refreshToken)
        clientId = try values.decodeIfPresent(String.self, forKey: .clientId)
        
        var decodedExpiresAt = try values.decodeIfPresent(Date.self, forKey: .expiresAt)
        
        if decodedExpiresAt == nil,
           let expiresIn = try values.decodeIfPresent(Double.self, forKey: .expiresIn) {
            decodedExpiresAt = Date().addingTimeInterval(expiresIn)
        }
        
        expiresAt = decodedExpiresAt!
        
        let scopeArray = try values.decode(String.self, forKey: .scope)
        scope = Set(scopeArray.split(separator: " ").compactMap { OAuth2Scope.init(rawValue: String($0)) })
    }
    
    /// Convenience initialiser for creating a new OAuth2User from known values
    public init(accessToken: String, refreshToken: String? = nil, clientId: String? = nil, expiresIn: TimeInterval = 7200, scope: Set<OAuth2Scope>) {
        self.accessToken = accessToken
        self.expiresAt = Date().addingTimeInterval(expiresIn)
        self.refreshToken = refreshToken
        self.clientId = clientId
        self.scope = scope
    }
    
    /// Encodes the OAuth2User instance to an encoder
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(accessToken, forKey: .accessToken)
        try container.encodeIfPresent(refreshToken, forKey: .refreshToken)
        try container.encode(expiresAt, forKey: .expiresAt)
        try container.encodeIfPresent(clientId, forKey: .clientId)
        
        let scopes = scope.map(\.rawValue).joined(separator: " ")
        try container.encode(scopes, forKey: .scope)
    }
}

/// The available access scopes for Twitter's OAuth 2.0 user authentication.
public enum OAuth2Scope: String, CaseIterable, RawRepresentable {
    /// All the Tweets you can view, including Tweets from protected accounts.
    case tweetRead = "tweet.read"
    
    /// Tweet and Retweet for you.
    case tweetWrite = "tweet.write"
    
    /// Hide and unhide replies to your Tweets.
    case tweetModerateWrite = "tweet.moderate.write"
    
    /// Any account you can view, including protected accounts.
    case usersRead = "users.read"
    
    /// Lists, list members, and list followers of lists you’ve created or are a member of, including private lists.
    static var freeScope: Set<OAuth2Scope> {
        [.tweetRead, .usersRead, .tweetWrite]
    }
}
