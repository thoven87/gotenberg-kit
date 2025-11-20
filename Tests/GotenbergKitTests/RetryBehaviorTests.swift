//
//  PDFEnginesTests.swift
//  gotenberg-kit
//
//  Created by Stevenson Michel on 11/19/25.
//

import AsyncHTTPClient
import Foundation
import Logging
import NIOHTTP1
import Testing

@testable import GotenbergKit

@Suite("Retry Behavior Tests")
struct RetryBehaviorTests {

    /// Test that non-retryable server errors are not retried
    @Test
    func testNonRetryableServerErrors() async throws {
        // Test metadata errors are not retried
        let metadataErrorMessages = [
            "write metadata: write metadata into '/tmp/test.pdf': write PDF metadata with multi PDF engines: read metadata with ExitfTool: error during unmarshaling",
            "error during unmarshaling perl: warning: Setting locale failed",
            "ExifTool version error: metadata processing failed",
            "write PDF metadata with multi PDF engines: configuration error",
        ]

        let client = GotenbergClient(baseURL: URL(string: "http://localhost:3000")!)

        for errorMessage in metadataErrorMessages {
            let isRetryable = client.isRetryableServerError(status: .internalServerError, errorMessage: errorMessage)
            #expect(isRetryable == false, "Error message '\(errorMessage)' should not be retryable")
        }
    }

    /// Test that retryable server errors are properly identified
    @Test
    func testRetryableServerErrors() async throws {
        let retryableErrorMessages = [
            "Internal server error: timeout processing request",
            "Database connection failed",
            "Service temporarily unavailable",
            "Memory allocation failed",
            "Network connection timeout",
        ]

        let client = GotenbergClient(baseURL: URL(string: "http://localhost:3000")!)

        for errorMessage in retryableErrorMessages {
            let isRetryable = client.isRetryableServerError(status: .internalServerError, errorMessage: errorMessage)
            #expect(isRetryable == true, "Error message '\(errorMessage)' should be retryable")
        }
    }

    /// Test that Chromium console errors are not retried
    @Test
    func testChromiumConsoleErrors() async throws {
        let chromiumErrorMessages = [
            "Chromium console exceptions:\nexception \"Uncaught\" (17:10): Error: Exception 1\nat file:///tmp/test.html:18:11;",
            "Chromium fails to load at least one resource",
            "exception \"Uncaught\" (20:10): Error: Exception 2",
            "fails to load at least one resource",
            "resource loading failed: timeout",
            "failed to load resource: network error",
        ]

        let client = GotenbergClient(baseURL: URL(string: "http://localhost:3000")!)

        for errorMessage in chromiumErrorMessages {
            let isRetryable = client.isRetryableServerError(status: .internalServerError, errorMessage: errorMessage)
            #expect(isRetryable == false, "Chromium error '\(errorMessage)' should not be retryable")
        }
    }

    /// Test that 409 Conflict status codes are never retried regardless of message
    @Test
    func testConflictStatusNotRetryable() async throws {
        let client = GotenbergClient(baseURL: URL(string: "http://localhost:3000")!)

        // Even with retryable-looking messages, 409s should never be retried
        let conflictMessages = [
            "Internal server error: timeout processing request",
            "Service temporarily unavailable",
            "Memory allocation failed",
            "Database connection failed",
        ]

        for errorMessage in conflictMessages {
            let isRetryable = client.isRetryableServerError(status: .conflict, errorMessage: errorMessage)
            #expect(isRetryable == false, "409 Conflict with message '\(errorMessage)' should not be retryable")
        }
    }

    /// Test that all 4xx status codes are not retryable
    @Test
    func testClientErrorsNotRetryable() async throws {
        let client = GotenbergClient(baseURL: URL(string: "http://localhost:3000")!)
        let clientErrorStatuses: [HTTPResponseStatus] = [
            .badRequest, .unauthorized, .forbidden, .notFound, .methodNotAllowed,
            .conflict, .unprocessableEntity, .tooManyRequests,
        ]

        for status in clientErrorStatuses {
            let isRetryable = client.isRetryableServerError(status: status, errorMessage: "Some error message")
            #expect(isRetryable == false, "Status \(status) should not be retryable")
        }
    }

    /// Test that PDF processing errors are not retried
    @Test
    func testPDFProcessingErrors() async throws {
        let pdfErrorMessages = [
            "PDF corruption detected in document structure",
            "invalid pdf structure: malformed header",
            "unsupported pdf version: 2.0",
        ]

        let client = GotenbergClient(baseURL: URL(string: "http://localhost:3000")!)

        for errorMessage in pdfErrorMessages {
            let isRetryable = client.isRetryableServerError(status: .internalServerError, errorMessage: errorMessage)
            #expect(isRetryable == false, "PDF error '\(errorMessage)' should not be retryable")
        }
    }

    /// Test that 5xx server errors are retryable when not matching non-retryable patterns
    @Test
    func testRetryable5xxServerErrors() async throws {
        let client = GotenbergClient(baseURL: URL(string: "http://localhost:3000")!)
        let retryable5xxStatuses: [HTTPResponseStatus] = [
            .internalServerError, .notImplemented, .badGateway, .serviceUnavailable,
            .gatewayTimeout, .httpVersionNotSupported, .variantAlsoNegotiates,
            .insufficientStorage, .loopDetected, .notExtended, .networkAuthenticationRequired,
        ]

        let genericServerErrorMessages = [
            "Database connection timeout",
            "Temporary resource allocation failure",
            "Service overloaded, please retry",
            "Internal processing error occurred",
        ]

        for status in retryable5xxStatuses {
            for errorMessage in genericServerErrorMessages {
                let isRetryable = client.isRetryableServerError(status: status, errorMessage: errorMessage)
                #expect(isRetryable == true, "5xx status \(status) with generic error '\(errorMessage)' should be retryable")
            }
        }
    }
}
