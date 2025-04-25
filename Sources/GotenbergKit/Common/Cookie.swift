//
//  Cookie.swift
//  gotenberg-kit
//
//  Created by Stevenson Michel on 4/11/25.
//

public struct Cookie: Codable, Sendable {
    /// Cookie name
    public var name: String
    /// Cookie value
    public var value: String
    /// Cookie domain
    public var domain: String
    /// Cookie path
    public var path: String?
    /// Set the cookie to secure if true.
    public var secure: Bool?
    /// Set the cookie as HTTP-only if true.
    public var httpOnly: Bool?
    /// Accepted values are "Strict", "Lax" or "None".
    public var sameSite: SameSite = .none

    public enum SameSite: String, Codable, Sendable {
        case none = "None"
        case strict = "Strict"
        case lax = "Lax"
    }

    public init(
        name: String,
        value: String,
        domain: String,
        path: String? = nil,
        secure: Bool? = nil,
        httpOnly: Bool? = nil
    ) {
        self.name = name
        self.value = value
        self.domain = domain
        self.path = path
        self.secure = secure
        self.httpOnly = httpOnly
    }
}
