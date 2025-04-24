//
//  GotenbergClient+PDF.swift
//  gotenberg-kit
//
//  Created by Stevenson Michel on 4/11/25.
//

import AsyncHTTPClient
import NIO

#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

// MARK: - PDF Engines
extension GotenbergClient {
    /// Merge multiple PDF files into a single PDF
    /// - Parameters:
    ///   - documents: Dictionary of PDF file data to be merged
    ///   - options: PDFEngineOptions
    ///   - waitTimeout: Timeout in seconds for the Gotenberg server
    /// - Returns: GotenbergResponse containing the merged PDF
    public func mergeWithPDFEngines(
        documents: [String: Data],
        options: PDFEngineOptions = PDFEngineOptions(),
        waitTimeout: TimeInterval = 30
    ) async throws -> GotenbergResponse {
        guard !documents.isEmpty else {
            throw GotenbergError.noPDFsProvided
        }

        logger.debug("Merging \(documents.count) with PDF engines route")

        // Create request with PDF files
        var files: [FormFile] = []

        for (filename, data) in documents {
            files.append(
                FormFile(
                    name: "files",
                    filename: filename,
                    contentType: contentTypeForFilename(filename),
                    data: data
                )
            )
            logger.debug("Merging \(filename) using PDF engines route")
            logger.debug("Document size: \(data.count) bytes")
        }

        // Send request to Gotenberg
        return try await sendFormRequest(
            route: "/forms/pdfengines/merge",
            files: files,
            values: options.formValues,
            headers: ["Gotenberg-Wait-Timeout": "\(Int(waitTimeout))"]
        )
    }

    /// Merge PDFs from local file paths
    /// - Parameters:
    ///   - filePaths: Array of file paths to PDFs that should be merged
    ///   - options: PDFEngineOptions
    ///   - waitTimeout: Timeout in seconds for the Gotenberg server to process the request
    /// - Returns: GotenbergResponse containing the merged PDF
    public func mergeWithPDFEngines(
        filePaths: [String],
        options: PDFEngineOptions = PDFEngineOptions(),
        waitTimeout: TimeInterval = 30
    ) async throws -> GotenbergResponse {
        var pdfFiles: [String: Data] = [:]

        for path in filePaths {
            let url = URL(fileURLWithPath: path)
            pdfFiles[url.lastPathComponent] = try Data(contentsOf: url)
        }

        return try await mergeWithPDFEngines(
            documents: pdfFiles,
            options: options,
            waitTimeout: waitTimeout
        )
    }

    /// Merge PDFs directly from URLs using Gotenberg's downloadFrom parameter
    /// - Parameters:
    ///   - urls: Array of URLs to PDFs that should be merged
    ///   - waitTimeout: Timeout in seconds for the Gotenberg server to process the request
    ///   - options: PDFEngineOptions
    /// - Returns: GotenbergResponse containing the merged PDF
    public func mergeWithPDFEngines(
        urls: [DownloadFrom],
        waitTimeout: TimeInterval = 30,
        options: PDFEngineOptions = PDFEngineOptions()
    ) async throws -> GotenbergResponse {
        guard !urls.isEmpty else {
            throw GotenbergError.noPDFsProvided
        }

        logger.debug("Merging \(urls.count) PDFs from URLs using downloadFrom parameter")

        // Convert to JSON
        let jsonData = try JSONEncoder().encode(urls)
        let jsonString = String(data: jsonData, encoding: .utf8)!

        var values = options.formValues
        values["downloadFrom"] = jsonString

        logger.debug("downloadFrom JSON: \(jsonString)")

        return try await sendFormRequest(
            route: "/forms/pdfengines/merge",
            files: [],
            values: values,
            headers: ["Gotenberg-Wait-Timeout": "\(Int(waitTimeout))"]
        )
    }

    /// Convert into PDF/A & PDF/UA directly from URLs using Gotenberg's downloadFrom parameter
    /// - Parameters:
    ///   - urls: Array of URLs of PDFs that should be converted
    ///   - waitTimeout: Timeout in seconds for the Gotenberg server to process the request
    ///   - options: PDFEngineOptions
    /// - Returns: GotenbergResponse containing the converted PDF
    public func convertWithPDFEngines(
        urls: [DownloadFrom],
        waitTimeout: TimeInterval = 500,
        options: PDFEngineOptions = PDFEngineOptions()
    ) async throws -> GotenbergResponse {
        guard !urls.isEmpty else {
            throw GotenbergError.noPDFsProvided
        }

        logger.debug("Converting \(urls.count) files PDFs from URLs using downloadFrom parameter")

        // Convert to JSON
        let jsonData = try JSONEncoder().encode(urls)
        let jsonString = String(data: jsonData, encoding: .utf8)!

        var values = options.formValues
        values["downloadFrom"] = jsonString

        logger.debug("downloadFrom JSON: \(jsonString)")

        return try await sendFormRequest(
            route: "/forms/pdfengines/convert",
            files: [],
            values: values,
            headers: ["Gotenberg-Wait-Timeout": "\(Int(waitTimeout))"]
        )
    }

