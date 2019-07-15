//
// This source file is part of Kombucha, an open source project by Wayfair
//
// Copyright (c) 2019 Wayfair, LLC.
// Licensed under the 2-Clause BSD License
//
// See LICENSE.md for license information
//

import Cont
import Foundation
import JSONValue

public extension SnapConfiguration {
    func fetch(
        decoder: JSONDecoder,
        encoder: JSONEncoder,
        session: URLSession) throws -> Cont<Result<JSONValue, Error>> {
        let request = try toURLRequest(encoder: encoder)
        return session.task(request)
            .map { Result<Data, Error>.extractResponse(data: $0.0, response: $0.1, error: $0.2) }
            .map { $0.flatMap { data in .init { try decoder.decode(JSONValue.self, from: data) } } }
    }

    func toURLRequest(encoder: JSONEncoder) throws -> URLRequest {
        switch request {
        case .get(let getSnap):
            return .init(url: try getSnap.toURL().value)
        case .graphQL(let graphQLSnap):
            var request = URLRequest(url: try graphQLSnap.toURL().value)
            request.httpBody = try encoder.encode(try EncodableGraphQLQueryContent(graphQLSnap.queryContent))
            request.httpMethod = "POST"
            return request
        }
    }
}

private struct EncodableGraphQLQueryContent: Encodable {
    let operationName: String?
    let query: String
    let variables: [String: String]?

    init (_ content: GraphQLQueryContent) throws {
        query = try content.getQueryText()
        operationName = content.operationName
        variables = content.variables
    }
}