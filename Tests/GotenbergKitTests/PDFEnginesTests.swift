//
//  PDFEnginesTests.swift
//  gotenberg-kit
//
//  Created by Stevenson Michel on 4/24/25.
//
import AsyncHTTPClient
import Foundation
import Logging
import Testing

@testable import GotenbergKit

@Suite("PDF Engines Tests")
struct PDFEnginesTests {

    let serverURL = ProcessInfo.processInfo.environment["FILE_SERVER_URL"] ?? "http://host.docker.internal:8081"

    let client = GotenbergClient(
        baseURL: URL(string: ProcessInfo.processInfo.environment["GOTENBERG_URL"] ?? "http://localhost:7100")!,
        username: "gotenberg",
        password: "password"
    )

    private let logger = Logger(label: "GotenbergKitTests")

    private var baseOutputPath: String {
        let subpath = "/tmp"

        return subpath
    }

    private let metadata: Metadata = Metadata(
        author: "Swift",
        copyright: "Swift Gotenberg",
        creator: "SwiftGotenberg",
        marked: false,
        modDate: .init(),
        pDFVersion: 1.3,
        producer: "Swift",
        subject: "Some Document",
        title: "Some Document"
    )

    //    @Test
    //    func mergePDFsFromURL() async throws {
    //        let pdfURLs: [URL] = [
    //            "\(serverURL)/documents/page_1.pdf",
    //            "\(serverURL)/documents/page_2.pdf",
    //        ].map { URL(string: $0)! }
    //
    //        logger.info("Starting to merge \(pdfURLs.count) PDFs")
    //
    //        // Option 1: Using the convenience method
    //        let startTime = Date()
    //        let mergedPDF = try await client.mergeWithPDFEngines(
    //            urls: pdfURLs,
    //            waitTimeout: 10  // Increase timeout for larger PDFs or slower connections
    //        )
    //
    //        let duration = Date().timeIntervalSince(startTime)
    //
    //        let contentLength = mergedPDF.headers.first(name: "Content-Length").flatMap(Int.init) ?? 0
    //
    //        logger.info("Merged PDF size: \(contentLength) bytes, completed in \(String(format: "%.2f", duration)) seconds")
    //
    //        // Save the merged PDF
    //        let outputPath = "\(baseOutputPath)/merged_pdfs_from_urls.pdf"
    //        try await client.writeToFile(mergedPDF, at: outputPath)
    //        logger.info("Saved merged PDF to \(outputPath)")
    //    }

    @Test
    func mergePDFsFromPath() async throws {
        let pdf1 = Bundle.module.url(forResource: "page_1", withExtension: "pdf", subdirectory: "Resources/documents")!

        let pdf2 = Bundle.module.url(forResource: "page_2", withExtension: "pdf", subdirectory: "Resources/documents")!

        let document1 = try Data(contentsOf: pdf1)
        let document2 = try Data(contentsOf: pdf2)

        logger.info("Starting to merge PDFs")

        // Option 1: Using the convenience method
        let startTime = Date()
        let mergedPDF = try await client.mergeWithPDFEngines(
            documents: [
                "page_1.pdf": document1,
                "page_2.pdf": document2,
            ],
            waitTimeout: 10  // Increase timeout for larger PDFs or slower connections
        )

        let duration = Date().timeIntervalSince(startTime)

        let contentLength = mergedPDF.headers.first(name: "Content-Length").flatMap(Int.init) ?? 0

        logger.info("Merged PDF size: \(contentLength) bytes, completed in \(String(format: "%.2f", duration)) seconds")

        // Save the merged PDF
        let outputPath = "\(baseOutputPath)/merged_pdfs_from_paths.pdf"
        try await client.writeToFile(mergedPDF, at: outputPath)
        logger.info("Saved merged PDF to \(outputPath)")
        #expect(mergedPDF.status == .ok)
    }

    @Test
    func convertWithPDFEngines() async throws {
        let doc1 = Bundle.module.url(forResource: "page_1", withExtension: "pdf", subdirectory: "Resources/documents")!

        let doc2 = Bundle.module.url(forResource: "page_2", withExtension: "pdf", subdirectory: "Resources/documents")!

        let document1 = try Data(contentsOf: doc1)
        let document2 = try Data(contentsOf: doc2)

        logger.info("Starting to convert files to PDF")

        // Option 1: Using the convenience method
        let startTime = Date()
        let pdfDocument = try await client.convertWithPDFEngines(
            documents: [
                "page_1.pdf": document1,
                "page_2.pdf": document2,
            ],
            options: PDFEngineOptions(
                metadata: metadata,
                pdfa: true,
                format: .A2B
            ),
            waitTimeout: 10
        )

        let duration = Date().timeIntervalSince(startTime)

        let contentLength = pdfDocument.headers.first(name: "Content-Length").flatMap(Int.init) ?? 0

        logger.info("Converted PDF size: \(contentLength) bytes, completed in \(String(format: "%.2f", duration)) seconds")

        // Save the converted PDF file
        let outputPath = "\(baseOutputPath)/converted_document.pdf"
        try await client.writeToFile(pdfDocument, at: outputPath)
        logger.info("Saved PDF to \(outputPath)")
        #expect(pdfDocument.status == .ok)
    }

