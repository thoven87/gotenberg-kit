//
//  GotenbergClient+Chromium.swift
//  gotenberg-kit
//
//  Created by Stevenson Michel on 4/11/25.
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

// MARK: - HTML to PDF Conversion
extension GotenbergClient {

    /// Convert HTML content to PDF
    /// - Parameters:
    ///   - htmlContent: The HTML content as Data
    ///   - assets: Optional dictionary of assets keyed by filename
    ///   - options: Chromium conversion options
    ///   - waitTimeout: Timeout in seconds for the Gotenberg server
    /// - Returns: Data containing the converted PDF
    public func convertHtml(
        htmlContent: Data,
        assets: [String: Data] = [:],
        options: ChromiumOptions = ChromiumOptions(),
        waitTimeout: TimeInterval = 30
    ) async throws -> GotenbergResponse {
        logger.debug("Converting HTML to PDF")

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
            route: "/forms/chromium/convert/html",
            files: files,
            values: options.formValues,
            headers: ["Gotenberg-Wait-Timeout": "\(Int(waitTimeout))"]
        )
    }

    // MARK: - URL to PDF Conversion

    /// Convert a web page URL to PDF
    /// - Parameters:
    ///   - url: The URL to convert
    ///   - options: Chromium conversion options
    ///   - waitTimeout: Timeout in seconds for the Gotenberg server
    /// - Returns: Data containing the converted PDF
    public func convertUrl(
        url: URL,
        options: ChromiumOptions = ChromiumOptions(),
        waitTimeout: TimeInterval = 30
    ) async throws -> GotenbergResponse {
        logger.debug("Converting URL to PDF: \(url.absoluteString)")

        var values = options.formValues
        values["url"] = url.absoluteString

        return try await sendFormRequest(
            route: "/forms/chromium/convert/url",
            files: [],
            values: values,
            headers: ["Gotenberg-Wait-Timeout": "\(Int(waitTimeout))"]
        )
    }

    // MARK: - Markdown to PDF Conversion

    /// Convert Markdown content to PDF
    /// - Parameters:
    ///   - markdownFiles: Dictionary mapping filenames to markdown content data
    ///   - assets: Optional dictionary of assets keyed by filename
    ///   - options: Chromium conversion options
    ///   - waitTimeout: Timeout in seconds for the Gotenberg server
    /// - Returns: Data containing the converted PDF
    public func convertMarkdown(
        files: [String: Data],
        assets: [String: Data] = [:],
        options: ChromiumOptions = ChromiumOptions(),
        waitTimeout: TimeInterval = 30
    ) async throws -> GotenbergResponse {
        guard !files.isEmpty else {
            throw GotenbergError.noFilesProvided
        }

        logger.debug("Converting \(files.count) Markdown files to PDF")

        var formFiles: [FormFile] = []

        // Add markdown files
        for (filename, data) in files {
            formFiles.append(
                FormFile(
                    name: "files",
                    filename: filename,
                    contentType: "text/markdown",
                    data: data
                )
            )
        }

        // Add assets
        for (filename, data) in assets {
            formFiles.append(
                FormFile(
                    name: "files",
                    filename: filename,
                    contentType: contentTypeForFilename(filename),
                    data: data
                )
            )
        }

        return try await sendFormRequest(
            route: "/forms/chromium/convert/markdown",
            files: formFiles,
            values: options.formValues,
            headers: ["Gotenberg-Wait-Timeout": "\(Int(waitTimeout))"]
        )
    }

    /// Convert multiple URLs to PDFs and merge them
    /// - Parameters:
    ///   - urls: Array of URLs to convert
    ///   - options: Chromium conversion options
    ///   - waitTimeout: Timeout in seconds for the Gotenberg server
    /// - Returns: Data containing the merged PDF
    public func convertUrlAndMerge(
        urls: [URL],
        options: ChromiumOptions = ChromiumOptions(),
        waitTimeout: TimeInterval = 60
    ) async throws -> GotenbergResponse {
        guard !urls.isEmpty else {
            throw GotenbergError.noFilesProvided
        }

        logger.debug("Converting and merging \(urls.count) URLs")

        // Convert each URL to PDF
        let pdfDataArray = try await withThrowingTaskGroup(of: (Int, Data).self) { group -> [Data] in
            for (index, url) in urls.enumerated() {
                group.addTask {
                    let pdfData = try await convertUrl(
                        url: url,
                        options: options,
                        waitTimeout: waitTimeout
                    )
                    return (index, try await toData(pdfData))
                }
            }

            // Collect results in original order
            var results = [Data?](repeating: nil, count: urls.count)
            while let (index, data) = try await group.next() {
                results[index] = data
            }

            return results.compactMap { $0 }
        }

        let filenames = urls.map { url -> String in
            let host = url.host ?? "unknown"
            let path = url.path.isEmpty ? "index" : url.path
            return "\(host)\(path).pdf".replacingOccurrences(of: "/", with: "_")
        }

        // Now merge the PDFs
        return try await mergeWithPdfEngines(
            pdfFiles: pdfDataArray,
            filenames: filenames,
            waitTimeout: waitTimeout
        )
    }
}
