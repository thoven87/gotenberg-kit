//
//  DownloadFrom.swift
//  gotenberg-kit
//
//  Created by Stevenson Michel on 4/23/25.
//

/// Download from
public struct DownloadFrom: Codable {
    /// URL to download a file from
    public var url: String
    /// HTTP headers for the file needed to download
    public var extraHttpHeaders: [String: String]? = nil
}
