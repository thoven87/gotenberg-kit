//
//  GotenbergClient+Chromium+Screenshots.swift
//  gotenberg-kit
//
//  Created by Stevenson Michel on 4/12/25.
//

import struct Foundation.Data
import struct Foundation.TimeInterval
import struct Foundation.URL

// MARK: - HTML Screenshot Methods
extension GotenbergClient {

    /// Capture a screenshot of HTML content
    /// - Parameters:
    ///   - html: The HTML content as Data
    ///   - assets: Optional dictionary of assets keyed by filename
    ///   - options: Screenshot options
    ///   - waitTimeout: Timeout in seconds for the Gotenberg server
    ///   - clientHTTPHeaders: Custom headers for GotenbergKit
    /// - Returns: GotenbergResponse containing the screenshot image
    public func capture(
        html: Data,
        assets: [String: Data] = [:],
        options: ScreenshotOptions = ScreenshotOptions(),
        waitTimeout: TimeInterval = 120,
        clientHTTPHeaders: [String: String] = [:]
    ) async throws -> GotenbergResponse {
        logger.debug("Capturing screenshot of HTML")

        var files: [FormFile] = [
            FormFile(
                name: "files",
                filename: "index.html",
                contentType: "text/html",
                data: html
            )
        ]

        // Add assets
        for (filename, data) in assets {
            files.append(
                FormFile(
                    name: "files",
                    filename: filename,
                    contentType: contentTypeForFilename(filename),
                    data: data
                )
            )
        }

        return try await sendFormRequest(
            route: "/forms/chromium/screenshot/html",
            files: files,
            values: options.formValues,
            headers: clientHTTPHeaders,
            timeoutSeconds: Int64(waitTimeout)
        )
    }

    /// Capture a screenshot of MarkDown content
    ///  the html content should have the following {{ toHTML "index.md" }}
    ///  to render the markdown content
    /// - Parameters:
    ///   - html: The HTML content as Data
    ///   - markdown: The markdown content
    ///   - assets: Optional dictionary of assets keyed by filename
    ///   - options: Screenshot options
    ///   - waitTimeout: Timeout in seconds for the Gotenberg server
    ///   - clientHTTPHeaders: Custom headers for GotenbergKit
    /// - Returns: GotenbergResponse containing the screenshot image
    public func capture(
        html: Data,
        markdown: Data,
        options: ScreenshotOptions = ScreenshotOptions(),
        waitTimeout: TimeInterval = 120,
        clientHTTPHeaders: [String: String] = [:]
    ) async throws -> GotenbergResponse {
        logger.debug("Capturing screenshot of Markdown")

        let files: [FormFile] = [
            FormFile(
                name: "files",
                filename: "index.html",
                contentType: "text/html",
                data: html
            ),
            FormFile(
                name: "files",
                filename: "index.md",
                contentType: "text/markdown",
                data: markdown
            ),
        ]

        return try await sendFormRequest(
            route: "/forms/chromium/screenshot/markdown",
            files: files,
            values: options.formValues,
            headers: clientHTTPHeaders,
            timeoutSeconds: Int64(waitTimeout)
        )
    }

    /// Capture a screenshot of HTML content from a string
    /// - Parameters:
    ///   - html: The HTML content as a string
    ///   - assets: Optional dictionary of assets keyed by filename
    ///   - options: Screenshot options
    ///   - waitTimeout: Timeout in seconds for the Gotenberg server
    ///   - clientHTTPHeaders: Custom headers for GotenbergKit
    /// - Returns: GotenbergResponse containing the screenshot image
    public func capture(
        html: String,
        assets: [String: Data] = [:],
        options: ScreenshotOptions = ScreenshotOptions(),
        waitTimeout: TimeInterval = 120,
        clientHTTPHeaders: [String: String] = [:]
    ) async throws -> GotenbergResponse {
        try await capture(
            html: Data(html.utf8),
            assets: assets,
            options: options,
            waitTimeout: waitTimeout,
            clientHTTPHeaders: clientHTTPHeaders
        )
    }

    // MARK: - URL Screenshot Methods

    /// Capture a screenshot of a URL
    /// - Parameters:
    ///   - url: The URL to capture
    ///   - options: Screenshot options
    ///   - waitTimeout: Timeout in seconds for the Gotenberg server
    ///   - clientHTTPHeaders: Custom headers for GotenbergKit
    /// - Returns: Data containing the screenshot image
    public func capture(
        url: URL,
        options: ScreenshotOptions = ScreenshotOptions(),
        waitTimeout: TimeInterval = 120,
        clientHTTPHeaders: [String: String] = [:]
    ) async throws -> GotenbergResponse {
        logger.debug("Capturing screenshot of URL: \(url.absoluteString)")

        var values = options.formValues
        values["url"] = url.absoluteString

        return try await sendFormRequest(
            route: "/forms/chromium/screenshot/url",
            files: [],
            values: values,
            headers: clientHTTPHeaders,
            timeoutSeconds: Int64(waitTimeout)
        )
    }

    // MARK: - Multiple URL Screenshots

    /// Capture screenshots from multiple URLs
    /// - Parameters:
    ///   - urls: Array of URLs to capture
    ///   - options: Screenshot options
    ///   - waitTimeout: Timeout in seconds for the Gotenberg server
    ///   - clientHTTPHeaders: Custom headers for GotenbergKit
    /// - Returns: Dictionary mapping URLs to their screenshot data
    public func capture(
        urls: [URL],
        options: ScreenshotOptions = ScreenshotOptions(),
        waitTimeout: TimeInterval = 120,
        clientHTTPHeaders: [String: String] = [:]
    ) async throws -> [URL: GotenbergResponse] {
        guard !urls.isEmpty else {
            throw GotenbergError.noURLsProvided
        }

        logger.debug("Capturing screenshots from \(urls.count) URLs")

        // Capture screenshots in parallel
        return try await withThrowingTaskGroup(of: (URL, GotenbergResponse).self) { group -> [URL: GotenbergResponse] in
            for url in urls {
                let options = options
                group.addTask {
                    let screenshotData = try await capture(
                        url: url,
                        options: options,
                        waitTimeout: waitTimeout,
                        clientHTTPHeaders: clientHTTPHeaders
                    )
                    return (url, screenshotData)
                }
            }

            // Collect results
            var results = [URL: GotenbergResponse]()
            for try await (url, data) in group {
                results[url] = data
                logger.debug("Captured screenshot for \(url.absoluteString)")
            }

            return results
        }
    }
}
