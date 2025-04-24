//
//  GotenbergClient+Chromium+Screenshots.swift
//  gotenberg-kit
//
//  Created by Stevenson Michel on 4/12/25.
//

import AsyncHTTPClient
import Logging
import NIO
import NIOFoundationCompat

#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

// MARK: - HTML Screenshot Methods
extension GotenbergClient {

    /// Capture a screenshot of HTML content
    /// - Parameters:
    ///   - htmlContent: The HTML content as Data
    ///   - assets: Optional dictionary of assets keyed by filename
    ///   - options: Screenshot options
    ///   - waitTimeout: Timeout in seconds for the Gotenberg server
    /// - Returns: GotenbergResponse containing the screenshot image
    public func captureHTMLScreenshot(
        htmlContent: Data,
        assets: [String: Data] = [:],
        options: ScreenshotOptions = ScreenshotOptions(),
        waitTimeout: TimeInterval = 30
    ) async throws -> GotenbergResponse {
        logger.debug("Capturing screenshot of HTML")

        var files: [FormFile] = [
            FormFile(
                name: "files",
                filename: "index.html",
                contentType: "text/html",
                data: htmlContent
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
            headers: ["Gotenberg-Wait-Timeout": "\(Int(waitTimeout))"]
        )
    }

    /// Capture a screenshot of MarkDown content
    /// - Parameters:
    ///   - htmlContent: The HTML content as Data
    ///   - assets: Optional dictionary of assets keyed by filename
    ///   - options: Screenshot options
    ///   - waitTimeout: Timeout in seconds for the Gotenberg server
    /// - Returns: GotenbergResponse containing the screenshot image
    public func captureMarkDownScreenshot(
        htmlContent: Data,
        assets: [String: Data] = [:],
        options: ScreenshotOptions = ScreenshotOptions(),
        waitTimeout: TimeInterval = 30
    ) async throws -> GotenbergResponse {
        logger.debug("Capturing screenshot of Markdown")

        var files: [FormFile] = [
            FormFile(
                name: "files",
                filename: "index.md",
                contentType: "text/markdown",
                data: htmlContent
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
            route: "/forms/chromium/screenshot/markdown",
            files: files,
            values: options.formValues,
            headers: ["Gotenberg-Wait-Timeout": "\(Int(waitTimeout))"]
        )
    }

    /// Capture a screenshot of HTML content from a string
    /// - Parameters:
    ///   - htmlString: The HTML content as a string
    ///   - assets: Optional dictionary of assets keyed by filename
    ///   - options: Screenshot options
    ///   - waitTimeout: Timeout in seconds for the Gotenberg server
    /// - Returns: GotenbergResponse containing the screenshot image
    public func captureHTMLStringScreenshot(
        htmlString: String,
        assets: [String: Data] = [:],
        options: ScreenshotOptions = ScreenshotOptions(),
        waitTimeout: TimeInterval = 30
    ) async throws -> GotenbergResponse {
        guard let htmlData = htmlString.data(using: .utf8) else {
            throw GotenbergError.invalidInput(message: "Failed to encode HTML string as UTF-8")
        }

        return try await captureHTMLScreenshot(
            htmlContent: htmlData,
            assets: assets,
            options: options,
            waitTimeout: waitTimeout
        )
    }

    // MARK: - URL Screenshot Methods

    /// Capture a screenshot of a URL
    /// - Parameters:
    ///   - url: The URL to capture
    ///   - options: Screenshot options
    ///   - waitTimeout: Timeout in seconds for the Gotenberg server
    /// - Returns: Data containing the screenshot image
    public func captureURLScreenshot(
        url: URL,
        options: ScreenshotOptions = ScreenshotOptions(),
        waitTimeout: TimeInterval = 30
    ) async throws -> GotenbergResponse {
        logger.debug("Capturing screenshot of URL: \(url.absoluteString)")

        var values = options.formValues
        values["url"] = url.absoluteString

        return try await sendFormRequest(
            route: "/forms/chromium/screenshot/url",
            files: [],
            values: values,
            headers: ["Gotenberg-Wait-Timeout": "\(Int(waitTimeout))"]
        )
    }

    // MARK: - Multiple URL Screenshots

    /// Capture screenshots from multiple URLs
    /// - Parameters:
    ///   - urls: Array of URLs to capture
    ///   - options: Screenshot options
    ///   - waitTimeout: Timeout in seconds for the Gotenberg server
    /// - Returns: Dictionary mapping URLs to their screenshot data
    public func captureMultipleURLScreenshots(
        urls: [URL],
        options: ScreenshotOptions = ScreenshotOptions(),
        waitTimeout: TimeInterval = 60
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
                    let screenshotData = try await captureURLScreenshot(
                        url: url,
                        options: options,
                        waitTimeout: waitTimeout
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
