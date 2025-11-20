//
//  EncryptionTests.swift
//  gotenberg-kit
//
//  Created by Stevenson Michel on 11/19/25.
//

import AsyncHTTPClient
import Foundation
import Testing

@testable import GotenbergKit

@Suite("PDF Encryption Tests")
struct EncryptionTests {

    let client = GotenbergClient(
        baseURL: URL(string: ProcessInfo.processInfo.environment["GOTENBERG_URL"] ?? "http://localhost:7100")!,
        username: "gotenberg",
        password: "password"
    )

    let metadata: Metadata = Metadata(
        author: "Swift",
        copyright: "Swift Gotenberg",
        creator: "SwiftGotenberg",
        marked: false,
        modDate: .init(),
        pDFVersion: 1.7,
        producer: "Swift",
        subject: "Some Document",
        title: "Some Document"
    )

    /// Test that ChromiumOptions properly includes encryption parameters in form values
    @Test
    func testChromiumOptionsEncryption() async throws {
        let options = ChromiumOptions(
            userPassword: "user123",
            ownerPassword: "owner456"
        )

        let formValues = options.formValues

        #expect(formValues["userPassword"] == "user123", "User password should be included in form values")
        #expect(formValues["ownerPassword"] == "owner456", "Owner password should be included in form values")
    }

    /// Test that ChromiumOptions with no encryption passwords doesn't include password fields
    @Test
    func testChromiumOptionsNoEncryption() async throws {
        let options = ChromiumOptions()

        let formValues = options.formValues

        #expect(formValues["userPassword"] == nil, "User password should not be included when not set")
        #expect(formValues["ownerPassword"] == nil, "Owner password should not be included when not set")
    }

    /// Test that LibreOfficeConversionOptions properly includes encryption parameters
    @Test
    func testLibreOfficeOptionsEncryption() async throws {
        let options = LibreOfficeConversionOptions(
            userPassword: "libre_user",
            ownerPassword: "libre_owner"
        )

        let formValues = options.formValues

        #expect(formValues["userPassword"] == "libre_user", "User password should be included in LibreOffice form values")
        #expect(formValues["ownerPassword"] == "libre_owner", "Owner password should be included in LibreOffice form values")
    }

    /// Test that LibreOfficeConversionOptions with no encryption passwords doesn't include password fields
    @Test
    func testLibreOfficeOptionsNoEncryption() async throws {
        let options = LibreOfficeConversionOptions()

        let formValues = options.formValues

        #expect(formValues["userPassword"] == nil, "User password should not be included when not set")
        #expect(formValues["ownerPassword"] == nil, "Owner password should not be included when not set")
    }

    /// Test that PDFEngineOptions properly includes encryption parameters
    @Test
    func testPDFEngineOptionsEncryption() async throws {
        let options = PDFEngineOptions(
            userPassword: "pdf_user",
            ownerPassword: "pdf_owner"
        )

        let formValues = options.formValues

        #expect(formValues["userPassword"] == "pdf_user", "User password should be included in PDF engine form values")
        #expect(formValues["ownerPassword"] == "pdf_owner", "Owner password should be included in PDF engine form values")
    }

    /// Test that PDFEngineOptions with no encryption passwords doesn't include password fields
    @Test
    func testPDFEngineOptionsNoEncryption() async throws {
        let options = PDFEngineOptions()

        let formValues = options.formValues

        #expect(formValues["userPassword"] == nil, "User password should not be included when not set")
        #expect(formValues["ownerPassword"] == nil, "Owner password should not be included when not set")
    }

    /// Test encryption with only user password set
    @Test
    func testUserPasswordOnly() async throws {
        let chromiumOptions = ChromiumOptions(userPassword: "only_user")
        let libreOptions = LibreOfficeConversionOptions(userPassword: "only_user")
        let pdfOptions = PDFEngineOptions(userPassword: "only_user")

        let chromiumValues = chromiumOptions.formValues
        let libreValues = libreOptions.formValues
        let pdfValues = pdfOptions.formValues

        // Chromium
        #expect(chromiumValues["userPassword"] == "only_user", "Chromium user password should be set")
        #expect(chromiumValues["ownerPassword"] == nil, "Chromium owner password should not be set")

        // LibreOffice
        #expect(libreValues["userPassword"] == "only_user", "LibreOffice user password should be set")
        #expect(libreValues["ownerPassword"] == nil, "LibreOffice owner password should not be set")

        // PDF Engine
        #expect(pdfValues["userPassword"] == "only_user", "PDF engine user password should be set")
        #expect(pdfValues["ownerPassword"] == nil, "PDF engine owner password should not be set")
    }

