//
//  PDFEngineOptions.swift
//  gotenberg-kit
//
//  Created by Stevenson Michel on 4/14/25.
//

import Logging

import class Foundation.JSONEncoder

public struct PDFEngineOptions: Sendable {
    /// The metadata to write
    public var metadata: Metadata?
    /// Flatten the resulting PDF
    public var flatten: Bool = false
    /// Enable PDF for universal Acess for optimal accessiblility
    public var pdfua: Bool = false
    /// PDF Format
    public var format: PDFFormat?
    /// Password for opening the resulting PDF
    public var userPassword: String?
    /// Password for full access on the resulting PDF
    public var ownerPassword: String?

    private let logger = Logger(label: "PDFEngineOptions")

    public init(
        metadata: Metadata? = nil,
        flatten: Bool = false,
        pdfa: Bool = false,
        format: PDFFormat? = nil,
        userPassword: String? = nil,
        ownerPassword: String? = nil
    ) {
        self.metadata = metadata
        self.flatten = flatten
        self.pdfua = pdfa
        self.format = format
        self.userPassword = userPassword
        self.ownerPassword = ownerPassword
    }

    var formValues: [String: String] {
        var values: [String: String] = [:]

        values["flatten"] = flatten ? "true" : "false"
        values["pdfua"] = pdfua ? "true" : "false"

        if let format = format {
            values["pdfa"] = format.rawValue
        }

        if let metadata = metadata {
            do {
                let encoder = JSONEncoder()
                encoder.dateEncodingStrategy = .formatted(Metadata.dateFormatter())

                let data = try encoder.encode(metadata)
                values["metadata"] = String(decoding: data, as: UTF8.self)
            } catch {
                logger.error(
                    "Error serializing metadata",
                    metadata: [
                        "error": .string(error.localizedDescription)
                    ]
                )
            }
        }

        if let userPassword = userPassword {
            values["userPassword"] = userPassword
        }

        if let ownerPassword = ownerPassword {
            values["ownerPassword"] = ownerPassword
        }

        return values
    }
}
