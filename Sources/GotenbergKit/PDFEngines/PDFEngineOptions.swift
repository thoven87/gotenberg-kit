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

    private let logger = Logger(label: "PDFEngineOptions")

    public init(
        metadata: Metadata? = nil,
        flatten: Bool = false,
        pdfa: Bool = false,
        format: PDFFormat? = nil
    ) {
        self.metadata = metadata
        self.flatten = flatten
        self.pdfua = pdfa
        self.format = format
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

        return values
    }
}
