//
//  GotenbergClient+PDF.swift
//  gotenberg-kit
//
//  Created by Stevenson Michel on 4/11/25.
//

import AsyncHTTPClient
import NIO

#if canImport(Darwin) || compiler(<6.0)
import Foundation
#else
import FoundationEssentials
#endif

// MARK: - PDF Engines
extension GotenbergClient {
    /// Merge multiple PDF files into a single PDF
    /// - Parameters:
    ///   - documents: Dictionary of PDF file data to be merged
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

    // MARK: - PDF Operations

    /// Extract specific pages from a PDF
    /// - Parameters:
    ///   - pdfData: The PDF data to extract pages from
    ///   - pages: Array of page numbers to extract (1-based indexing)
    ///   - filename: Optional filename for the PDF
    ///   - waitTimeout: Timeout in seconds for the Gotenberg server
    /// - Returns: GotenbergResponse containing the PDF with only the extracted pages
    public func extractPages(
        from pdfData: Data,
        pages: [Int],
        filename: String = "document.pdf",
        options: PDFEngineOptions = PDFEngineOptions(),
        waitTimeout: TimeInterval = 30
    ) async throws -> GotenbergResponse {
        guard !pages.isEmpty else {
            throw GotenbergError.noPagesSpecified
        }

        let files = [
            FormFile(
                name: "files",
                filename: filename,
                contentType: "application/pdf",
                data: pdfData
            )
        ]

        let values = ["pages": pages.map { String($0) }.joined(separator: ",")]

        return try await sendFormRequest(
            route: "/forms/pdfengines/extract",
            files: files,
            values: values,
            headers: ["Gotenberg-Wait-Timeout": "\(Int(waitTimeout))"]
        )
    }

    /// Merge PDFs from local file paths
    /// - Parameters:
    ///   - filePaths: Array of file paths to PDFs that should be merged
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
    /// - Returns: Data containing the merged PDF
    public func mergeWithPDFEngines(
        urls: [URL],
        waitTimeout: TimeInterval = 30,
        options: PDFEngineOptions = PDFEngineOptions(),
        metadata: Metadata? = nil
    ) async throws -> GotenbergResponse {
        guard !urls.isEmpty else {
            throw GotenbergError.noPDFsProvided
        }

        logger.debug("Merging \(urls.count) PDFs from URLs using downloadFrom parameter")

        // Prepare the downloadFrom parameter - array of objects with url property
        let downloadItems = urls.map { ["url": $0.absoluteString] }

        // Convert to JSON
        let jsonData = try JSONEncoder().encode(downloadItems)
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
}
