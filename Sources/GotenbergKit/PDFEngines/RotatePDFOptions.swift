//
//  RotatePDFOptions.swift
//  gotenberg-kit
//

import struct Foundation.Data

/// Options for rotating pages in a PDF.
/// Route: POST /forms/pdfengines/rotate
public struct RotatePDFOptions: Sendable {

    /// The clockwise rotation angle to apply.
    public enum Angle: Int, Sendable {
        case degrees90 = 90
        case degrees180 = 180
        case degrees270 = 270
    }

    /// Clockwise rotation angle. Required.
    public var angle: Angle

    /// Page ranges to rotate, e.g. "1-3,5". Omit or leave nil to rotate all pages.
    public var pages: String?

    public init(angle: Angle, pages: String? = nil) {
        self.angle = angle
        self.pages = pages
    }

    var formValues: [String: String] {
        var v: [String: String] = [:]
        v["rotateAngle"] = String(angle.rawValue)
        if let pages = pages { v["rotatePages"] = pages }
        return v
    }
}