    @Test
    func splitPDFs() async throws {
        let document = Bundle.module.url(forResource: "pages_3", withExtension: "pdf", subdirectory: "Resources/documents")!

        logger.info("Starting to split file to mutiple PDFs")

        let startTime = Date()
        let splitPDFs = try await client.splitPDF(
            documents: [
                "page_3.pdf": try Data(contentsOf: document)
            ],
            waitTimeout: 10
        )

        let duration = Date().timeIntervalSince(startTime)

        let contentLength = splitPDFs.headers.first(name: "Content-Length").flatMap(Int.init) ?? 0

        logger.info("Split PDF size: \(contentLength) bytes, completed in \(String(format: "%.2f", duration)) seconds")

        // Save the converted PDF file
        let outputPath = "\(baseOutputPath)/split_pdfs.zip"
        try await client.writeToFile(splitPDFs, at: outputPath)
        logger.info("Saved Zip file to \(outputPath)")
        #expect(splitPDFs.status == .ok)
    }

    @Test
    func flattenPDFs() async throws {
        let document = Bundle.module.url(forResource: "pages_3", withExtension: "pdf", subdirectory: "Resources/documents")!

        let document1 = Bundle.module.url(forResource: "page_1", withExtension: "pdf", subdirectory: "Resources/documents")!

        logger.info("Starting to flatten files")

        let startTime = Date()
        let flattenPDFs = try await client.flattenPDF(
            documents: [
                "page_1.pdf": try Data(contentsOf: document1),
                "pages_3.pdf": try Data(contentsOf: document),
            ],
            waitTimeout: 10
        )

        let duration = Date().timeIntervalSince(startTime)

        let contentLength = flattenPDFs.headers.first(name: "Content-Length").flatMap(Int.init) ?? 0

        logger.info("Flattened PDF size: \(contentLength) bytes, completed in \(String(format: "%.2f", duration)) seconds")

        // Save the converted PDF file
        let outputPath = "\(baseOutputPath)/flattened_pdfs.zip"
        try await client.writeToFile(flattenPDFs, at: outputPath)
        logger.info("Saved Zip file to \(outputPath)")
        #expect(flattenPDFs.status == .ok)
    }

    @Test
    func writePDFsMetadata() async throws {
        let document = Bundle.module.url(forResource: "pages_3", withExtension: "pdf", subdirectory: "Resources/documents")!

        let document1 = Bundle.module.url(forResource: "page_1", withExtension: "pdf", subdirectory: "Resources/documents")!

        logger.info("Starting to write metadata to files")

        let startTime = Date()
        let pdfsWithMetadata = try await client.writePDFMetadata(
            documents: [
                "page_1.pdf": try Data(contentsOf: document1),
                "pages_3.pdf": try Data(contentsOf: document),
            ],
            metadata: [
                "Author": "Swift",
                "Copyright": "Swift Gotenber SDK",
            ],
            waitTimeout: 10
        )

        let duration = Date().timeIntervalSince(startTime)

        let contentLength = pdfsWithMetadata.headers.first(name: "Content-Length").flatMap(Int.init) ?? 0

        logger.info("Wrote metadata to PDF size: \(contentLength) bytes, completed in \(String(format: "%.2f", duration)) seconds")

        // Save the converted PDF file
        let outputPath = "\(baseOutputPath)/metadata_pdfs.zip"
        try await client.writeToFile(pdfsWithMetadata, at: outputPath)
        logger.info("Saved Zip file to \(outputPath)")
        #expect(pdfsWithMetadata.status == .ok)
    }

    @Test
    func readPDFsMetadata() async throws {
        let document = Bundle.module.url(forResource: "pages_3", withExtension: "pdf", subdirectory: "Resources/documents")!

        let document1 = Bundle.module.url(forResource: "page_1", withExtension: "pdf", subdirectory: "Resources/documents")!

        logger.info("Starting to write metadata to files")

        let startTime = Date()
        let metadataResponse = try await client.readPDFMetadata(
            documents: [
                "page_1.pdf": try Data(contentsOf: document1),
                "pages_3.pdf": try Data(contentsOf: document),
            ],
            waitTimeout: 10
        )

        let duration = Date().timeIntervalSince(startTime)

        logger.info("Reading metadata completed in \(String(format: "%.2f", duration)) seconds")

        #expect(metadataResponse.status == .ok)
    }
}
