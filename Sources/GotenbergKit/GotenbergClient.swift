// The Swift Programming Language
// https://docs.swift.org/swift-book

import AsyncHTTPClient
import Logging
import NIO
import NIOFoundationCompat

import struct Foundation.Data
import struct Foundation.TimeInterval
import struct Foundation.URL
import struct Foundation.UUID

/// A comprehensive Swift client for interacting with Gotenberg API
public struct GotenbergClient: Sendable {
    internal let httpClient: HTTPClient
    internal let baseURL: URL
    internal let logger: Logger
    internal let username: String?
    internal let password: String?
    internal let userAgent: String
    internal let customHttpHeaders: [String: String]
    private let maxRetries: Int

    public typealias GotenbergResponse = HTTPClientResponse

    /// Initialize the Gotenberg client
    /// - Parameters:
    ///   - baseURL: Base URL of the Gotenberg service (e.g., "http://localhost:3000")
    ///   - logger: Optional logger
    ///   - username: Optional username for the Gotenberg server
    ///   - password: Optional password for the Gotenberg server
    ///   - userAgent: Optional userAgent for all HTTP calls to the Gotenberg server
    ///   - httpClient: HTTClient
    public init(
        baseURL: URL,
        logger: Logger = Logger(label: "com.gotenberg.swift"),
        username: String? = nil,
        password: String? = nil,
        userAgent: String = "Gotenberg Swift SDK/1.0",
        httpClient: HTTPClient = HTTPClient.shared,
        maxRetries: Int = 3
    ) {
        self.baseURL = baseURL
        self.logger = logger
        self.username = username
        self.password = password
        self.userAgent = userAgent
        self.httpClient = httpClient
        self.customHttpHeaders = [:]
        self.maxRetries = maxRetries
    }

    /// Initialize the Gotenberg client
    /// - Parameters:
    ///   - baseURL: Base URL of the Gotenberg service (e.g., "http://localhost:3000")
    ///   - logger: Optional logger
    ///   - username: Optional username for the Gotenberg server
    ///   - password: Optional password for the Gotenberg server
    ///   - userAgent: Optional userAgent for all HTTP calls to the Gotenberg server
    ///   - customHttpHeaders: For advanced authentication or add custom HTTP headers to requests to the Gotenberg server
    ///   - httpClient: HTTClient
    ///   - maxRetries: Max retry count
    public init(
        baseURL: URL,
        logger: Logger = Logger(label: "com.gotenberg.swift"),
        username: String? = nil,
        password: String? = nil,
        userAgent: String = "Gotenberg Swift SDK/1.0",
        customHttpHeaders: [String: String],
        httpClient: HTTPClient = HTTPClient.shared,
        maxRetries: Int = 3
    ) {
        self.baseURL = baseURL
        self.logger = logger
        self.username = username
        self.password = password
        self.userAgent = userAgent
        self.customHttpHeaders = customHttpHeaders
        self.httpClient = httpClient
        self.maxRetries = maxRetries
    }

    /// Sends a form request to Gotenberg with files and values
    /// - Parameters:
    ///   - route: The API route to send the request to
    ///   - files: Array of files to include in the request
    ///   - values: Dictionary of form values to include
    ///   - headers: Additional HTTP headers to include
    /// - Returns: GotenbergResponse
    internal func sendFormRequest(
        route: String,
        files: [FormFile],
        values: [String: String],
        headers: [String: String],
    ) async throws -> GotenbergResponse {
        try await makeRequest(route: route, files: files, values: values, headers: headers)
    }

    /// Sends a form request to Gotenberg with files and values
    /// - Parameters:
    ///   - route: The API route to send the request to
    ///   - files: Array of files to include in the request
    ///   - values: Dictionary of form values to include
    ///   - headers: Additional HTTP headers to include
    ///   - currentRetryCount: Current retry count
    /// - Returns: GotenbergResponse
    private func makeRequest(
        route: String,
        files: [FormFile],
        values: [String: String],
        headers: [String: String],
        currentRetryCount: Int = 0
    ) async throws -> GotenbergResponse {
        // Create multipart form data
        let boundary = "------------------------\(UUID().uuidString)"
        var body = Data()

        // Add form values
        for (name, value) in values {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(name)\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(value)\r\n".data(using: .utf8)!)
        }

        // Add files
        for file in files {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(file.name)\"; filename=\"\(file.filename)\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: \(file.contentType)\r\n\r\n".data(using: .utf8)!)
            body.append(file.data)
            body.append("\r\n".data(using: .utf8)!)
        }

