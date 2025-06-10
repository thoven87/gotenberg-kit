//
//  GotenbergClient+Health.swift
//  gotenberg-kit
//
//  Created by Florian Friedrich on 10.06.25.
//

import class Foundation.ISO8601DateFormatter
import class Foundation.JSONDecoder
import typealias Foundation.TimeInterval

extension GotenbergClient {
    /// Get the current Gotenberg health status.
    /// - Parameters:
    ///   - waitTimeout: Timeout in seconds for the Gotenberg server
    ///   - clientHTTPHeaders: Custom headers for GotenbergKit
    /// - Returns: The health of the Gotenberg instance this client connects to.
    public func health(
        waitTimeout: TimeInterval = 30,
        clientHTTPHeaders: [String: String] = [:]
    ) async throws -> GotenbergHealth {
        let timeoutSeconds = Int64(waitTimeout)
        let request = makeRequest(method: .GET, route: "health", timeoutSeconds: timeoutSeconds, headers: clientHTTPHeaders)
        let response = try await sendRequestWithRetry(request, timeoutSeconds: timeoutSeconds)
        // Health response is a rather simple JSON. 8kB are more than enough space.
        let responseData = try await response.body.collect(upTo: 1024 * 8)
        let decoder = JSONDecoder()
        // The standard ISO8601 format does not include fractional seconds, but the Gotenberg response does.
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            guard let date = formatter.date(from: dateString)
            else { throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid ISO8601 date: '\(dateString)'") }
            return date
        }
        return try decoder.decode(GotenbergHealth.self, from: responseData)
    }
}
