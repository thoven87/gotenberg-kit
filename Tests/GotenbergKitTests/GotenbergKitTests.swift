import AsyncHTTPClient
import Foundation
import Logging
import Testing

@testable import GotenbergKit

@Suite("GotenbergKit")
struct GokenbergKitTests {

    let serverURL = ProcessInfo.processInfo.environment["FILE_SERVER_URL"] ?? "http://host.docker.internal:8081"

    let client = GotenbergClient(
        baseURL: URL(string: ProcessInfo.processInfo.environment["GOTENBERG_URL"] ?? "http://localhost:7100")!,
        username: "gotenberg",
        password: "password"
    )

    let logger = Logger(label: "GotenbergKitTests")

    private var baseOutputPath: String {
        let subpath = "/tmp"

        return subpath
    }

    @Test
    func testSimpleHTMLToPDF() async throws {
        // Example 1: Basic HTML conversion
        let htmlContent = """
            <!DOCTYPE html>
            <html>
            <head>
                <meta charset="UTF-8">
                <title>Simple HTML Document</title>
                <style>
                    body { font-family: Arial, sans-serif; margin: 40px; }
                    h1 { color: #2c3e50; }
                    .content { padding: 20px; border: 1px solid #eee; }
                </style>
            </head>
            <body>
                <h1>Hello, from Gotenberg Swift Client!</h1>
                <div class="content">
                    <p>This is a simple HTML document that will be converted to PDF.</p>
                    <p>The current date is: <strong>\(Date())</strong></p>
                </div>
            </body>
            </html>
            """

        let result = try await client.convert(
            html: htmlContent.data(using: .utf8)!
        )
        #expect(result.status.code == 200)
        try await client.writeToFile(result, at: "\(baseOutputPath)/simple.pdf")
    }

    @Test
    func testHTMLWithAssets() async throws {
        let htmlWithAssets = """
            <!DOCTYPE html>
            <html>
            <head>
                <meta charset="UTF-8">
                <title>Document with Assets</title>
                <link rel="stylesheet" href="styles.css">
            </head>
            <body>
                <div class="container">
                    <h1>Document with External Assets</h1>
                    <img src="logo.png" alt="Logo" class="logo">
                    <div class="content">
                        <p>This document includes CSS and image assets.</p>
                    </div>
                </div>
                <script src="script.js"></script>
            </body>
            </html>
            """

        let cssContent = """
            body { 
                font-family: 'Helvetica', sans-serif; 
                margin: 0;
                padding: 20px;
                color: #333;
            }
            .container {
                max-width: 800px;
                margin: 0 auto;
                padding: 20px;
                border: 1px solid #ccc;
                border-radius: 5px;
            }
            h1 { color: #2c3e50; text-align: center; }
            .logo { 
                display: block;
                max-width: 200px;
                margin: 20px auto;
            }
            .content {
                padding: 20px;
                background-color: #f9f9f9;
                border-radius: 5px;
            }
            """

        let jsContent = """
            console.log('PDF generated at: ' + new Date().toString());
            """

        // Load image data from a file
        let logoData = try await HTTPClient.shared.get(url: "https://logolab.app/assets/logo.png").get()

        guard let logoData = logoData.body else {
            #expect(Bool(false))
            return
        }

        // Prepare assets
        let assets: [String: Data] = [
            "styles.css": cssContent.data(using: .utf8)!,
            "script.js": jsContent.data(using: .utf8)!,
            "logo.png": Data(buffer: logoData),
        ]

        let htmlData = htmlWithAssets.data(using: .utf8)!

        let pdfWithAssets = try await client.convert(
            html: htmlData,
            header: "<div style='text-align: center; font-size: 10px;'>Generated with Gotenberg</div>".data(using: .utf8)!,
            footer:
                "<div style='text-align: center; font-size: 10px;'>Page <span class='pageNumber'></span> of <span class='totalPages'></span></div>"
                .data(using: .utf8)!,
            assets: assets,
            options: ChromiumOptions(
                paperWidth: 8.5,
                paperHeight: 11,
                marginTop: 1.0,
                marginBottom: 1.0,
                marginLeft: 1.0,
                marginRight: 1.0,
                printBackground: true
            )
        )

        #expect(pdfWithAssets.status == .ok)
        logger.info("Successfully converted HTML with assets to PDF")
    }

