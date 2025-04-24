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

To implement advanced authentication or add custom HTTP headers to your requests, you can use the `customHttpHeaders` option within the `configure` method. This allows you to pass additional headers, such as authentication tokens or custom metadata, with each API call.

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

`GotenbergKit` client comes with a `convertUrl`, `convertHtml` and `convertMarkdown` methods that call one of Chromium's [routes](https://gotenberg.dev/docs/modules/chromium#routes) to convert `html` and `markdown` files, or a `url` to a `GotenbergResponse` that contains the `Response` which holds the content of the converted PDF file.

`convert` expects two parameters; the first parameter represents what will be converted (i.e. `url`, `html`, or `markdown` files), and the second one is a `PageProperties` parameter.

#### URL

```swfit
let response = try await client.convertUrl("https://gotenberg.dev/")
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

#### Markdown

This route accepts an `index.html` file plus markdown files. Check [Gotenberg docs](https://gotenberg.dev/docs/routes#markdown-files-into-pdf-route) for details.

#### Screenshot

### LibreOffice

### PDF Engines

# under construction
