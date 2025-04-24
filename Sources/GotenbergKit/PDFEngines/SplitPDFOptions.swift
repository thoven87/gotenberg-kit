//
//  SplitPDFOptions.swift
//  gotenberg-kit
//
//  Created by Stevenson Michel on 4/24/25.
//

import Logging

import class Foundation.JSONEncoder

/// Split PDF options
public struct SplitPDFOptions: Sendable {
    /// Flatten the PDF document (Forms will not be editable)
    public var flatten: Bool
    ///Specify whether to put extracted pages into a single file
    ///or as many files as there are page ranges.
    ///Only works with pages mode.
    public var splitUnify: Bool
    /// Either the intervals or the page ranges to extract, depending on the selected mode.
    /// e.g when mode is set to pages the values passed should be in this format 1-2
    public var splitSpan: String
    /// Either intervals or pages.
    public var splitMode: SplitPDFMode
    /// Convert the resulting PDF(s) into the given PDF/A format.
    public var pdfa: PDFFormat?
    /// Enable PDF for Universal Access for optimal accessibility.
    public var pdfua: Bool
    /// The metadata to write
    public var metadata: Metadata?

    private let logger = Logger(label: "SplitPDFOptions")

    public enum SplitPDFMode: String, Codable, Sendable {
        case pages
        case intervals
    }

    public init(
        flatten: Bool = false,
        splitUnify: Bool = false,
        splitSpan: String,
        splitMode: SplitPDFMode,
        pdfa: PDFFormat? = nil,
        pdfua: Bool = false,
        metadata: Metadata? = nil
    ) {
        self.flatten = flatten
        self.splitUnify = splitUnify
        self.splitSpan = splitSpan
        self.splitMode = splitMode
        self.pdfa = pdfa
        self.pdfua = pdfua
        self.metadata = metadata
    }

    var formValues: [String: String] {
        var values: [String: String] = [:]

        values["flatten"] = String(flatten)
        values["splitUnify"] = String(splitUnify)

        values["splitSpan"] = splitSpan
        values["splitMode"] = splitMode.rawValue

        if let pdfa = pdfa {
            values["pdfa"] = pdfa.rawValue
        }

        values["pdfua"] = String(pdfua)

        if let metadata = metadata {
            do {
                let encoder = JSONEncoder()

                encoder.dateEncodingStrategy = .formatted(Metadata.dateFormatter())

                let data = try encoder.encode(metadata)

                if let stringValue = String(data: data, encoding: .utf8) {
                    values["metadata"] = stringValue
                }
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