    /// Test encryption with only owner password set
    @Test
    func testOwnerPasswordOnly() async throws {
        let chromiumOptions = ChromiumOptions(ownerPassword: "only_owner")
        let libreOptions = LibreOfficeConversionOptions(ownerPassword: "only_owner")
        let pdfOptions = PDFEngineOptions(ownerPassword: "only_owner")

        let chromiumValues = chromiumOptions.formValues
        let libreValues = libreOptions.formValues
        let pdfValues = pdfOptions.formValues

        // Chromium
        #expect(chromiumValues["userPassword"] == nil, "Chromium user password should not be set")
        #expect(chromiumValues["ownerPassword"] == "only_owner", "Chromium owner password should be set")

        // LibreOffice
        #expect(libreValues["userPassword"] == nil, "LibreOffice user password should not be set")
        #expect(libreValues["ownerPassword"] == "only_owner", "LibreOffice owner password should be set")

        // PDF Engine
        #expect(pdfValues["userPassword"] == nil, "PDF engine user password should not be set")
        #expect(pdfValues["ownerPassword"] == "only_owner", "PDF engine owner password should be set")
    }

    /// Test encryption with complex passwords containing special characters
    @Test
    func testComplexPasswords() async throws {
        let complexUserPassword = "User@123!#$%^&*()"
        let complexOwnerPassword = "Owner$456!@#$%^&*()"

        let options = ChromiumOptions(
            userPassword: complexUserPassword,
            ownerPassword: complexOwnerPassword
        )

        let formValues = options.formValues

        #expect(formValues["userPassword"] == complexUserPassword, "Complex user password should be preserved")
        #expect(formValues["ownerPassword"] == complexOwnerPassword, "Complex owner password should be preserved")
    }

    /// Test encryption with empty strings (should be treated as nil)
    @Test
    func testEmptyPasswordStrings() async throws {
        let options = ChromiumOptions(
            userPassword: "",
            ownerPassword: ""
        )

        let formValues = options.formValues

        // Empty strings should still be included (Gotenberg handles empty vs nil differently)
        #expect(formValues["userPassword"] == "", "Empty user password string should be preserved")
        #expect(formValues["ownerPassword"] == "", "Empty owner password string should be preserved")
    }

    /// Test that encryption parameters work with other options
    @Test
    func testEncryptionWithOtherOptions() async throws {
        let options = ChromiumOptions(
            paperWidth: 8.5,
            paperHeight: 11.0,
            marginTop: 1.0,
            printBackground: true,
            userPassword: "test_user",
            ownerPassword: "test_owner"
        )

        let formValues = options.formValues

        // Check that other options are still present
        #expect(formValues["paperWidth"] == "8.5", "Paper width should be preserved")
        #expect(formValues["paperHeight"] == "11.0", "Paper height should be preserved")
        #expect(formValues["marginTop"] == "1.0", "Margin top should be preserved")
        #expect(formValues["printBackground"] == "true", "Print background should be preserved")

        // Check encryption options
        #expect(formValues["userPassword"] == "test_user", "User password should be present with other options")
        #expect(formValues["ownerPassword"] == "test_owner", "Owner password should be present with other options")
    }

    /// Test that LibreOffice source password and encryption passwords are different
    @Test
    func testLibreOfficeSourceVsEncryptionPasswords() async throws {
        let options = LibreOfficeConversionOptions(
            password: "source_password",  // For opening the source file
            userPassword: "encryption_user",  // For encrypting the output PDF
            ownerPassword: "encryption_owner"  // For encrypting the output PDF
        )

        let formValues = options.formValues

        #expect(formValues["password"] == "source_password", "Source file password should be set")
        #expect(formValues["userPassword"] == "encryption_user", "Output PDF user password should be set")
        #expect(formValues["ownerPassword"] == "encryption_owner", "Output PDF owner password should be set")
    }

