//
//  GotenberClient+LibreOffice.swift
//  gotenberg-kit
//
//  Created by Stevenson Michel on 4/11/25.
//

import struct Foundation.Data
import class Foundation.JSONEncoder
import struct Foundation.TimeInterval
import struct Foundation.URL

// MARK: - LibreOffice
extension GotenbergClient {

    /// Convert with LibreOffice to convert all LibreOffice supported formats
    /// Note: passing
    /// - Parameters:
    ///   - documents: The  documents (filename.ext, data) to convert
    ///   - options: LibreOffice Conversion Options
    ///   - waitTimeout: Timeout in seconds for the Gotenberg server
    ///   - clientHTTPHeaders: Custom headers for GotenbergKit
    /// - Returns: Async Sequence  containing the converted PDF
    public func convertWithLibreOffice(
        documents: [String: Data],
        options: LibreOfficeConversionOptions = LibreOfficeConversionOptions(),
        waitTimeout: TimeInterval = 500,
        clientHTTPHeaders: [String: String] = [:]
    ) async throws -> GotenbergResponse {
        guard !documents.isEmpty else {
            throw GotenbergError.noFilesProvided
        }

        logger.debug("Converting \(documents.count) with LibreOffice route")

        var files: [FormFile] = []

        // Add markdown files
        for (filename, data) in documents {
            files.append(
                FormFile(
                    name: "files",
                    filename: filename,
                    contentType: contentTypeForFilename(filename),
                    data: data
                )
            )
            logger.debug("Converting \(filename) to PDF using LibreOffice route")
            logger.debug("Document size: \(data.count) bytes")
        }

        let values = options.formValues

        return try await sendFormRequest(
            route: "/forms/libreoffice/convert",
            files: files,
            values: values,
            headers: clientHTTPHeaders,
            timeoutSeconds: Int64(waitTimeout)
        )
    }

    /// Convert with LibreOffice to convert all LibreOffice supported formats
    /// Note: passing
    /// - Parameters:
    ///   - urls: The http | https URL of the files to convert
    ///   - options: LibreOffice Conversion Options
    ///   - waitTimeout: Timeout in seconds for the Gotenberg server
    ///   - clientHTTPHeaders: Custom headers for GotenbergKit
    /// - Returns: Async Sequence  containing the converted PDF
    public func convertWithLibreOffice(
        urls: [DownloadFrom],
        options: LibreOfficeConversionOptions = LibreOfficeConversionOptions(),
        waitTimeout: TimeInterval = 500,
        clientHTTPHeaders: [String: String] = [:]
    ) async throws -> GotenbergResponse {
        guard !urls.isEmpty else {
            throw GotenbergError.noURLsProvided
        }

        logger.debug("Converting \(urls.count) with LibreOffice route")

        // Convert to JSON
        let jsonData = try JSONEncoder().encode(urls)
        let jsonString = String(decoding: jsonData, as: UTF8.self)

        var values = options.formValues
        values["downloadFrom"] = jsonString

        return try await sendFormRequest(
            route: "/forms/libreoffice/convert",
            files: [],
            values: values,
            headers: clientHTTPHeaders,
            timeoutSeconds: Int64(waitTimeout)
        )
    }
}
