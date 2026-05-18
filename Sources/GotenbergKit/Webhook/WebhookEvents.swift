//
//  WebhookEvents.swift
//  gotenberg-kit
//
//  Decodable models for the structured JSON events sent to
//  WebhookConfiguration.eventsUrl after each webhook operation.
//

import Foundation

// MARK: - Event envelope

/// The event type discriminator sent in every webhook event payload.
public enum WebhookEventType: String, Codable, Sendable {
    case success = "webhook.success"
    case error = "webhook.error"
}

// MARK: - Success event

/// Structured JSON event posted to `Gotenberg-Webhook-Events-Url` on success.
///
/// ```json
/// {
///   "event":         "webhook.success",
///   "correlationId": "unique-request-id",
///   "timestamp":     "2025-01-15T10:30:00.000000000Z"
/// }
/// ```
public struct WebhookSuccessEvent: Codable, Sendable {
    public let event: WebhookEventType
    public let correlationId: String
    public let timestamp: String  // ISO 8601 nanosecond precision

    public init(event: WebhookEventType, correlationId: String, timestamp: String) {
        self.event = event
        self.correlationId = correlationId
        self.timestamp = timestamp
    }
}

// MARK: - Error event

/// Structured JSON event posted to `Gotenberg-Webhook-Events-Url` on failure.
///
/// ```json
/// {
///   "event":         "webhook.error",
///   "correlationId": "unique-request-id",
///   "timestamp":     "2025-01-15T10:30:00.000000000Z",
///   "error": {
///     "status":  500,
///     "message": "conversion failed"
///   }
/// }
/// ```
public struct WebhookErrorEvent: Codable, Sendable {

    /// The error detail nested inside a `webhook.error` event.
    public struct ErrorDetail: Codable, Sendable {
        /// HTTP status code from the conversion attempt.
        public let status: Int
        /// Human-readable error description.
        public let message: String
    }

    public let event: WebhookEventType
    public let correlationId: String
    public let timestamp: String
    public let error: ErrorDetail

    public init(
        event: WebhookEventType,
        correlationId: String,
        timestamp: String,
        error: ErrorDetail
    ) {
        self.event = event
        self.correlationId = correlationId
        self.timestamp = timestamp
        self.error = error
    }
}
