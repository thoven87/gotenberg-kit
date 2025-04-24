# GotenbergKit

<p align="center">
    <a href="https://swift.org">
        <img src="https://img.shields.io/badge/swift-6.0-f05138.svg"/>
    </a>
    <a href="https://github.com/thoven87/gotenberg-kit/actions?query=workflow%3ACI">
        <img src="https://github.com/thoven87/gotenberg-kit/actions/workflows/ci.yml/badge.svg?branch=main"/>
    </a>
</p>

A Swift library that interacts with [Gotenberg](https://gotenberg.dev/)'s different modules to convert a variety of document formats to PDF files.

# Table of Contents

1. [Getting Started](#getting-started)
   - [Installation](#snippets)
   - [Prerequisites](#prerequisites)
   - [Configuration](#configuration)
2. [Authentication](#authentication)
   - [Basic Authentication](#basic-authentication)
   - [Advanced Authentication](#advanced-authentication)
3. [Core Features](#core-features)
   - [Chromium](#chromium)
     - [URL](#url)
     - [HTML](#html)
     - [Markdown](#markdown)
     - [Screenshot](#screenshot)
   - [LibreOffice](#libreoffice)
   - [PDF Engines](#pdf-engines)
     - [Format Conversion](#format-conversion)
     - [Merging](#merging)
     - [Metadata Management](#metadata-management)
     - [File Generation](#file-generation)
   - [PDF Splitting](#pdf-splitting)
4. [Usage Example](#snippet)

## Getting Started

## Snippets
To incorporate `gotenberg-kit` into your project, follow the snippets below for SPM dependencies.

### SPM
```swift
.package(url: "https://github.com/thoven87/gotenberg-kit.git", from: "0.1.0")

.target(name: "MyApp", dependencies: [.product(name: "GotenbergKit", package: "gotenberg-kit")]),
```

## Prerequisites

Before attempting to use `GotenbergKit`, be sure you install [Docker](https://www.docker.com/) if you have not already done so.

Once the docker Daemon is up and running, you can start a default Docker container of [Gotenberg](https://gotenberg.dev/) as follows:

```bash
docker run --rm -p 7100:7100 gotenberg/gotenberg:8 gotenberg --api-port=7100
```

## Configuration

Create an instance of `Gotenberg` class and pass your `Gotenberg` `endpoint` url as a constructor parameter.

```swift
let client = GotenbergClient(
    baseURL: URL(string: ProcessInfo.processInfo.environment["GOTENBERG_URL"] ?? "http://localhost:7100")!
)
```

## Authentication

### Basic Authentication

Gotenberg introduces basic authentication support starting from version [8.4.0](https://github.com/gotenberg/gotenberg/releases/tag/v8.4.0). Suppose you are running a Docker container using the command below:

```bash
docker run --rm -p 3000:3000 \
-e GOTENBERG_API_BASIC_AUTH_USERNAME=gotenberg \
-e GOTENBERG_API_BASIC_AUTH_PASSWORD=password \
gotenberg/gotenberg:8.4.0 gotenberg --api-enable-basic-auth

```

To integrate this setup with Chromiumly, you need to update your client instance as outlined below:


```Swift
let client = GotenbergClient(
    baseURL: URL(
        string: ProcessInfo.processInfo.environment["GOTENBERG_URL"] ?? "http://localhost:7100"
    )!,
    username: "gotenberg",
    password: "password"
)
```

### Advanced Authentication

To implement advanced authentication or add custom HTTP headers to your requests, you can use the `customHttpHeaders` option during initialization or for every function call. This allows you to pass additional headers, such as authentication tokens or custom metadata, with each API call.

For example, you can include a Bearer token for authentication along with a custom header as follows:

```swift
let token = try await generateToken();

let client = GotenbergClient(
    baseURL: URL(
        string: ProcessInfo.processInfo.environment["GOTENBERG_URL"] ?? "http://localhost:7100"
    )!,
    customHttpHeaders: [
        "Authorization": "Bearer \(token)",
        "X-Custom-Header": "value",
    ]
)

```

## Core Features

GotenbergKit exposes different funcs that serve as wrappers to
Gotenberg's [routes](https://gotenberg.dev/docs/routes)

### Chromium

`GotenbergKit` client comes with a `convertUrl`, `convertHtml` and `convertMarkdown` functions that call one of Chromium's [routes](https://gotenberg.dev/docs/modules/chromium#routes) to convert `html` and `markdown` files, or a `url` to a `GotenbergResponse` that contains the `Response` which holds the content of the converted PDF file.

`convert` expects two parameters; the first parameter represents what will be converted (i.e. `url`, `html`, or `markdown` files), and the second one is a `PageProperties` parameter.

#### URL

```swfit
let response = try await client.convertUrl("https://gotenberg.dev/")
```

```swift
let response = try await client.capture(url: URL(string: "https://gotenberg.dev/")!)
```

#### HTML

The only requirement is that one of the files name should be `index.html`.

```swift
let index = try Data(contentsOf: URL(string:"path/to/index.html"))
let header = try Data(contentsOf: URL(string:"path/to/header.html"))
let response = try await client.convertHtml(
    documents: [
        "index.html": index,
        "header.html": header
    ]
)
```

```swift
let response = try await client.capture(
    htmlString: "<html>CONTENT</html>"
)
```

#### Markdown

This route accepts an `index.html` file plus a markdown file.

```swift
let html = """
<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <title>My PDF</title>
</head>
<body>
    {{ toHTML "file.md" }}
</body>
"""
let response = try await client.convertMarkdown(
    files: [
        "index.html": html.data(using: .utf8)!,
        "file.md": "Markdown Content".data(using: .utf8)!
    ]
)

let response = try await client.capture(
    html: html.data(using: .utf8)!,
    markdown: "Markdown Content".data(using: .utf8)!
)
```

Each `convert()` method takes an optional `properties` parameter of the following type which dictates how the PDF generated
file will look like.

```swift
PageProperties
```

In addition to the `PageProperties` customization options, the `convert()` method also accepts a set of parameters to further enhance the versatility of the conversion process.

#### Screenshot
Similarly, the `capture()` function takes an optional `properties` parameter of the specified type, influencing the appearance of the captured screenshot file.

```swift
ScreenshotOptions
```

### LibreOffice

The `LibreOffice` utility comes with a function called `convertWithLibreOffice`. This function interacts with [LibreOffice](https://gotenberg.dev/docs/routes#convert-with-libreoffice) route to convert different documents to PDF files. You can find the file extensions
accepted [here](https://gotenberg.dev/docs/routes#convert-with-libreoffice).

```swift
let response = try await client.convertWithLibreOffice(
    urls: [
        .init(url: "https://someurl.com/myfile.csv"),
        .init(url: "https://someurl.com/myfile.odt"),
        .init(url: "https://someurl.com/myfile.doc"),
        .init(url: "https://someurl.com/myfile.pdf")
    ],
)
```

Similarly to Chromium's route `convert` function, this function takes the following optional parameters :

```swift
LibreOfficeConversionOptions
```

Note: not setting merge to true will return a zip file containing all PDF files

### PDF Engines

The `PDFEngines` funcs interacts with Gotenberg's [PDF Engines](https://gotenberg.dev/docs/routes#convert-into-pdfa--pdfua-route) routes to manipulate PDF files.

#### Format Conversion

This function interacts with [PDF Engines](https://gotenberg.dev/docs/routes#convert-into-pdfa--pdfua-route) convertion route to transform PDF files into the requested PDF/A format and/or PDF/UA.

```swift
let response = try await client.convertWithPDFEngines(
    documents: [
        "file_1.pdf": Data,
        "file_2.pdf": Data
    ],
    options: PDFEngineOptions(
        pdfua: true,
        format: .A1B
    )
)

let response = try await client.convertWithPDFEngines(
    urls: [
       .init(url: "https://someurl.com/myfile.pdf")
    ],
    options: PDFEngineOptions(
        pdfua: true,
        format: .A1B
    )
)
```

#### Merging

These functions interact with [PDF Engines](https://gotenberg.dev/docs/routes#merge-pdfs-route) merge route which gathers different
engines that can manipulate and merge PDF files such
as: [PDFtk](https://gitlab.com/pdftk-java/pdftk), [PDFcpu](https://github.com/pdfcpu/pdfcpu), [QPDF](https://github.com/qpdf/qpdf),
and [UNO](https://github.com/unoconv/unoconv).

```swift
let response = try await client.mergeWithPDFEngines(
    documents: [
        "file_1.pdf": Data,
        "file_2.pdf": Data
    ],
    options: PDFEngineOptions(
        pdfua: true,
        format: .A1B
    )
)

let response = try await client.mergeWithPDFEngines(
    urls: [
       .init(url: "https://someurl.com/myfile.pdf")
    ],
    options: PDFEngineOptions(
        pdfua: true,
        format: .A1B
    )
)
```

#### Metadata Management

##### readMetadata

This function reads metadata from the provided PDF files.

```swift
let response = try await client.readPDFMetadata(
    urls: [
       .init(url: "https://someurl.com/myfile.pdf")
    ],
)

let response = try await client.readPDFMetadata(
    documents: [
        "file_1.pdf": Data,
        "file_2.pdf": Data
    ]
)
```

##### writeMetadata

This function writes metadata to the provided PDF files.

```swift
let response = try await client.writePDFMetadata(
    urls: [
       .init(url: "https://someurl.com/myfile.pdf")
    ],
    metadata: [
        "Author": "Stevenson Michel",
        "Title": "GotenbergKit"
        "Keywords": ["pdf"', "gotenberg", "swift"]
    ]
)
```

Referr to [ExifTool](https://exiftool.org/TagNames/XMP.html#pdf) for a comprehensive list of accessible metadata options.

### PDF Splitting

Each [Chromium](#chromium) and [LibreOffice](#libreoffice) route has a `split` parameter that allows splitting a PDF file into multiple files. The `split` parameter is an object with the following properties:

- `mode`: the mode of the split. It can be `pages` or `intervals`.
- `span`: the span of the split. It is a string that represents the range of pages to split.
- `unify`: a boolean that allows unifying the split files. Only works when `mode` is `pages`.
- `flatten`: a boolean that, when set to true, flattens the split PDF files, making form fields and annotations uneditable.

```swift
let response = try await client.convertUrl(
    url: URL(string: "https://gotenberg.dev")!,
    options: ChromiumOptions(
        mode: .pages,
        span: "1-2",
        unify: true,
    ),
)
```

On the other hand, PDFEngines' has a `split` function that interacts with [PDF Engines](https://gotenberg.dev/docs/routes#split-pdfs-route) split route which splits PDF files into multiple files.

```swift
let response = try await client.splitPDF(
    urls: [
       .init(url: "https://someurl.com/myfile.pdf")
    ],
    options: SplitPDFOptions(
        splitMode: .pages,
        splitSpan: "1-2",
        splitUnify: true,
    ),
)
```

> ⚠️ **Note**: Gotenberg does not currently validate the `span` value when `mode` is set to `pages`, as the validation depends on the chosen engine for the split feature. See [PDF Engines module configuration](https://gotenberg.dev/docs/configuration#pdf-engines) for more details.

### PDF Flattening

PDF flattening converts interactive elements like forms and annotations into a static PDF. This ensures the document looks the same everywhere and prevents further edits.

```swift

let response = try await client.flattenPDF(
    urls: [
       .init(url: "https://someurl.com/myfile.pdf")
    ]
)
```

#### File Generation

It is just a complementary function that takes the `GotenbergResponse` returned by any functions beside readPDFMetadata, and a
chosen `filepath` with name to generate a PDF file or zip file. Note that note that this function will not create sub directories if not already exist.
