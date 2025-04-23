//
//  GotenbergError.swift
//  gotenberg-kit
//
//  Created by Stevenson Michel on 4/11/25.
//

// MARK: - Errors

/// Errors that can occur when using the Gotenberg client
public enum GotenbergError: Error {
    case noPDFsProvided
    case noFilesProvided
    case noURLsProvided
    case filenameCountMismatch
    case noPagesSpecified
    case apiError(statusCode: UInt, message: String)
    case invalidInput(message: String)
    case paperWidthTooSmall
    case paperHeightTooSmall
    case marginTooSmall
    case pageRangeInvalid
    
    public var errorDescription: String {
        switch self {
        case .noPDFsProvided:
            return "No PDF files provided"
        case .noFilesProvided:
            return "No files provided"
        case .noURLsProvided:
            return "No URLs provided"
        case .filenameCountMismatch:
            return "The number of filenames must match the number of files"
        case .noPagesSpecified:
            return "No pages specified for extraction"
        case .apiError(let statusCode, let message):
            return "Gotenberg API error (status \(statusCode)): \(message)"
        case .invalidInput(let message):
            return "Invalid input: \(message)"
        case .paperWidthTooSmall:
            return "Paper width must be at least 1.0 inches" // 21mm
        case .paperHeightTooSmall:
            return "Paper height must be at least 1.5 inches" // 29.7mm
        case .marginTooSmall:
            return "Margin must be at least 0 inches"
        case .pageRangeInvalid:
            return "Page range must be in format start-end abd with positive integers for start and end and start <= end."
        }
    }
}
