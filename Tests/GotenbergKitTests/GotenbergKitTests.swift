
import Foundation
import Logging
import Testing

@testable import GotenbergKit

@Suite("GotenbergKit")
struct GokenbergKitTests {

    let serverURL = ProcessInfo.processInfo.environment["GOTENBERG_URL"] ?? "http://localhost:7100"

    let client = GotenbergClient(
        baseURL: URL(string: ProcessInfo.processInfo.environment["GOTENBERG_URL"] ?? "http://localhost:7100")!
    )

    let logger = Logger(label: "GotenbergKitTests")

    private var baseOutputPath: String {
        let subpath = "/tmp"

        return subpath
    }

    @Test
    func testSimpleHTMLTOPDF() async throws {
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

        let result = try await client.convertHtml(
            htmlContent: htmlContent.data(using: .utf8)!
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
        //let logoData = try Data(contentsOf: URL(string: "https://logolab.app/assets/logo.png")!)
        let logoURL = URL(string: "https://logolab.app/assets/logo.png")!
        let logoData = try await URLSession.shared.data(from: logoURL, delegate: nil)

        // Prepare assets
        let assets: [String: Data] = [
            "styles.css": cssContent.data(using: .utf8)!,
            "script.js": jsContent.data(using: .utf8)!,
            "logo.png": logoData.0,
        ]

        let htmlData = htmlWithAssets.data(using: .utf8)!

        let pdfWithAssets = try await client.convertHtml(
            htmlContent: htmlData,
            assets: assets,
            options: ChromiumOptions(
                paperWidth: 8.5,
                paperHeight: 11,
                marginTop: 1.0,
                marginBottom: 1.0,
                marginLeft: 1.0,
                marginRight: 1.0,
                printBackground: true,
                headerHTML: "<div style='text-align: center; font-size: 10px;'>Generated with Gotenberg</div>",
                footerHTML:
                    "<div style='text-align: center; font-size: 10px;'>Page <span class='pageNumber'></span> of <span class='totalPages'></span></div>"
            )
        )

        #expect(pdfWithAssets.status == .ok)
        logger.info("Successfully converted HTML with assets to PDF")
    }

    @Test
    func urlToPDF() async throws {

        let pdfData = try await client.convertUrl(
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
                waitDelay: 2.0,  // Wait for page to fully load
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
    func markdownToPDFExample() async {
        // MARK: - Markdown Conversion Example

        /// Example: Convert Markdown to PDF
        do {
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
                "document.md": markdownContent.data(using: .utf8)!
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

        } catch {
            print("Error converting Markdown to PDF: \(error.localizedDescription)")
        }
    }

    @Test
    func batchProcessingURLToPDF() async {
        // MARK: - Batch Processing Example
        /// Example: Process multiple conversions in parallel
        // List of URLs to convert
        let urls = [
            //"https://www.example.com",
            "https://github.com",
            "https://developer.apple.com",
            "https://swift.org",
        ].map { URL(string: $0)! }

        // Use a task group for parallel processing
        await withThrowingTaskGroup(of: (URL, GotenbergClient.GotenbergResponse).self) { group in
            for url in urls {
                let client = GotenbergClient(
                    baseURL: URL(string: serverURL)!
                )
                group.addTask {
                    let pdfData = try await client.convertUrl(
                        url: url,
                        options: ChromiumOptions(
                            printBackground: true,
                            waitDelay: 2.0
                        )
                    )
                    return (url, pdfData)
                }
            }
        }

        logger.info("All batch conversions completed")
    }

    @Test
    func batchProcessingURLToPNG() async throws {
        // MARK: - Batch Processing Example
        /// Example: Process multiple conversions in parallel
        // List of URLs to convert
        let urls = [
            //"https://www.example.com",
            "https://github.com",
            "https://developer.apple.com",
            "https://swift.org",
        ].map { URL(string: $0)! }

        let result = try await client.captureMultipleURLScreenshots(
            urls: urls,
            options: ScreenshotOptions(
                format: .jpeg,
                fullPage: true,
                width: 1920,
                height: 1080,
                //clip: true
            )
        )
        #expect(result.isEmpty == false)
    }

    @Test
    func mergePDFsFromURL() async throws {
        let pdfURLs = [
            //"https://ontheline.trincoll.edu/images/bookdown/sample-local-pdf.pdf",
            "https://www.adobe.com/support/products/enterprise/knowledgecenter/media/c4611_sample_explain.pdf",
            "https://www.cms.gov/files/document/mm13939-icd-10-other-coding-revisions-national-coverage-determinations-july-2025-update.pdf",
            // "https://unec.edu.az/application/uploads/2014/12/pdf-sample.pdf"
            //"https://pdfobject.com/pdf/sample.pdf"
        ].map { URL(string: $0)! }

        logger.info("Starting to merge \(pdfURLs.count) PDFs")

        // Option 1: Using the convenience method
        let startTime = Date()
        let mergedPDF = try await client.mergePDFsFromURLs(
            urls: pdfURLs,
            waitTimeout: 6  // Increase timeout for larger PDFs or slower connections
        )

        let duration = Date().timeIntervalSince(startTime)
        logger.info("Merged PDF size: \(mergedPDF.count) bytes, completed in \(String(format: "%.2f", duration)) seconds")

        // Save the merged PDF
        let outputPath = "\(baseOutputPath)/merged_pdfs_from_urls.pdf"
        try mergedPDF.write(to: URL(fileURLWithPath: outputPath))
        logger.info("Saved merged PDF to \(outputPath)")
    }
}
