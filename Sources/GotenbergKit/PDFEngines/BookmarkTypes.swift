//
//  BookmarkTypes.swift
//  gotenberg-kit
//
//  Types for the write-bookmarks and read-bookmarks routes.
//
//  Write: POST /forms/pdfengines/bookmarks/write
//  Read:  POST /forms/pdfengines/bookmarks/read  (returns JSON, not a PDF)
//

import Foundation

/// A single PDF bookmark (outline entry).
///
/// Can be nested: set `children` to build a hierarchical outline.
public struct PDFBookmark: Codable, Sendable {
    /// The display label for this outline entry.
    public var title: String
    /// The 1-based page number this bookmark points to.
    public var page: Int
    /// Child bookmarks nested under this entry.
    public var children: [PDFBookmark]

    public init(title: String, page: Int, children: [PDFBookmark] = []) {
        self.title = title
        self.page = page
        self.children = children
    }
}

/// The structure returned by `readBookmarks(documents:)` / `readBookmarks(urls:)`.
///
/// Keys are the uploaded filenames; values are the root-level bookmark arrays.
public typealias PDFBookmarkMap = [String: [PDFBookmark]]
