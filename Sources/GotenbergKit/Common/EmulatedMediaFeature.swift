//
//  EmulatedMediaFeature.swift
//  gotenberg-kit
//
//  Used by Chromium routes to override CSS media features
//  via the `emulatedMediaFeatures` form field.
//
//  Common name/value pairs:
//    ("prefers-color-scheme", "dark" | "light")
//    ("prefers-reduced-motion", "reduce" | "no-preference")
//    ("forced-colors", "active" | "none")
//    ("color-gamut", "srgb" | "p3" | "rec2020")
//

import Foundation

/// A single CSS media feature override for Chromium's `emulatedMediaFeatures` field.
public struct EmulatedMediaFeature: Codable, Sendable {
    /// The CSS media feature name, e.g. `"prefers-color-scheme"`.
    public var name: String
    /// The value to force, e.g. `"dark"`.
    public var value: String

    public init(name: String, value: String) {
        self.name = name
        self.value = value
    }

    // MARK: - Common presets

    /// Force dark color scheme (`prefers-color-scheme: dark`).
    public static let darkMode = EmulatedMediaFeature(name: "prefers-color-scheme", value: "dark")
    /// Force light color scheme (`prefers-color-scheme: light`).
    public static let lightMode = EmulatedMediaFeature(name: "prefers-color-scheme", value: "light")
    /// Emulate reduced-motion preference.
    public static let reduceMotion = EmulatedMediaFeature(name: "prefers-reduced-motion", value: "reduce")
    /// Emulate High Contrast mode.
    public static let forcedColors = EmulatedMediaFeature(name: "forced-colors", value: "active")
}
