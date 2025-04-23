//
//  ScreenshotOptions.swift
//  gotenberg-kit
//
//  Created by Stevenson Michel on 4/12/25.
//

#if canImport(Darwin) || compiler(<6.0)
import Foundation
#else
import FoundationEssentials
#endif

// MARK: - Screenshot Options

public enum ScreenshotFormat: String, Sendable {
    case png
    case jpeg
    case webp
}

/// Options for customizing screenshot capture
public struct ScreenshotOptions: Sendable {
    /// Optional format for the screenshot (png, jpeg, webp)
    public var format: ScreenshotFormat?

    /// Quality for lossy image formats (0-100)
    public var quality: Int?

    /// Whether to capture the full page height
    public var fullPage: Bool?

    /// Whether to omit the background
    public var omitBackground: Bool?

    /// Width of the viewport for the screenshot
    public var width: Int?

    /// Height of the viewport for the screenshot
    public var height: Int?

    /// Define whether to clip the screenshot according to the device dimensions.
    public var clip: Bool?

    /// Define whether to optimize image encoding for speed, not for resulting size.
    public var optimizeForSpeed: Bool?

    //    /// Top clip position
    //    public var clipX: Int?
    //
    //    /// Left clip position
    //    public var clipY: Int?
    //
    //    /// Clip width
    //    public var clipWidth: Int?
    //
    //    /// Clip height
    //    public var clipHeight: Int?

    /// Wait delay before taking the screenshot (in seconds)
    public var waitDelay: Double?

    /// Wait for a JavaScript expression to evaluate to true
    public var waitForExpression: String?

    /// User agent to use for the navigation
    public var userAgent: String?

    /// Extra HTTP headers for the request
    public var extraHttpHeaders: [String: String]?

    /// Emulated media type (screen, print)
    public var emulatedMediaType: EmulatedMediaType?

    /// Default initializer with all optional parameters
    public init(
        format: ScreenshotFormat? = .png,
        quality: Int? = nil,
        fullPage: Bool? = nil,
        omitBackground: Bool? = nil,
        width: Int? = nil,
        height: Int? = nil,
        clip: Bool? = nil,
        waitDelay: Double? = nil,
        optimizeForSpeed: Bool? = nil,
        waitForExpression: String? = nil,
        userAgent: String? = nil,
        extraHttpHeaders: [String: String]? = nil,
        emulatedMediaType: EmulatedMediaType = .screen
    ) {
        self.format = format
        self.quality = quality
        self.fullPage = fullPage
        self.omitBackground = omitBackground
        self.width = width
        self.height = height
        //        self.clipX = clipX
        //        self.clipY = clipY
        //        self.clipWidth = clipWidth
        //        self.clipHeight = clipHeight
        self.clip = clip
        self.optimizeForSpeed = optimizeForSpeed
        self.waitDelay = waitDelay
        self.waitForExpression = waitForExpression
        self.userAgent = userAgent
        self.extraHttpHeaders = extraHttpHeaders
        self.emulatedMediaType = emulatedMediaType
    }

    var formValues: [String: String] {
        var values: [String: String] = [:]

        if let format = format {
            values["format"] = format.rawValue
        }

        if let quality = quality {
            values["quality"] = "\(quality)"
        }

        if let fullPage = fullPage {
            values["fullPage"] = fullPage ? "true" : "false"
        }

        if let omitBackground = omitBackground {
            values["omitBackground"] = omitBackground ? "true" : "false"
        }

        if let width = width {
            values["width"] = "\(width)"
        }

        if let height = height {
            values["height"] = "\(height)"
        }

        if let clip = clip {
            values["clip"] = clip ? "true" : "false"
        }

        if let optimizeForSpeed = optimizeForSpeed {
            values["optimizeForSpeed"] = optimizeForSpeed ? "true" : "false"
        }

        //        if let clipX = clipX {
        //            values["clipX"] = "\(clipX)"
        //        }
        //
        //        if let clipY = clipY {
        //            values["clipY"] = "\(clipY)"
        //        }
        //
        //        if let clipWidth = clipWidth {
        //            values["clipWidth"] = "\(clipWidth)"
        //        }
        //
        //        if let clipHeight = clipHeight {
        //            values["clipHeight"] = "\(clipHeight)"
        //        }

        if let waitDelay = waitDelay {
            values["waitDelay"] = "\(waitDelay)"
        }

        if let waitForExpression = waitForExpression {
            values["waitForExpression"] = waitForExpression
        }

        if let userAgent = userAgent {
            values["userAgent"] = userAgent
        }

        if let extraHttpHeaders = extraHttpHeaders, !extraHttpHeaders.isEmpty {
            do {
                let headersData = try JSONEncoder().encode(extraHttpHeaders)
                if let headersString = String(data: headersData, encoding: .utf8) {
                    values["extraHttpHeaders"] = headersString
                }
            } catch {
                print("Failed to serialize extra HTTP headers: \(error)")
            }
        }

        if let emulatedMediaType = emulatedMediaType {
            values["emulatedMediaType"] = emulatedMediaType.rawValue
        }

        return values
    }
}
