//
//  GotenbergClient+Chromium.swift
//  gotenberg-kit
//
//  Created by Stevenson Michel on 4/11/25.
//

import struct Foundation.Data
import class Foundation.JSONEncoder
import struct Foundation.TimeInterval
import struct Foundation.URL

// MARK: - HTML to PDF Conversion
extension GotenbergClient {

    /// Convert HTML content to PDF
    /// - Parameters:
    ///   - html: The HTML content as Data
    ///   - header: HTML header
    ///   - footer: HTML footer
    ///   - assets: Optional dictionary of assets keyed by filename
    ///   - options: Chromium conversion options
    ///   - waitTimeout: Timeout in seconds for the Gotenberg server
    ///   - clientHTTPHeaders: Custom headers for GotenbergKit
    /// - Returns: Data containing the converted PDF
    public func convert(
        html: Data,
        header: Data? = nil,
        footer: Data? = nil,
        assets: [String: Data] = [:],
        options: ChromiumOptions = ChromiumOptions(),
        waitTimeout: TimeInterval = 120,
        clientHTTPHeaders: [String: String] = [:]
    ) async throws -> GotenbergResponse {
        logger.debug("Converting HTML to PDF")

        var files: [FormFile] = [
            FormFile(
                name: "files",
                filename: "index.html",
                contentType: "text/html",
                data: html
            )
        ]

        if let header = header {
            files.append(
                FormFile(
                    name: "files",
                    filename: "header.html",
                    contentType: "text/html",
                    data: header
                )
            )
        }

        if let footer = footer {
            files.append(
                FormFile(
                    name: "files",
                    filename: "footer.html",
                    contentType: "text/html",
                    data: footer
                )
            )
        }

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
            headers: clientHTTPHeaders,
            timeoutSeconds: Int64(waitTimeout)
        )
    }

    // MARK: - URL to PDF Conversion

    /// Convert a web page URL to PDF
    /// - Parameters:
    ///   - url: The URL to convert
    ///   - header: HTML header
    ///   - footer: HTML footer
    ///   - options: Chromium conversion options
    ///   - waitTimeout: Timeout in seconds for the Gotenberg server
    ///   - clientHTTPHeaders: Custom headers for GotenbergKit
    /// - Returns: Data containing the converted PDF
    public func convert(
        url: URL,
        header: Data? = nil,
        footer: Data? = nil,
        options: ChromiumOptions = ChromiumOptions(),
        waitTimeout: TimeInterval = 120,
        clientHTTPHeaders: [String: String] = [:]
    ) async throws -> GotenbergResponse {
        logger.debug("Converting URL to PDF: \(url.absoluteString)")

        var values = options.formValues
        values["url"] = url.absoluteString

        var files: [FormFile] = []

        if let header = header {
            files.append(
                FormFile(
                    name: "files",
                    filename: "header.html",
                    contentType: "text/html",
                    data: header
                )
            )
        }

        if let footer = footer {
            files.append(
                FormFile(
                    name: "files",
                    filename: "footer.html",
                    contentType: "text/html",
                    data: footer
                )
            )
        }

        return try await sendFormRequest(
            route: "/forms/chromium/convert/url",
            files: files,
            values: values,
            headers: clientHTTPHeaders,
            timeoutSeconds: Int64(waitTimeout)
        )
    }

    /// Convert html from downloaded contents
    /// - Parameters:
    ///   - html: Array of DownloadFrom
    ///   - header: HTML header
    ///   - footer: HTML footer
    ///   - options: Chromium conversion options
    ///   - waitTimeout: Timeout in seconds for the Gotenberg server
    ///   - clientHTTPHeaders: Custom headers for GotenbergKit
    /// - Returns: Data containing the converted PDF
    public func convert(
        html: [DownloadFrom],
        header: Data? = nil,
        footer: Data? = nil,
        options: ChromiumOptions = ChromiumOptions(),
        waitTimeout: TimeInterval = 120,
        clientHTTPHeaders: [String: String] = [:]
    ) async throws -> GotenbergResponse {
        logger.debug("Converting \(html.lazy.count) files to PDF")

        // Convert to JSON
        let jsonData = try JSONEncoder().encode(html)
        let jsonString = String(decoding: jsonData, as: UTF8.self)

        var values = options.formValues
        values["downloadFrom"] = jsonString

        var files: [FormFile] = []

        if let header = header {
            files.append(
                FormFile(
                    name: "files",
                    filename: "header.html",
                    contentType: "text/html",
                    data: header
                )
            )
        }

        if let footer = footer {
            files.append(
                FormFile(
                    name: "files",
                    filename: "footer.html",
                    contentType: "text/html",
                    data: footer
                )
            )
        }

        return try await sendFormRequest(
            route: "/forms/chromium/convert/html",
            files: files,
            values: values,
            headers: clientHTTPHeaders,
            timeoutSeconds: Int64(waitTimeout)
        )
    }

    /// Convert markdown files from downloaded contents
    /// - Parameters:
    ///   - markdown: Array of DownloadFrom
    ///   - header: HTML header
    ///   - footer: HTML footer
    ///   - options: Chromium conversion options
    ///   - waitTimeout: Timeout in seconds for the Gotenberg server
    ///   - clientHTTPHeaders: Custom headers for GotenbergKit
    /// - Returns: Data containing the converted PDF
    public func convert(
        markdown: [DownloadFrom],
        header: Data? = nil,
        footer: Data? = nil,
        options: ChromiumOptions = ChromiumOptions(),
        waitTimeout: TimeInterval = 120,
        clientHTTPHeaders: [String: String] = [:]
    ) async throws -> GotenbergResponse {
        logger.debug("Converting \(markdown.lazy.count) files to PDF")

        // Convert to JSON
        let jsonData = try JSONEncoder().encode(markdown)
        let jsonString = String(decoding: jsonData, as: UTF8.self)

        var values = options.formValues
        values["downloadFrom"] = jsonString

        var files: [FormFile] = []

        if let header = header {
            files.append(
                FormFile(
                    name: "files",
                    filename: "header.html",
                    contentType: "text/html",
                    data: header
                )
            )
        }

        if let footer = footer {
            files.append(
                FormFile(
                    name: "files",
                    filename: "footer.html",
                    contentType: "text/html",
                    data: footer
                )
            )
        }

        return try await sendFormRequest(
            route: "/forms/chromium/convert/markdown",
            files: files,
            values: values,
            headers: clientHTTPHeaders,
            timeoutSeconds: Int64(waitTimeout)
        )
    }

    // MARK: - Markdown to PDF Conversion

    /// Convert Markdown content to PDF
    /// - Parameters:
    ///   - files: Dictionary mapping filenames to markdown content data
    ///   - assets: Optional dictionary of assets keyed by filename
    ///   - options: Chromium conversion options
    ///   - waitTimeout: Timeout in seconds for the Gotenberg server
    ///   - clientHTTPHeaders: Custom headers for GotenbergKit
    /// - Returns: Data containing the converted PDF
    public func convertMarkdown(
        files: [String: Data],
        assets: [String: Data] = [:],
        options: ChromiumOptions = ChromiumOptions(),
        waitTimeout: TimeInterval = 120,
        clientHTTPHeaders: [String: String] = [:]
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
                    contentType: contentTypeForFilename(filename),
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
            headers: clientHTTPHeaders,
            timeoutSeconds: Int64(waitTimeout)
        )
    }

    /// Convert multiple URLs to PDFs and merge them
    /// - Parameters:
    ///   - urls: Array of URLs to convert
    ///   - options: Chromium conversion options
    ///   - waitTimeout: Timeout in seconds for the Gotenberg server
    ///   - clientHTTPHeaders: Custom headers for GotenbergKit
    /// - Returns: Data containing the merged PDF
    public func convertAndMerge(
        urls: [URL],
        options: ChromiumOptions = ChromiumOptions(),
        waitTimeout: TimeInterval = 120,
        clientHTTPHeaders: [String: String] = [:]
    ) async throws -> GotenbergResponse {
        guard !urls.isEmpty else {
            throw GotenbergError.noFilesProvided
        }

        logger.debug("Converting and merging \(urls.count) URLs")

        // Convert each URL to PDF
        let pdfData = try await withThrowingTaskGroup(of: (filename: String, data: Data).self) { group -> [String: Data] in
            for (index, url) in urls.enumerated() {
                group.addTask {
                    let pdfData = try await convert(
                        url: url,
                        options: options,
                        waitTimeout: waitTimeout,
                        clientHTTPHeaders: clientHTTPHeaders
                    )
                    let host = url.host ?? "unknown"
                    let path = url.path.isEmpty ? "page_\(index)" : url.path
                    let filename = "\(host)\(path)_\(index).pdf".replacingOccurrences(of: "/", with: "_")
                    return (filename, try await toData(pdfData))
                }
            }

            return try await group.reduce(into: [:]) { partialResult, response in
                partialResult[response.filename] = response.data
            }
        }

        // Now merge the PDFs
        return try await mergeWithPDFEngines(
            documents: pdfData,
            waitTimeout: waitTimeout
        )
    }
}
