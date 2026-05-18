//
//  ConvertWithLibreOfficeTests.swift
//  gotenberg-kit
//
//  Created by Stevenson Michel on 4/11/25.
//
import Foundation
import Logging
import Testing

@testable import GotenbergKit

@Suite("ConvertWithLibreOfficeTests")
struct ConvertWithLibreOfficeTests {

    let logger = Logger(label: "ConvertWithLibreOfficeTests")

    let client = GotenbergClient(
        baseURL: URL(
            string: ProcessInfo.processInfo.environment["GOTENBERG_URL"] ?? "http://localhost:7100"
        )!,
        username: "gotenberg",
        password: "password"
    )

    let metadata: Metadata = Metadata(
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

    @Test
    func convertDocumentFromURL() async throws {
        // Use the CSV already in the test resources via its raw GitHub URL.
        // data.ny.gov blocks non-browser IPs; GitHub raw is reliably accessible
        // from CI and returns the file extension in the URL path so Gotenberg
        // can derive the filename without a Content-Disposition header.
        let url =
            "https://raw.githubusercontent.com/thoven87/gotenberg-kit/main/Tests/GotenbergKitTests/Resources/documents/MTA_Subway_Major_Incidents__Beginning_2020.csv"
        let downloadFrom = DownloadFrom(url: url, extraHttpHeaders: nil)

        logger.info("Converting CSV to PDF")

        let response = try await client.convertWithLibreOffice(
            urls: [downloadFrom, downloadFrom]
        )

        #expect(response.status == .ok)
    }

    @Test
    func convertOpenDocumentToPDF() async throws {
        logger.info("Converting Open Document to PDF")
        let resourceURL = try #require(Bundle.module.url(forResource: "sample", withExtension: "odt", subdirectory: "Resources/documents"))

        let document = try Data(contentsOf: resourceURL)

        // Convert to PDF with options
        let response = try await client.convertWithLibreOffice(
            documents: [
                "sample.odt": document
            ]
        )

        #expect(response.status == .ok)
        let expectedBytes = response.headers.first(name: "content-length").flatMap(Int.init) ?? 0
        #expect(expectedBytes > 0)
    }

    /// Example: Convert and merge multiple documents
    @Test
    func convertAndMergeDocuments() async throws {
        logger.info("Converting and merging multiple documents")

        let odt = try #require(Bundle.module.url(forResource: "sample", withExtension: "odt", subdirectory: "Resources/documents"))

        let pdf = try #require(Bundle.module.url(forResource: "simple", withExtension: "pdf", subdirectory: "Resources/documents"))

        let csv = Bundle.module.url(
            forResource: "MTA_Subway_Major_Incidents__Beginning_2020",
            withExtension: "csv",
            subdirectory: "Resources/documents"
        )!

        // Load multiple documents
        let document1 = try Data(contentsOf: odt)
        let document2 = try Data(contentsOf: pdf)
        let document3 = try Data(contentsOf: csv)

        // Prepare documents dictionary
        let documents = [
            "sample.odt": document1,
            "simple.pdf": document2,
            "MTA_Subway_Major_Incidents__Beginning_2020.csv": document3,
        ]

        // Convert and merge
        let mergedPDF = try await client.convertWithLibreOffice(
            documents: documents,
            options: LibreOfficeConversionOptions(
                merge: true,
                pdfFormat: .A1B,
                metadata: metadata,
                flatten: true
            ),
            waitTimeout: 90  // Longer timeout for multiple documents
        )

        #expect(mergedPDF.status == .ok)

        // Save the merged PDF
        let outputPath = "/tmp/merged_documents.pdf"
        try await client.writeToFile(mergedPDF, at: outputPath)
    }

    /// Example: Convert and merge documents from URLs
    @Test
    func convertAndMergeFromURLs() async throws {
        logger.info("Converting and merging documents from URLs")

        // Use the CSV already in the test resources via its raw GitHub URL.
        // data.ny.gov blocks non-browser IPs; this URL is self-contained and
        // always publicly accessible from CI without rate-limiting or auth.
        let csvURL =
            "https://raw.githubusercontent.com/thoven87/gotenberg-kit/main/Tests/GotenbergKitTests/Resources/documents/MTA_Subway_Major_Incidents__Beginning_2020.csv"
        let documentURLs = [csvURL, csvURL].map { DownloadFrom(url: $0) }

        let mergedDocument = try await client.convertWithLibreOffice(
            urls: documentURLs,
            waitTimeout: 90
        )
        let outputPath = "/tmp/merged_documents_from_urls.pdf"
        try await client.writeToFile(mergedDocument, at: outputPath)
    }
}
