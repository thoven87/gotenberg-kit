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

#if canImport(Darwin) || compiler(<6.0)
import Foundation
#else
import FoundationEssentials
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

    // MARK: - Convenience Methods

    /// Save an HTML screenshot to a file
    /// - Parameters:
    ///   - html: HTML content as a string
    ///   - outputPath: Path where to save the screenshot
    ///   - assets: Optional dictionary of assets keyed by filename
    ///   - options: Screenshot options
    ///   - waitTimeout: Timeout in seconds for the Gotenberg server
    public func captureHTMLScreenshotAndSave(
        html: String,
        outputPath: String,
        assets: [String: Data] = [:],
        options: ScreenshotOptions = ScreenshotOptions(),
        waitTimeout: TimeInterval = 30
    ) async throws {
        let screenshot = try await captureHTMLStringScreenshot(
            htmlString: html,
            assets: assets,
            options: options,
            waitTimeout: waitTimeout
        )

        try await toData(screenshot).write(to: URL(fileURLWithPath: outputPath))
        logger.info("Saved screenshot to \(outputPath)")
    }

    /// Save a URL screenshot to a file
    /// - Parameters:
    ///   - url: The URL to capture
    ///   - outputPath: Path where to save the screenshot
    ///   - options: Screenshot options
    ///   - waitTimeout: Timeout in seconds for the Gotenberg server
    public func captureURLScreenshotAndSave(
        url: URL,
        outputPath: String,
        options: ScreenshotOptions = ScreenshotOptions(),
        waitTimeout: TimeInterval = 30
    ) async throws {
        let screenshot = try await captureURLScreenshot(
            url: url,
            options: options,
            waitTimeout: waitTimeout
        )

        try await toData(screenshot).write(to: URL(fileURLWithPath: outputPath))
        logger.info("Saved screenshot to \(outputPath)")
    }

    /// Capture screenshots from multiple URLs and save them to files
    /// - Parameters:
    ///   - urls: Array of URLs to capture
    ///   - outputDirectory: Directory to save the screenshots
    ///   - filenameGenerator: Optional function to generate custom filenames
    ///   - options: Screenshot options
    ///   - waitTimeout: Timeout in seconds for the Gotenberg server
    /// - Returns: Dictionary mapping URLs to their screenshot file paths
    public func captureMultipleURLScreenshotsAndSave(
        urls: [URL],
        outputDirectory: String,
        filenameGenerator: ((URL) -> String)? = nil,
        options: ScreenshotOptions = ScreenshotOptions(),
        waitTimeout: TimeInterval = 60
    ) async throws -> [URL: String] {
        let screenshots = try await captureMultipleURLScreenshots(
            urls: urls,
            options: options,
            waitTimeout: waitTimeout
        )

        let fileManager = FileManager.default

        // Create the output directory if it doesn't exist
        if !fileManager.fileExists(atPath: outputDirectory) {
            try fileManager.createDirectory(
                atPath: outputDirectory,
                withIntermediateDirectories: true
            )
        }

        // Default filename generator if none provided
        let generateFilename: (URL) -> String =
            filenameGenerator ?? { url in
                let urlString = url.absoluteString
                    .replacingOccurrences(of: "https://", with: "")
                    .replacingOccurrences(of: "http://", with: "")
                    .replacingOccurrences(of: "/", with: "_")
                    .replacingOccurrences(of: ".", with: "_")

                // Determine extension based on format option
                let ext = (options.format?.rawValue.lowercased() ?? "png")

                return "\(urlString).\(ext)"
            }

        // Save each screenshot to a file
        var outputPaths = [URL: String]()
        for (url, response) in screenshots {
            let filename = generateFilename(url)
            let outputPath = (outputDirectory as NSString).appendingPathComponent(filename)

            try await toData(response).write(to: URL(fileURLWithPath: outputPath))
            outputPaths[url] = outputPath

            logger.debug("Saved screenshot for \(url.absoluteString) to \(outputPath)")
        }

        logger.info("Saved \(outputPaths.count) screenshots to \(outputDirectory)")
        return outputPaths
    }
}
