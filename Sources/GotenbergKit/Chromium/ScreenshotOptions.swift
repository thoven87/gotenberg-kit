import Logging

//
//  ScreenshotOptions.swift
//  gotenberg-kit
//
//  Created by Stevenson Michel on 4/12/25.
//
import class Foundation.JSONEncoder

// MARK: - Screenshot Options
/// Screenshot format
public enum ScreenshotFormat: String, Sendable {
    case png
    case jpeg
    case webp
}

/// Options for customizing screenshot capture
public struct ScreenshotOptions: Sendable {
    /// Optional format for the screenshot (png, jpeg, webp)
    public var format: ScreenshotFormat

    /// Quality for lossy image formats (0-100)
    public var quality: Int?

    /// Whether to omit the background
    public var omitBackground: Bool

    /// Width of the viewport for the screenshot
    /// default to 800
    public var width: Int

    /// Height of the viewport for the screenshot
    /// default 600
    public var height: Int

    /// Define whether to clip the screenshot according to the device dimensions.
    /// default false
    public var clip: Bool

    /// Define whether to optimize image encoding for speed, not for resulting size.
    public var optimizeForSpeed: Bool

    /// Wait delay before taking the screenshot (in seconds)
    public var waitDelay: Int?

    /// Wait for a JavaScript expression to evaluate to true
    public var waitForExpression: String?

    /// User agent to use for the navigation
    public var userAgent: String?

    /// Extra HTTP headers for the request
    public var extraHttpHeaders: [String: String]?

    /// Emulated media type (screen, print)
    public var emulatedMediaType: EmulatedMediaType?
    /// Cookies to be written
    public var cookies: [Cookie]?
    /// Return a 409 Conflict response if the HTTP status code from at least one resource is not acceptable.
    public var failOnResourceHttpStatusCodes: [Int]
    /// Return a 409 Conflict response if the HTTP status code from the main page is not acceptable.
    public var failOnHttpStatusCodes: [Int]
    /// Return a 409 Conflict response if Chromium fails to load at least one resource.
    public var failOnResourceLoadingFailed: Bool
    /// Return a 409 Conflict response if there are exceptions in the Chromium console.
    public var failOnConsoleExceptions: Bool
    /// Do not wait for Chromium network to be idle.
    public var skipNetworkIdleEvent: Bool

    private let logger = Logger(label: "com.gotenberg.kit.ScreenshotOptions")

    /// Default initializer with all optional parameters
    public init(
        format: ScreenshotFormat = .png,
        quality: Int? = nil,
        omitBackground: Bool = false,
        width: Int = 800,
        height: Int = 600,
        clip: Bool = false,
        waitDelay: Int? = nil,
        optimizeForSpeed: Bool = false,
        waitForExpression: String? = nil,
        userAgent: String? = nil,
        cookies: [Cookie]? = nil,
        extraHttpHeaders: [String: String]? = nil,
        emulatedMediaType: EmulatedMediaType = .screen,
        failOnHttpStatusCodes: [Int] = [499, 599],
        failOnResourceHttpStatusCodes: [Int] = [],
        failOnConsoleExceptions: Bool = false,
        skipNetworkIdleEvent: Bool = true,
        failOnResourceLoadingFailed: Bool = false
    ) {
        self.format = format
        self.quality = quality
        self.omitBackground = omitBackground
        self.width = width
        self.height = height
        self.clip = clip
        self.optimizeForSpeed = optimizeForSpeed
        self.waitDelay = waitDelay
        self.waitForExpression = waitForExpression
        self.userAgent = userAgent
        self.extraHttpHeaders = extraHttpHeaders
        self.emulatedMediaType = emulatedMediaType
        self.failOnHttpStatusCodes = failOnHttpStatusCodes
        self.failOnResourceHttpStatusCodes = failOnResourceHttpStatusCodes
        self.failOnConsoleExceptions = failOnConsoleExceptions
        self.skipNetworkIdleEvent = skipNetworkIdleEvent
        self.failOnResourceLoadingFailed = failOnResourceLoadingFailed
        self.cookies = cookies
    }

    var formValues: [String: String] {
        var values: [String: String] = [:]

        values["format"] = format.rawValue

        values["omitBackground"] = String(omitBackground)

        values["width"] = String(width)

        values["height"] = String(height)

        values["clip"] = String(clip)

        values["optimizeForSpeed"] = String(optimizeForSpeed)

        values["failOnHttpStatusCodes"] = "[\(failOnHttpStatusCodes.map(String.init).joined(separator: ","))]"
        values["failOnResourceHttpStatusCodes"] = "[\(failOnResourceHttpStatusCodes.map(String.init).joined(separator: ","))]"
        values["failOnConsoleExceptions"] = String(failOnConsoleExceptions)
        values["skipNetworkIdleEvent"] = String(skipNetworkIdleEvent)
        values["failOnResourceLoadingFailed"] = String(failOnResourceLoadingFailed)

        if let quality = quality {
            if format == .jpeg {
                values["quality"] = "\(quality)"
            }
        }

        if let waitDelay = waitDelay {
            values["waitDelay"] = "\(waitDelay)s"
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
                logger.error(
                    "Failed to serialize extra HTTP headers",
                    metadata: [
                        "error": "\(error)"
                    ]
                )
            }
        }

        if let cookies = cookies {
            do {
                let cookies = try JSONEncoder().encode(cookies)
                if let headersString = String(data: cookies, encoding: .utf8) {
                    values["cookies"] = headersString
                }
            } catch {
                logger.error(
                    "Failed to serialize cookies",
                    metadata: [
                        "error": "\(error)"
                    ]
                )
            }
        }

        if let emulatedMediaType = emulatedMediaType {
            values["emulatedMediaType"] = emulatedMediaType.rawValue
        }

        return values
    }
}