    @Test
    func urlToPDF() async throws {

        let pdfData = try await client.convert(
            url: URL(string: "https://developer.apple.com/swift")!,
            options: ChromiumOptions(
                paperWidth: 11.0,
                paperHeight: 8.5,  // Landscape size
                marginTop: 0.39,
                marginBottom: 0.39,
                marginLeft: 0.39,
                marginRight: 0.39,
                printBackground: true,
                landscape: true,
                scale: 1.0,
                waitDelay: 2,  // Wait for page to fully load
                userAgent: "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36",
                extraHttpHeaders: [
                    "Accept-Language": "en-US",
                    "Cache-Control": "no-cache",
                ]
            )
        )

        #expect(pdfData.status == .ok)
    }

    @Test
    func markdownToPDF() async throws {

        let htmlContent = """
            <!DOCTYPE html>
            <html>
            <head>
                <meta charset="UTF-8">
                <title>Document with Assets</title>
                <link rel="stylesheet" href="styles.css">
            </head>
            <body>
                <div class="container">
                    <h1>Document with External Assets</h1>
                    <img src="logo.png" alt="Logo" class="logo">
                    <div class="content">
                        <p>This document includes CSS and image assets.</p>
                    </div>
                </div>
                <script src="script.js"></script>
            </body>
            </html>
            """

        // Markdown content
        let markdownContent = """
            # Markdown to PDF Example

            This is an example of converting **Markdown** to PDF using Gotenberg.

            ## Features

            - Supports *all* standard Markdown syntax
            - Can include custom CSS
            - Handles images and other assets

            ```swift
            func helloWorld() {
                print("Hello, Gotenberg!")
            }
            ```

            > Note: This is rendered using Chromium's built-in Markdown renderer.

            ![Logo](logo.png)
            """

        // Custom CSS for Markdown rendering
        let customCSS = """
            body {
                font-family: 'Helvetica', sans-serif;
                line-height: 1.6;
                max-width: 800px;
                margin: 0 auto;
                padding: 20px;
            }

            h1, h2, h3 {
                color: #2c3e50;
            }

            code {
                background-color: #f5f5f5;
                padding: 2px 4px;
                border-radius: 3px;
            }

            pre {
                background-color: #f5f5f5;
                padding: 10px;
                border-radius: 5px;
                overflow-x: auto;
            }

            blockquote {
                border-left: 4px solid #ccc;
                padding-left: 15px;
                color: #666;
            }

            img {
                max-width: 100%;
            }
            """

        // Load logo image
        let url = Bundle.module.url(forResource: "test-logo", withExtension: "png", subdirectory: "Resources/images")!
        let logoData = try Data(contentsOf: url)

        // Prepare files
        let markdownFiles = [
            "index.html": htmlContent.data(using: .utf8)!,
            "document.md": markdownContent.data(using: .utf8)!,
        ]

        let assets = [
            "custom.css": customCSS.data(using: .utf8)!,
            "logo.png": logoData,
        ]

        // Convert to PDF
        let pdfData = try await client.convertMarkdown(
            files: markdownFiles,
            assets: assets,
            options: ChromiumOptions(
                paperWidth: 8.5,
                paperHeight: 11,
                marginTop: 1.0,
                marginBottom: 1.0,
                marginLeft: 1.0,
                marginRight: 1.0,
                printBackground: true
            )
        )

        #expect(pdfData.status == .ok)
    }

    @Test
    func batchProcessingURLToPDF() async throws {
        let urls = [
            "https://github.com",
            "https://developer.apple.com",
            "https://swift.org",
        ].map { URL(string: $0)! }

        typealias Response = [URL: GotenbergClient.GotenbergResponse]

        // Use a task group for parallel processing
        let response = try await withThrowingTaskGroup(of: (URL, GotenbergClient.GotenbergResponse).self) { group -> Response in
            for url in urls {
                group.addTask {
                    let pdfData = try await client.convert(
                        url: url,
                        options: ChromiumOptions(
                            printBackground: true,
                            waitDelay: 1
                        )
                    )
                    return (url, pdfData)
                }
            }

            var result: Response = [:]
            for try await (url, pdfData) in group {
                result[url] = pdfData
            }
            return result
        }

        #expect(response.count == urls.count)

        logger.info("All batch conversions completed")
    }

    @Test
    func batchProcessingURLToPNG() async throws {
        let urls = [
            "https://github.com",
            "https://developer.apple.com",
            "https://swift.org",
        ].map { URL(string: $0)! }

        let result = try await client.capture(
            urls: urls,
            options: ScreenshotOptions(
                format: .jpeg,
                width: 1920,
                height: 1080
            )
        )
        #expect(result.isEmpty == false)
    }
}
