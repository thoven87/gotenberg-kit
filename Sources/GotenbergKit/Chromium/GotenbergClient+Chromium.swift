//
//  GotenbergClient+Chromium.swift
//  gotenberg-kit
//
//  Created by Stevenson Michel on 4/11/25.
//

import struct Foundation.Data
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
        waitTimeout: TimeInterval = 30,
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

        var headers: [String: String] = clientHTTPHeaders
        headers["Gotenberg-Wait-Timeout"] = "\(Int(waitTimeout))"

        return try await sendFormRequest(
            route: "/forms/chromium/convert/html",
            files: files,
            values: options.formValues,
            headers: headers
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
        waitTimeout: TimeInterval = 30,
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

        var headers: [String: String] = clientHTTPHeaders
        headers["Gotenberg-Wait-Timeout"] = "\(Int(waitTimeout))"

        return try await sendFormRequest(
            route: "/forms/chromium/convert/url",
            files: files,
            values: values,
            headers: headers
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
        waitTimeout: TimeInterval = 30,
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

        var headers: [String: String] = clientHTTPHeaders
        headers["Gotenberg-Wait-Timeout"] = "\(Int(waitTimeout))"

        return try await sendFormRequest(
            route: "/forms/chromium/convert/markdown",
            files: formFiles,
            values: options.formValues,
            headers: headers
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
        waitTimeout: TimeInterval = 60,
        clientHTTPHeaders: [String: String] = [:]
    ) async throws -> GotenbergResponse {
        guard !urls.isEmpty else {
            throw GotenbergError.noFilesProvided
        }

        logger.debug("Converting and merging \(urls.count) URLs")

        // Convert each URL to PDF
        let pdfData = try await withThrowingTaskGroup(of: (String, Data).self) { group -> [String: Data] in
            for (index, url) in urls.enumerated() {

                var headers: [String: String] = clientHTTPHeaders
                headers["Gotenberg-Wait-Timeout"] = "\(Int(waitTimeout))"

                group.addTask {
                    let pdfData = try await convert(
                        url: url,
                        options: options,
                        waitTimeout: waitTimeout,
                        clientHTTPHeaders: headers
                    )
                    let host = url.host ?? "unknown"
                    let path = url.path.isEmpty ? "page_\(index)" : url.path
                    let filename = "\(host)\(path)_\(index).pdf".replacingOccurrences(of: "/", with: "_")
                    return (filename, try await toData(pdfData))
                }
            }

            var results: [String: Data] = [:]
            while let (filename, data) = try await group.next() {
                results[filename] = data
            }

            return results
        }

        // Now merge the PDFs
        return try await mergeWithPDFEngines(
            documents: pdfData,
            waitTimeout: waitTimeout
        )
    }
}
