//
//  WebhookConfiguration.swift
//  gotenberg-kit
//
//  Webhook support — switches any Gotenberg request from synchronous to async.
//
//  Usage:
//    let webhook = WebhookConfiguration(
//        webhookUrl: "https://my.service/gotenberg/success",
//        eventsUrl:  "https://my.service/gotenberg/events"
//    )
//    let response = try await gotenberg.convert(
//        html: htmlData,
//        options: options,
//        clientHTTPHeaders: webhook.asHeaders()
//    )
//    // response is 204 No Content — conversion runs in background
//

import Foundation

import class Foundation.JSONEncoder

/// Configuration for Gotenberg's async webhook mode.
///
/// When any `Gotenberg-Webhook-Url` header is present on a request, Gotenberg:
/// 1. Returns `204 No Content` immediately.
/// 2. Processes the conversion in the background.
/// 3. POSTs the result to `webhookUrl` on success.
/// 4. Fires a structured JSON event to `eventsUrl` (if provided).
///
/// Use `asHeaders()` to convert this configuration into a headers dictionary
/// and pass it as `clientHTTPHeaders` on any conversion method.
public struct WebhookConfiguration: Sendable {

    /// HTTP method for the webhook callback.
    public enum CallbackMethod: String, Sendable {
        case post = "POST"
        case put = "PUT"
        case patch = "PATCH"
    }

    // MARK: - Required

    /// The URL that receives the converted file on success (POST by default).
    public var webhookUrl: String

    // MARK: - Recommended

    /// URL that receives structured JSON events after each webhook operation.
    ///
    /// Events fire *after* the main webhook callbacks and never affect result delivery.
    /// Delivery failures to this URL are logged but do not cascade.
    ///
    /// Success event shape:
    /// ```json
    /// { "event": "webhook.success", "correlationId": "...", "timestamp": "..." }
    /// ```
    /// Error event shape:
    /// ```json
    /// { "event": "webhook.error", "correlationId": "...", "timestamp": "...",
    ///   "error": { "status": 500, "message": "..." } }
    /// ```
    public var eventsUrl: String?

    // MARK: - Optional

    /// HTTP method used for the success callback. Default `.post`.
    public var method: CallbackMethod

    /// URL for error callbacks.
    ///
    /// - Deprecated: Use ``eventsUrl`` instead. Gotenberg replaced the separate error
    ///   callback URL with the unified `Gotenberg-Webhook-Events-Url` mechanism.
    ///   If `errorUrl` is set and `eventsUrl` is not, the value is automatically
    ///   promoted to `eventsUrl` so the header is still sent correctly.
    @available(*, deprecated, message: "Use eventsUrl instead")
    public var errorUrl: String? {
        get { _errorUrl }
        set { _errorUrl = newValue }
    }

    /// Private backing store so `asHeaders()` can read the value without
    /// triggering the deprecation warning on itself.
    private var _errorUrl: String?

    /// HTTP method used for the error callback. Default `.post`.
    public var errorMethod: CallbackMethod

    /// Extra headers sent with every callback (success and error).
    /// Useful for authentication tokens.
    public var extraHttpHeaders: [String: String]?

    // MARK: - Init

    public init(
        webhookUrl: String,
        eventsUrl: String? = nil,
        method: CallbackMethod = .post,
        errorMethod: CallbackMethod = .post,
        extraHttpHeaders: [String: String]? = nil
    ) {
        self.webhookUrl = webhookUrl
        self.eventsUrl = eventsUrl
        self.method = method
        self.errorMethod = errorMethod
        self.extraHttpHeaders = extraHttpHeaders
    }

    // MARK: - Header generation

    /// Converts this configuration to the HTTP headers dictionary expected by Gotenberg.
    ///
    /// Pass the result as `clientHTTPHeaders` on any GotenbergKit conversion method:
    /// ```swift
    /// let headers = WebhookConfiguration(webhookUrl: "...").asHeaders()
    /// let _ = try await gotenberg.convert(html: data, clientHTTPHeaders: headers)
    /// ```
    public func asHeaders() -> [String: String] {
        var headers: [String: String] = [:]

        headers["Gotenberg-Webhook-Url"] = webhookUrl
        headers["Gotenberg-Webhook-Method"] = method.rawValue
        headers["Gotenberg-Webhook-Error-Method"] = errorMethod.rawValue

        // If eventsUrl is set, use it. If only errorUrl was set (deprecated),
        // promote it to eventsUrl — Gotenberg replaced the separate error URL
        // with the unified Events-Url mechanism.
        let effectiveEventsUrl = eventsUrl ?? _errorUrl
        if let url = effectiveEventsUrl {
            headers["Gotenberg-Webhook-Events-Url"] = url
        }

        if let extra = extraHttpHeaders, !extra.isEmpty {
            if let data = try? JSONEncoder().encode(extra),
                let json = String(data: data, encoding: .utf8)
            {
                headers["Gotenberg-Webhook-Extra-Http-Headers"] = json
            }
        }

        return headers
    }
}
