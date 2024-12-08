//
//  APISubpath.swift
//  hundredproject
//
//  Created by Duc Tran  on 18/11/24.
//


import Foundation

let envDict = ProcessInfo.processInfo.environment
let env = envDict["ENVIRONMENT"]
let isTestEnvironment = env == "TEST"

extension Twift {
  // MARK: Internal helper methods
  internal func call<T: Codable>(route: APIRoute,
                                 method: HTTPMethod = .GET,
                                 queryItems: [URLQueryItem] = [],
                                 body: Data? = nil
  ) async throws -> T {
    if case AuthenticationType.oauth2UserAuth(_, _) = self.authenticationType {
      try await self.refreshOAuth2AccessToken()
    }
    
    let url = getURL(for: route, queryItems: queryItems)
    var request = URLRequest(url: url)
    
    if let body = body {
      request.httpBody = body
      request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    }
    
    signURLRequest(method: method, body: body, request: &request)

    let (data, _) = try await URLSession.shared.data(for: request)
    
    return try decodeOrThrow(decodingType: T.self, data: data)
  }
  
  internal func fieldsAndExpansions<T: Fielded>(for type: T.Type,
                                                             fields: Set<T.Field>
  ) -> [URLQueryItem] {
    var queryItems: [URLQueryItem] = []
    
    if !fields.isEmpty { queryItems.append(URLQueryItem(name: T.fieldParameterName, value: fields.compactMap { T.fieldName(field: $0) }.joined(separator: ","))) }
    
    return queryItems
  }
}

extension Twift {
    internal func getURL(for route: APIRoute, queryItems: [URLQueryItem] = []) -> URL {
        var combinedQueryItems: [URLQueryItem] = []
        
        combinedQueryItems.append(contentsOf: queryItems)
        
        if let routeQueryItems = route.resolvedPath.queryItems {
            combinedQueryItems.append(contentsOf: routeQueryItems)
        }
        
        var components = URLComponents()
        components.scheme = "https"
        components.host = isTestEnvironment ? "stoplight.io" : "api.twitter.com"
        
        if isTestEnvironment {
            components.path = "/mocks/dte/twitter-v2-api-spec/54953920\(route.resolvedPath.path)"
        } else {
            components.path = "\(route.resolvedPath.path)"
        }
        
        components.queryItems = combinedQueryItems
        
        var allowedCharacters = CharacterSet.urlQueryAllowed
        allowedCharacters.remove(charactersIn: ":()")
        components.percentEncodedQuery = components.query?.addingPercentEncoding(withAllowedCharacters: allowedCharacters)
        
        return components.url!
    }
    
    internal func signURLRequest(method: HTTPMethod, body: Data? = nil, request: inout URLRequest) {
        switch authenticationType {
        case .appOnly(let bearerToken):
            request.addValue("Bearer \(bearerToken)", forHTTPHeaderField: "Authorization")
        case .userAccessTokens(let clientCredentials, let userCredentials):
            request.oAuthSign(
                method: method.rawValue,
                body: body,
                consumerCredentials: clientCredentials,
                userCredentials: userCredentials
            )
        case .oauth2UserAuth(let oauthUser, _):
            request.addValue("Bearer \(oauthUser.accessToken)", forHTTPHeaderField: "Authorization")
        }
        
        request.httpMethod = method.rawValue
    }
}


extension Twift {
    internal enum APIRoute {
        case me
        case tweets
        
        
        var resolvedPath: (path: String, queryItems: [URLQueryItem]?) {
            switch self {
            case .tweets:
                return (path: "/2/tweets", queryItems: nil)
            case .me:
                return (path: "/2/users/me", queryItems: nil)
                
                
            }
        }
    }
    
    internal func decodeOrThrow<T: Codable>(decodingType: T.Type, data: Data) throws -> T {
        guard let result = try? decoder.decode(decodingType.self, from: data) else {
            if let error = try? decoder.decode(TwitterAPIError.self, from: data) { throw error }
            
            throw TwiftError.UnknownError(String(data: data, encoding: .utf8))
        }
        
        return result
    }
}

/// The response object from the Twitter API containing the requested object(s) in the `data` property
public struct TwitterAPIData<Resource: Codable>: Codable {
    /// The requested object(s)
    public let data: Resource
    
    /// Any errors associated with the request
    public let errors: [TwitterAPIError]?
}

/// The response object from the Twitter API containing the requested object(s) in the `data` property
public struct TwitterAPIDataAndMeta<Resource: Codable, Meta: Codable>: Codable {
    /// The requested object(s)
    public let data: Resource?
    
    /// The meta information for the request, including pagination information
    public let meta: Meta?
    
    /// Any errors associated with the request
    public let errors: [TwitterAPIError]?
}

/// A response object from the Twitter API containing the requested object(s) in the `data` property, and expansions in the `includes` property
public struct TwitterAPIDataAndIncludes<Resource: Codable, Includes: Codable>: Codable {
    /// The requested object(s)
    public let data: Resource
    
    /// Any requested expansions
    public let includes: Includes?
    
    /// Any errors associated with the request
    public let errors: [TwitterAPIError]?
}

/// A response object from the Twitter API containing the requested object(s) in the `data` property,  expansions in the `includes` property, and additional information (such as pagination tokens) in the `meta` property
public struct TwitterAPIDataIncludesAndMeta<Resource: Codable, Includes: Codable, Meta: Codable>: Codable {
    /// The requested object(s)
    public let data: Resource
    
    /// Any requested expansions
    public let includes: Includes?
    
    /// The meta information for the request, including pagination information
    public let meta: Meta?
    
    /// Any errors associated with the request
    public let errors: [TwitterAPIError]?
}

internal enum HTTPMethod: String {
    case GET, POST, DELETE, PUT
}

/// An object containing pagination information for paginated requests
public struct Meta: Codable {
    /// The number of results in this page
    public let resultCount: Int
    
    /// The pagination token for the next page of results, if any
    public let nextToken: String?
    
    /// The pagination token for the previous page of results, if any
    public let previousToken: String?
}
