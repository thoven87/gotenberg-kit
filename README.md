# GotenbergKit

[![](https://img.shields.io/github/v/release/thoven87/gotenberg-kit?include_prereleases)](https://github.com/thoven87/gotenberg-kit/releases)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fthoven87%2Fgotenberg-kit%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/thoven87/gotenberg-kit)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fthoven87%2Fgotenberg-kit%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/thoven87/gotenberg-kit)
[![CI](https://github.com/thoven87/gotenberg-kit/actions/workflows/ci.yml/badge.svg)](https://github.com/thoven87/gotenberg-kit/actions/workflows/ci.yml)

A modern Swift SDK for [Gotenberg](https://gotenberg.dev/) that provides a type-safe, async/await interface for PDF generation and document conversion. Transform HTML, Markdown, URLs, and office documents into PDFs with intelligent retry logic and comprehensive error handling.

## Features

- 🚀 **Async/await support** with modern Swift concurrency
- 🛡️ **Type-safe APIs** with comprehensive error handling
- 🔄 **Intelligent retry logic** for transient failures
- 📄 **Multiple input formats** (HTML, Markdown, URLs, Office docs)
- 🖼️ **Screenshot capture** from web pages
- 📋 **PDF manipulation** (merge, split, metadata)
- 🔐 **PDF encryption** (during conversion + dedicated endpoint)
- 🔑 **Authentication support** (Basic Auth + custom headers)
- 📱 **Cross-platform** (iOS, macOS, Linux, Windows)

## Quick Start

### Installation

Add GotenbergKit to your Swift package:

```swift
dependencies: [
    .package(url: "https://github.com/thoven87/gotenberg-kit.git", from: "0.1.0")
]
```

### Setup Gotenberg Server

Run Gotenberg using Docker:

```bash
docker run --rm -p 3000:3000 gotenberg/gotenberg:8
```

### Basic Usage

```swift
import GotenbergKit

let client = GotenbergClient(baseURL: URL(string: "http://localhost:3000")!)

// Convert HTML to PDF
let pdfData = try await client.convertHTMLToPDF(
    htmlContent: "<h1>Hello World</h1>",
    options: ConversionOptions()
)

// Convert URL to PDF
let urlResponse = try await client.convertURLToPDF(
    url: URL(string: "https://apple.com")!,
    options: ConversionOptions()
)

// Save the PDF
try await client.writeToFile(urlResponse, at: "/path/to/output.pdf")
```

## Documentation

### HTML to PDF Conversion

Convert HTML content with optional CSS and JavaScript:

```swift
let options = ConversionOptions(
    paperWidth: 8.27,
    paperHeight: 11.7,
    marginTop: 1.0,
    marginBottom: 1.0,
    marginLeft: 1.0,
    marginRight: 1.0,
    printBackground: true,
    landscape: false,
    scale: 1.0
)

let response = try await client.convertHTMLToPDF(
    htmlContent: """
    <!DOCTYPE html>
    <html>
    <head>
        <style>body { font-family: Arial, sans-serif; }</style>
    </head>
    <body>
        <h1>Professional Document</h1>
        <p>Generated with GotenbergKit</p>
    </body>
    </html>
    """,
    options: options
)
```

### URL to PDF Conversion

Convert web pages to PDF with customizable options:

```swift
let response = try await client.convertURLToPDF(
    url: URL(string: "https://swift.org")!,
    options: ConversionOptions(
        waitDelay: 2000, // Wait 2 seconds for page load
        printBackground: true,
        scale: 0.8
    )
)
```

### Screenshot Capture

Capture screenshots of web pages:

```swift
let screenshotOptions = ScreenshotOptions(
    width: 1920,
    height: 1080,
    clip: true,
    format: .png,
    quality: 100
)

let screenshot = try await client.captureScreenshot(
    url: URL(string: "https://github.com")!,
    options: screenshotOptions
)
```

### Office Document Conversion

Convert office documents (Word, Excel, PowerPoint) to PDF:

```swift
let documents = [
    "document.docx": try Data(contentsOf: docxURL),
    "spreadsheet.xlsx": try Data(contentsOf: xlsxURL)
]

let response = try await client.convertWithLibreOffice(
    documents: documents,
    options: LibreOfficeConversionOptions(merge: true)
)
```

### PDF Manipulation

#### Merge PDFs

```swift
let response = try await client.mergeWithPDFEngines(
    documents: [
        "file1.pdf": pdfData1,
        "file2.pdf": pdfData2
    ],
    options: PDFEngineOptions()
)
```

#### Split PDFs

```swift
let response = try await client.splitPDF(
    documents: ["document.pdf": pdfData],
    options: SplitPDFOptions(
        splitMode: .pages,
        splitSpan: "1-5",
        splitUnify: false
    )
)
```

### PDF Metadata

Read and write PDF metadata:

```swift
// Read metadata
let metadata = try await client.readPDFMetadata(
    documents: ["document.pdf": pdfData]
)

// Write metadata
let response = try await client.writePDFMetadata(
    documents: ["document.pdf": pdfData],
    metadata: [
        "Title": "My Document",
        "Author": "GotenbergKit",
        "Subject": "PDF Generation",
        "Keywords": ["swift", "pdf", "gotenberg"]
    ]
)
```

### PDF Encryption

GotenbergKit provides two ways to encrypt PDFs with password protection:

#### 1. Encrypt During Conversion

Add password protection while converting documents to PDF:

```swift
// Encrypt HTML to PDF with both user and owner passwords
let options = ConversionOptions(
    userPassword: "user123",     // Password for opening/viewing the PDF
    ownerPassword: "owner456"    // Password for full access/editing
)

let response = try await client.convertHTMLToPDF(
    htmlContent: "<h1>Confidential Document</h1>",
    options: options
)

// Encrypt office documents
let libreOptions = LibreOfficeConversionOptions(
    password: "source_password",      // Password for opening source file (if encrypted)
    userPassword: "view_password",    // Password for viewing output PDF
    ownerPassword: "edit_password"    // Password for editing output PDF
)

let response = try await client.convertWithLibreOffice(
    documents: ["confidential.docx": docData],
    options: libreOptions
)

// Encrypt when processing existing PDFs
let pdfOptions = PDFEngineOptions(
    userPassword: "reader_access",
    ownerPassword: "full_access"
)

let encryptedPDF = try await client.mergeWithPDFEngines(
    documents: ["file1.pdf": data1, "file2.pdf": data2],
    options: pdfOptions
)
```

#### 2. Encrypt Existing PDFs

Use the dedicated encryption endpoint to add password protection to existing PDF files with full metadata override support:

```swift
// Basic encryption with passwords only
let encryptedResponse = try await client.encryptPDFs(
    documents: [
        "document1.pdf": try Data(contentsOf: pdf1URL),
        "document2.pdf": try Data(contentsOf: pdf2URL)
    ],
    options: PDFEngineOptions(
        userPassword: "viewer_password",
        ownerPassword: "admin_password"  // Optional
    )
)

// Encrypt with custom metadata override
let customMetadata = Metadata(
    author: "Secure Author",
    copyright: "Company Confidential",
    creator: "GotenbergKit",
    marked: true,
    producer: "Swift PDF Processor",
    subject: "Encrypted Document",
    title: "Confidential Report"
)

let encryptedWithMetadata = try await client.encryptPDFs(
    documents: ["report.pdf": reportData],
    options: PDFEngineOptions(
        metadata: customMetadata,        // Override metadata during encryption
        userPassword: "user123",
        ownerPassword: "owner456",
        flatten: true,                   // Additional PDF processing options
        pdfua: true
    )
)

// Encrypt PDFs from URLs
let pdfURLs = [
    DownloadFrom(url: "https://example.com/file1.pdf"),
    DownloadFrom(url: "https://example.com/file2.pdf")
]

let encryptedFromURLs = try await client.encryptPDFs(
    urls: pdfURLs,
    options: PDFEngineOptions(
        userPassword: "required_password"
    )
)
```

**Key Features:**
- **Password Protection**: User password (required) and owner password (optional)
- **Metadata Override**: Set custom metadata during encryption process
- **PDF Processing**: Support for flattening, PDF/UA compliance, and format options
- **Flexible Input**: Encrypt from file data or URLs
- **Consistent API**: Uses PDFEngineOptions like other PDF operations

**Password Types:**
- **User Password**: Required to open and view the PDF (required for encryption)
- **Owner Password**: Required for full access (editing, copying, printing) (optional)



### Authentication

#### Basic Authentication

```swift
let client = GotenbergClient(
    baseURL: URL(string: "http://localhost:3000")!,
    username: "gotenberg",
    password: "secret"
)
```

#### Custom Headers

```swift
let response = try await client.convertHTMLToPDF(
    htmlContent: "<h1>Authenticated Request</h1>",
    options: ConversionOptions(),
    customHeaders: [
        "Authorization": "Bearer \(token)",
        "X-Request-ID": "unique-id"
    ]
)
```

### Error Handling

GotenbergKit provides comprehensive error handling with intelligent retry logic:

```swift
do {
    let response = try await client.convertHTMLToPDF(
        htmlContent: html,
        options: options
    )
} catch GotenbergError.apiError(let statusCode, let message) {
    switch statusCode {
    case 400:
        print("Bad request: \(message)")
    case 409:
        print("Resource conflict (won't retry): \(message)")
    case 500:
        print("Server error (may have been retried): \(message)")
    default:
        print("API error \(statusCode): \(message)")
    }
} catch GotenbergError.networkError(let description) {
    print("Network error: \(description)")
} catch {
    print("Unexpected error: \(error)")
}
```

### Configuration Options

#### Retry Configuration

```swift
let client = GotenbergClient(
    baseURL: URL(string: "http://localhost:3000")!,
    maxRetries: 3, // Default: 3 retries
    logger: Logger(label: "gotenberg-client")
)
```

#### Timeout Configuration

```swift
// Per-request timeout
let response = try await client.convertHTMLToPDF(
    htmlContent: html,
    options: options,
    timeoutSeconds: 30 // 30 seconds timeout
)
```

#### Encryption Best Practices

```swift
// Use strong, unique passwords for conversion
let options = ConversionOptions(
    userPassword: generateSecurePassword(length: 12),
    ownerPassword: generateSecurePassword(length: 16)
)

// For dedicated encryption endpoint with metadata control
let encryptionOptions = PDFEngineOptions(
    metadata: Metadata(
        author: "Document Owner",
        copyright: "Confidential",
        creator: "Secure App",
        marked: true,
        subject: "Encrypted Content",
        title: "Protected Document"
    ),
    userPassword: generateSecurePassword(length: 12),
    ownerPassword: generateSecurePassword(length: 16),
    flatten: true  // Prevent form modifications
)

// User password only (allows viewing)
let viewOnlyOptions = PDFEngineOptions(
    userPassword: "view_password"
)

// Both passwords for maximum control
let secureOptions = PDFEngineOptions(
    userPassword: "user_access",    // Required to open
    ownerPassword: "admin_access"   // Full permissions
)

// Apply encryption to existing PDFs
let encrypted = try await client.encryptPDFs(
    documents: ["sensitive.pdf": pdfData],
    options: encryptionOptions
)
```

## Advanced Features

### Batch Processing

Process multiple documents concurrently:

```swift
let urls = [
    URL(string: "https://apple.com")!,
    URL(string: "https://swift.org")!,
    URL(string: "https://github.com")!
]

await withTaskGroup(of: Void.self) { group in
    for url in urls {
        group.addTask {
            do {
                let response = try await client.convertURLToPDF(
                    url: url,
                    options: ConversionOptions()
                )
                let filename = "\(url.host ?? "unknown").pdf"
                try await client.writeToFile(response, at: filename)
                print("✅ Generated: \(filename)")
            } catch {
                print("❌ Failed to convert \(url): \(error)")
            }
        }
    }
}
```

### Custom Paper Sizes

```swift
let options = ConversionOptions(
    paperWidth: 21.0,  // A4 width in cm
    paperHeight: 29.7, // A4 height in cm
    marginTop: 2.54,   // 1 inch margins
    marginBottom: 2.54,
    marginLeft: 2.54,
    marginRight: 2.54
)
```

## Requirements
- Swift 6.1+
- Gotenberg server instance

## Contributing

We welcome contributions! Please see our [Contributing Guidelines](CONTRIBUTING.md) for details.

## License

GotenbergKit is released under the MIT License. See [LICENSE](LICENSE) for details.

## Related Projects

- [Gotenberg](https://gotenberg.dev/) - The Docker-powered stateless API for PDF files
- [AsyncHTTPClient](https://github.com/swift-server/async-http-client) - HTTP client library used internally
