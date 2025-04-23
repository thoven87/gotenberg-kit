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
    ///   - pdfFiles: Array of PDF file data to be merged
    ///   - filenames: Optional array of filenames (should match the count of pdfFiles)
    ///   - waitTimeout: Timeout in seconds for the Gotenberg server
    /// - Returns: GotenbergResponse containing the merged PDF
    public func mergeWithPdfEngines(
        pdfFiles: [Data],
        filenames: [String]? = nil,
        options: PDFEngineOptions = PDFEngineOptions(),
        waitTimeout: TimeInterval = 30
    ) async throws -> GotenbergResponse {
        guard !pdfFiles.isEmpty else {
            throw GotenbergError.noPDFsProvided
        }

        // Generate filenames if not provided
        let fileNames = filenames ?? pdfFiles.indices.map { "file\($0).pdf" }

        guard fileNames.count == pdfFiles.count else {
            throw GotenbergError.filenameCountMismatch
        }

        // Create request with PDF files
        var files: [FormFile] = []
        for (index, pdfData) in pdfFiles.enumerated() {
            files.append(
                FormFile(
                    name: "files",
                    filename: fileNames[index],
                    contentType: "application/pdf",
                    data: pdfData
                )
            )
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
    public func mergeWithPdfEngines(
        filePaths: [String],
        options: PDFEngineOptions = PDFEngineOptions(),
        waitTimeout: TimeInterval = 30
    ) async throws -> GotenbergResponse {
        let pdfFiles = try filePaths.map { path -> Data in
            let url = URL(fileURLWithPath: path)
            return try Data(contentsOf: url)
        }

        let filenames = filePaths.map { URL(fileURLWithPath: $0).lastPathComponent }

        return try await mergeWithPdfEngines(
            pdfFiles: pdfFiles,
            filenames: filenames,
            options: options,
            waitTimeout: waitTimeout
        )
    }

    /// Save merged PDF to a file
    /// - Parameters:
    ///   - pdfFiles: Array of PDF file data to be merged
    ///   - outputPath: Path where the merged PDF should be saved
    ///   - filenames: Optional array of filenames (should match the count of pdfFiles)
    ///   - waitTimeout: Timeout in seconds for the Gotenberg server to process the request
    public func mergePDFsToFile(
        pdfFiles: [Data],
        outputPath: String,
        filenames: [String]? = nil,
        options: PDFEngineOptions = PDFEngineOptions(),
        waitTimeout: TimeInterval = 30
    ) async throws {
        let mergedPDF = try await mergeWithPdfEngines(
            pdfFiles: pdfFiles,
            filenames: filenames,
            options: options,
            waitTimeout: waitTimeout
        )

        try await toData(mergedPDF).write(to: URL(fileURLWithPath: outputPath))
    }

    /// Merge PDFs directly from URLs using Gotenberg's downloadFrom parameter
    /// - Parameters:
    ///   - urls: Array of URLs to PDFs that should be merged
    ///   - waitTimeout: Timeout in seconds for the Gotenberg server to process the request
    /// - Returns: Data containing the merged PDF
    public func mergePDFsFromURLs(
        urls: [URL],
        waitTimeout: TimeInterval = 30,
        options: PDFEngineOptions = PDFEngineOptions(),
        metadata: Metadata? = nil
    ) async throws -> Data {
        guard !urls.isEmpty else {
            throw GotenbergError.noPDFsProvided
        }

        logger.debug("Merging \(urls.count) PDFs from URLs using downloadFrom parameter")

        // Prepare the downloadFrom parameter - array of objects with url property
        let downloadItems = urls.map { ["url": $0.absoluteString] }

        // Convert to JSON
        let jsonData = try JSONEncoder().encode(downloadItems)
        let jsonString = String(data: jsonData, encoding: .utf8)!

        logger.debug("downloadFrom JSON: \(jsonString)")

        // Create the form data
        let boundary = "------------------------\(UUID().uuidString)"
        var body = Data()

        // Add form values
        for (name, value) in options.formValues {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(name)\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(value)\r\n".data(using: .utf8)!)
        }

        // Add the downloadFrom parameter
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"downloadFrom\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(jsonString)\r\n".data(using: .utf8)!)

        if let metadata = metadata {
            let metadataJSONString = try JSONEncoder().encode(metadata)
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"metadata\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(metadataJSONString)\r\n".data(using: .utf8)!)
        }

        // Add final boundary
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)

        // Create the request
        let mergeEndpoint = baseURL.appendingPathComponent("/forms/pdfengines/merge")
        var request = HTTPClientRequest(url: mergeEndpoint.absoluteString)
        request.method = .POST
        request.headers.add(name: "Content-Type", value: "multipart/form-data; boundary=\(boundary)")
        request.headers.add(name: "Content-Length", value: "\(body.count)")

        // Add Gotenberg specific headers
        request.headers.add(name: "Gotenberg-Wait-Timeout", value: "\(Int(waitTimeout))")

        // Set the request body
        request.body = .bytes(ByteBuffer(data: body))

        logger.debug("Sending request to Gotenberg: \(mergeEndpoint.absoluteString)")

        // Execute the request
        let response = try await httpClient.execute(
            request,
            timeout: .seconds(Int64(waitTimeout) + 10)
        )

        // Validate the response status
        guard response.status == .ok else {
            var errorData = Data()
            for try await buffer in response.body {
                errorData.append(Data(buffer.readableBytesView))
            }

            if let errorMessage = String(data: errorData, encoding: .utf8) {
                logger.error("Gotenberg API error: \(errorMessage)")
                throw GotenbergError.apiError(statusCode: response.status.code, message: errorMessage)
            } else {
                logger.error("Gotenberg API error with status: \(response.status.code)")
                throw GotenbergError.apiError(statusCode: response.status.code, message: "Unknown error")
            }
        }

        // Collect response data
        logger.debug("Collecting response data from Gotenberg")
        var responseData = Data()
        for try await buffer in response.body {
            responseData.append(Data(buffer.readableBytesView))
        }

        logger.info("Successfully merged \(urls.count) PDFs from URLs, received \(responseData.count) bytes")
        return responseData
    }
}