    /// Convert into PDF/A & PDF/UA
    /// - Parameters:
    ///   - documents: Dictionary of PDF file data to be converted
    ///   - options: PDFEngineOptions
    ///   - waitTimeout: Timeout in seconds for the Gotenberg server
    /// - Returns: GotenbergResponse containing the converted PDF
    public func convertWithPDFEngines(
        documents: [String: Data],
        options: PDFEngineOptions = PDFEngineOptions(),
        waitTimeout: TimeInterval = 500
    ) async throws -> GotenbergResponse {
        guard !documents.isEmpty else {
            throw GotenbergError.noPDFsProvided
        }

        logger.debug("Converting \(documents.lazy.count) files PDFs from paths")

        // Create request with PDF files
        var files: [FormFile] = []

        for (filename, data) in documents {
            files.append(
                FormFile(
                    name: "files",
                    filename: filename,
                    contentType: contentTypeForFilename(filename),
                    data: data
                )
            )
            logger.debug("Converting file \(filename) using PDF engines route")
            logger.debug("Document size: \(data.lazy.count) bytes")
        }

        // Send request to Gotenberg
        return try await sendFormRequest(
            route: "/forms/pdfengines/convert",
            files: files,
            values: options.formValues,
            headers: ["Gotenberg-Wait-Timeout": "\(Int(waitTimeout))"]
        )
    }

    /// Splits a PDF file into multiple PDF files
    /// - Parameters:
    ///   - documents: Dictionary of PDF file data to be split into multiple files
    ///   - options: SplitPDFOptions with splitSpan defaults to 1 and splitMode to intervals
    ///   - waitTimeout: Timeout in seconds for the Gotenberg server
    /// - Returns: GotenbergResponse containing a zip file if splitUnify is true or just one PDF if splitUnify is false
    public func splitPDF(
        documents: [String: Data],
        options: SplitPDFOptions = SplitPDFOptions(
            splitSpan: "1",
            splitMode: .intervals
        ),
        waitTimeout: TimeInterval = 500
    ) async throws -> GotenbergResponse {
        guard !documents.isEmpty else {
            throw GotenbergError.noPDFsProvided
        }

        logger.debug("Splitting \(documents.lazy.count) files PDFs from paths")

        if options.splitUnify && options.splitMode != .pages {
            throw GotenbergError.invalidInput(message: "Unify option can only be used with mode: pages")
        }

        // Create request with PDF files
        var files: [FormFile] = []

        for (filename, data) in documents {
            files.append(
                FormFile(
                    name: "files",
                    filename: filename,
                    contentType: contentTypeForFilename(filename),
                    data: data
                )
            )
            logger.debug("Splitting file \(filename) using PDF engines route")
            logger.debug("Document size: \(data.lazy.count) bytes")
        }

        // Send request to Gotenberg
        return try await sendFormRequest(
            route: "/forms/pdfengines/split",
            files: files,
            values: options.formValues,
            headers: ["Gotenberg-Wait-Timeout": "\(Int(waitTimeout))"]
        )
    }

    /// Splits a PDF file into multiple PDF files
    /// - Parameters:
    ///   - documents: Dictionary of PDF file data to be split into multiple files
    ///   - options: SplitPDFOptions with splitSpan defaults to 1 and splitMode to intervals
    ///   - waitTimeout: Timeout in seconds for the Gotenberg server
    /// - Returns: GotenbergResponse containing a zip file if splitUnify is true or just one PDF if splitUnify is false
    public func splitPDF(
        urls: [DownloadFrom],
        options: SplitPDFOptions = SplitPDFOptions(
            splitSpan: "1",
            splitMode: .intervals
        ),
        waitTimeout: TimeInterval = 500
    ) async throws -> GotenbergResponse {
        guard !urls.isEmpty else {
            throw GotenbergError.noURLsProvided
        }
        
        logger.debug("Splitting \(urls.count) PDFS with PDF engines route")

        // Convert to JSON
        let jsonData = try JSONEncoder().encode(urls)
        let jsonString = String(data: jsonData, encoding: .utf8)!

        var values = options.formValues
        values["downloadFrom"] = jsonString

        return try await sendFormRequest(
            route: "/forms/pdfengines/split",
            files: [],
            values: values,
            headers: ["Gotenberg-Wait-Timeout": "\(Int(waitTimeout))"]
        )
    }
}
