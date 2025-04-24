//
//  FormFile.swift
//  gotenberg-kit
//
//  Created by Stevenson Michel on 4/12/25.
//

import struct Foundation.Data

// MARK: - Helpers FormFile

/// Structure representing a file in a multipart form
internal struct FormFile {
    let name: String
    let filename: String
    let contentType: String
    let data: Data
}