        // Add final boundary
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)

        // Create the request
        let endpoint = baseURL.appendingPathComponent(route)
        var request = HTTPClientRequest(url: endpoint.absoluteString)
        request.method = .POST
        request.headers.add(name: "Content-Type", value: "multipart/form-data; boundary=\(boundary)")
        request.headers.add(name: "Content-Length", value: "\(body.count)")
        request.headers.add(name: "User-Agent", value: userAgent)

        if let username = username, let password = password {
            logger.debug("Using basic auth for Gotenberg API")
            request.setBasicAuth(username: username, password: password)
        }

        // Add additional headers
        for (name, value) in headers {
            request.headers.add(name: name, value: value)
        }

        // custom http headers
        for (key, value) in customHttpHeaders {
            request.headers.add(name: key, value: value)
        }

        // Set the request body
        request.body = .bytes(ByteBuffer(data: body))

        logger.debug("Sending request to Gotenberg: \(endpoint.absoluteString)")

        // Execute the request
        let timeout = Int64(headers["Gotenberg-Wait-Timeout"] ?? "60") ?? 60
        let response = try await httpClient.execute(
            request,
            deadline: .now() + .seconds(timeout)
        )

        switch response.status {
        case .gatewayTimeout, .tooManyRequests, .serviceUnavailable, .requestTimeout, .internalServerError:
            let retryCount = currentRetryCount + 1
            if retryCount < maxRetries {
                let delayTime = min(exp2(Double(retryCount)), 30)
                let jitter = Double.random(in: 0.1...0.5)
                let delay = delayTime * (1 + jitter)
                logger.debug("Gotenberg API returned \(response.status), retrying in \(delay) seconds with attempt count... \(retryCount)")
                try await Task.sleep(for: .seconds(delay))
                return try await makeRequest(
                    route: route,
                    files: files,
                    values: values,
                    headers: headers,
                    currentRetryCount: retryCount
                )
            }

            throw GotenbergError.apiError(statusCode: response.status.code, message: "Exhausted retry attempts")
        case .ok:
            return response
        default: break
        }

        // Validate the response status
        guard response.status == .ok else {
            var errorData = Data()
            for try await buffer in response.body {
                errorData.append(Data(buffer.readableBytesView))
            }

            if let errorMessage = String(data: errorData, encoding: .utf8) {
                logger.error(
                    "Gotenberg API error with status",
                    metadata: [
                        "statusCode": "\(response.status.code)",
                        "message": .string(errorMessage),
                    ]
                )
                throw GotenbergError.apiError(statusCode: response.status.code, message: errorMessage)
            } else {
                logger.error(
                    "Gotenberg API error",
                    metadata: [
                        "statusCode": "\(response.status.code)",
                        "message": "Unknown error",
                    ]
                )
                throw GotenbergError.apiError(statusCode: response.status.code, message: "Unknown error")
            }
        }

        return response
    }

    /// Conver an HTTPClientResponse into data
    /// - Parameters:
    ///   - response: The API response
    /// - Returns: Response data
    internal func toData(_ response: GotenbergResponse) async throws -> Data {
        // Collect response data
        logger.debug("Collecting response data from Gotenberg")
        var responseData = Data()
        for try await buffer in response.body {
            responseData.append(Data(buffer.readableBytesView))
        }

        logger.debug("Gotenberg request completed successfully, received \(responseData.count) bytes")
        return responseData
    }

    /// Write a Gotenberg Response to a path
    /// - Parameters:
    ///   - response: The API response
    public func writeToFile(_ response: GotenbergResponse, at path: String, options: Data.WritingOptions = []) async throws {
        try await toData(response).write(
            to: URL(fileURLWithPath: path),
            options: options
        )
    }

    /// Determines the content type based on the filename extension
    /// - Parameter filename: The filename to check
    /// - Returns: The appropriate content type string
    internal func contentTypeForFilename(_ filename: String) -> String {
        let ext = URL(fileURLWithPath: filename).pathExtension.lowercased()

        switch ext {
        case "html", "htm":
            return "text/html"
        case "css":
            return "text/css"
        case "js":
            return "application/javascript"
        case "jpg", "jpeg":
            return "image/jpeg"
        case "png":
            return "image/png"
        case "gif":
            return "image/gif"
        case "svg":
            return "image/svg+xml"
        case "pdf":
            return "application/pdf"
        case "doc":
            return "application/msword"
        case "docx":
            return "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
        case "xls":
            return "application/vnd.ms-excel"
        case "xlsx":
            return "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
        case "ppt":
            return "application/vnd.ms-powerpoint"
        case "pptx":
            return "application/vnd.openxmlformats-officedocument.presentationml.presentation"
        case "md":
            return "text/markdown"
        case "ttf":
            return "font/ttf"
        case "otf":
            return "font/otf"
        case "woff":
            return "font/woff"
        case "woff2":
            return "font/woff2"
        case "odt":
            return "application/vnd.oasis.opendocument.text"
        case "ods":
            return "application/vnd.oasis.opendocument.spreadsheet"
        case "odp":
            return "application/vnd.oasis.opendocument.presentation"
        case "rtf":
            return "application/rtf"
        case "txt":
            return "text/plain"
        case "csv":
            return "text/csv"
        default:
            return "application/octet-stream"
        }
    }

    private static let libreOfficeSupportedFormats: Set<String> = [
        "123",
        "602",
        "abw",
        "bib",
        "bmp",
        "cdr",
        "cgm",
        "cmx",
        "csv",
        "cwk",
        "dbf",
        "dif",
        "doc",
        "docm",
        "docx",
        "dot",
        "dotm",
        "dotx",
        "dxf",
        "emf",
        "eps",
        "epub",
        "fodg",
        "fodp",
        "fods",
        "fodt",
        "fopd",
        "gif",
        "htm",
        "html",
        "hwp",
        "jpeg",
        "jpg",
        "key",
        "ltx",
        "lwp",
        "mcw",
        "met",
        "mml",
        "mw",
        "numbers",
        "odd",
        "odg",
        "odm",
        "odp",
        "ods",
        "odt",
        "otg",
        "oth",
        "otp",
        "ots",
        "ott",
        "pages",
        "pbm",
        "pcd",
        "pct",
        "pcx",
        "pdb",
        "pdf",
        "pgm",
        "png",
        "pot",
        "potm",
        "potx",
        "ppm",
        "pps",
        "ppt",
        "pptm",
        "pptx",
        "psd",
        "psw",
        "pub",
        "pwp",
        "pxl",
        "ras",
        "rtf",
        "sda",
        "sdc",
        "sdd",
        "sdp",
        "sdw",
        "sgl",
        "slk",
        "smf",
        "stc",
        "std",
        "sti",
        "stw",
        "svg",
        "svm",
        "swf",
        "sxc",
        "sxd",
        "sxg",
        "sxi",
        "sxm",
        "sxw",
        "tga",
        "tif",
        "tiff",
        "txt",
        "uof",
        "uop",
        "uos",
        "uot",
        "vdx",
        "vor",
        "vsd",
        "vsdm",
        "vsdx",
        "wb2",
        "wk1",
        "wks",
        "wmf",
        "wpd",
        "wpg",
        "wps",
        "xbm",
        "xhtml",
        "xls",
        "xlsb",
        "xlsm",
        "xlsx",
        "xlt",
        "xltm",
        "xltx",
        "xlw",
        "xml",
        "xpm",
        "zabw",
    ]

    internal static func isLibreOfficeSupportedFormat(_ format: String) -> Bool {
        guard let url = URL(string: format) else {
            return false
        }

        let ext = url.pathExtension

        return libreOfficeSupportedFormats.contains(ext.lowercased())
    }

    internal static func isFileSupportedFromContentType(_ contentType: String) -> Bool {
        let ext = contentType.components(separatedBy: "/").last ?? ""

        return libreOfficeSupportedFormats.contains(ext.lowercased())
    }

    public static func isFileSupported(_ contentTypeOrPath: String) -> Bool {
        isLibreOfficeSupportedFormat(contentTypeOrPath) || isFileSupportedFromContentType(contentTypeOrPath)
    }
}
