import Foundation

extension Twift {
    // MARK: User Lookup Methods
    /// Equivalent to `GET /2/users/me`.
    /// - Parameters:
    ///   - fields: Any additional fields to include on returned objects
    ///   - expansions: Objects and their corresponding fields that should be expanded in the `includes` property
    /// - Returns: A Twitter API response object containing the ``User`` and any pinned tweets
    public func getMe(fields: Set<User.Field> = []
    ) async throws -> TwitterAPIDataAndIncludes<User, User.Includes> {
        let queryItems = fieldsAndExpansions(for: User.self, fields: fields)
        
        return try await call(route: .me,
                              queryItems: queryItems)
    }
    
    /// Creates a Tweet on behalf of an authenticated user.
      /// - Parameter tweet: The payload of the post Tweet request
      /// - Returns: A data object with the newly-created Tweet's ID and text
      @discardableResult
    public func postTweet(_ tweet: MutableTweet) async throws -> TwitterAPIData<PostTweetResponse> {
        let body = try encoder.encode(tweet)
        return try await call(route: .tweets,
                              method: .POST,
                              body: body)
    }
}