    /// Test dedicated PDF encryption method with documents
    @Test
    func testEncryptPDFsWithDocuments() async throws {

        // Create a simple PDF first
        let htmlContent = """
            <!DOCTYPE html>
            <html>
            <head><title>Test PDF</title></head>
            <body><h1>Test Document for Encryption</h1></body>
            </html>
            """

        // First create unencrypted PDF with explicit metadata
        let initialResponse = try await client.convert(
            html: htmlContent.data(using: .utf8)!,
            options: ChromiumOptions(metadata: metadata)
        )

        let pdfData = try await client.toData(initialResponse)
        let documents = ["test.pdf": pdfData]

        // Test with both passwords using dedicated encryption endpoint
        let encryptedResponse = try await client.encryptPDFs(
            documents: documents,
            options: PDFEngineOptions(
                userPassword: "user123",
                ownerPassword: "owner456"
            )
        )

        let encryptedData = try await client.toData(encryptedResponse)
        #expect(encryptedData.count > 0, "Encrypted PDF should contain data")

        // Verify it's a valid PDF
        let pdfHeader = String(data: encryptedData.prefix(4), encoding: .ascii)
        #expect(pdfHeader == "%PDF", "Encrypted file should be a valid PDF")

        // Save files to examine metadata behavior
        try pdfData.write(to: URL(fileURLWithPath: "/tmp/metadata_original.pdf"))
        try encryptedData.write(to: URL(fileURLWithPath: "/tmp/metadata_encrypted.pdf"))

        print("🔍 Metadata Encryption Test:")
        print("📄 Original: /tmp/metadata_original.pdf")
        print("🔒 Encrypted: /tmp/metadata_encrypted.pdf")
        print("📋 Metadata set: Author=Swift, Title=Some Document, Subject=Some Document")
        print("🔑 Passwords: user123 / owner456")

        // Test with only user password
        let encryptedResponse2 = try await client.encryptPDFs(
            documents: documents,
            options: PDFEngineOptions(
                userPassword: "user123"
            )
        )

        let encryptedData2 = try await client.toData(encryptedResponse2)
        #expect(encryptedData2.count > 0, "Encrypted PDF with user password only should contain data")
    }

    /// Test dedicated PDF encryption with metadata override
    @Test
    func testDedicatedPDFEncryption() async throws {
        // Create a simple PDF first with original metadata
        let htmlContent = """
            <!DOCTYPE html>
            <html>
            <head><title>Original PDF</title></head>
            <body><h1>Original Document</h1></body>
            </html>
            """

        // Create unencrypted PDF with original metadata
        let initialResponse = try await client.convert(
            html: htmlContent.data(using: .utf8)!,
            options: ChromiumOptions(metadata: metadata)
        )

        let pdfData = try await client.toData(initialResponse)
        let documents = ["original.pdf": pdfData]

        // Test encryption WITH metadata override
        let overrideMetadata = Metadata(
            author: "Override Author",
            copyright: "Override Copyright",
            creator: "Override Creator",
            marked: false,
            modDate: .init(),
            pDFVersion: 1.7,
            producer: "Override Producer",
            subject: "Override Subject",
            title: "Override Title"
        )

        let encryptedWithOverride = try await client.encryptPDFs(
            documents: documents,
            options: PDFEngineOptions(
                metadata: overrideMetadata,
                userPassword: "user123",
                ownerPassword: "owner456"
            )
        )

        let encryptedOverrideData = try await client.toData(encryptedWithOverride)
        #expect(encryptedOverrideData.count > 0, "Encrypted PDF with metadata override should contain data")

        // Test encryption WITHOUT metadata override (preserves original)
        let encryptedWithoutOverride = try await client.encryptPDFs(
            documents: documents,
            options: PDFEngineOptions(
                userPassword: "user789",
                ownerPassword: "owner123"
            )
        )

        let encryptedOriginalData = try await client.toData(encryptedWithoutOverride)
        #expect(encryptedOriginalData.count > 0, "Encrypted PDF without metadata override should contain data")

        // Save files to examine metadata behavior
        try pdfData.write(to: URL(fileURLWithPath: "/tmp/dedicated_original.pdf"))
        try encryptedOverrideData.write(to: URL(fileURLWithPath: "/tmp/dedicated_encrypted_override.pdf"))
        try encryptedOriginalData.write(to: URL(fileURLWithPath: "/tmp/dedicated_encrypted_original.pdf"))

        print("🔍 Dedicated Encryption Metadata Test:")
        print("📄 Original: /tmp/dedicated_original.pdf")
        print("🔒 Override: /tmp/dedicated_encrypted_override.pdf (should have 'Override' metadata)")
        print("🔒 Preserve: /tmp/dedicated_encrypted_original.pdf (should have original 'Swift' metadata)")
        print("🔑 Override passwords: user123 / owner456")
        print("🔑 Preserve passwords: user789 / owner123")

        // Verify both are valid PDFs
        let overridePdfHeader = String(data: encryptedOverrideData.prefix(4), encoding: .ascii)
        let originalPdfHeader = String(data: encryptedOriginalData.prefix(4), encoding: .ascii)
        #expect(overridePdfHeader == "%PDF", "Encrypted override file should be a valid PDF")
        #expect(originalPdfHeader == "%PDF", "Encrypted original file should be a valid PDF")
    }
}
