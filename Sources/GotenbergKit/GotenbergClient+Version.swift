//
//  GotenbergClient+Version.swift
//  gotenberg-kit
//
//  Created by Florian Friedrich on 10.06.25.
//

import typealias Foundation.TimeInterval

extension GotenbergClient {
    /// Get the current Gotenberg version.
    /// - Parameters:
    ///   - waitTimeout: Timeout in seconds for the Gotenberg server
    ///   - clientHTTPHeaders: Custom headers for GotenbergKit
    /// - Returns: The version of the Gotenberg instance this client connects to.
    public func version(
        waitTimeout: TimeInterval = 10,
        clientHTTPHeaders: [String: String] = [:]
    ) async throws -> String {
        let timeoutSeconds = Int64(waitTimeout)
        let request = makeRequest(method: .GET, route: "version", timeoutSeconds: timeoutSeconds, headers: clientHTTPHeaders)
        let response = try await sendRequestWithRetry(request, timeoutSeconds: timeoutSeconds)
        // The version response is a simple string. 1kB is more than enough.
        let responseData = try await response.body.collect(upTo: 1024)
        return String(buffer: responseData)
    }
}
