//
//  EmbedFilesTests.swift
//  gotenberg-kit
//
//  Created by Stevenson Michel on 11/19/25.
//

import AsyncHTTPClient
import Foundation
import Testing

@testable import GotenbergKit

@Suite("PDF Embed Files Tests")
struct EmbedFilesTests {

    let client = GotenbergClient(
        baseURL: URL(string: ProcessInfo.processInfo.environment["GOTENBERG_URL"] ?? "http://localhost:7100")!,
        username: "gotenberg",
        password: "password"
    )

    /// Test embed files functionality for ZUGFeRD/Factur-X compliance during conversion
    @Test
    func testEmbedFilesDuringConversion() async throws {
        // Create a simple HTML document
        let htmlContent = """
            <!DOCTYPE html>
            <html>
            <head><title>Invoice Document</title></head>
            <body>
                <h1>Invoice #12345</h1>
                <p>Amount: $1,000.00</p>
            </body>
            </html>
            """

        // Create mock XML invoice data (ZUGFeRD/Factur-X format)
        let invoiceXML = """
            <?xml version="1.0" encoding="UTF-8"?>
            <Invoice xmlns="urn:un:unece:uncefact:data:standard:CrossIndustryInvoice:100">
                <ExchangedDocumentContext>
                    <BusinessProcessSpecifiedDocumentContextParameter>
                        <ID>urn:cen.eu:en16931:2017</ID>
                    </BusinessProcessSpecifiedDocumentContextParameter>
                </ExchangedDocumentContext>
                <ExchangedDocument>
                    <ID>INV-12345</ID>
                    <TypeCode>380</TypeCode>
                </ExchangedDocument>
            </Invoice>
            """.data(using: .utf8)!

        // Create additional attachment file
        let metadataJSON = """
            {
                "invoice_number": "INV-12345",
                "amount": 1000.00,
                "currency": "USD",
                "date": "2025-01-01"
            }
            """.data(using: .utf8)!

        // Test ChromiumOptions with embed files
        let chromiumOptions = ChromiumOptions(
            embeds: [
                "invoice.xml": invoiceXML,
                "metadata.json": metadataJSON,
            ]
        )

        let chromiumResponse = try await client.convert(
            html: htmlContent.data(using: .utf8)!,
            options: chromiumOptions
        )

        let chromiumPdfData = try await client.toData(chromiumResponse)
        #expect(chromiumPdfData.count > 0, "PDF with embedded files should contain data")

        // Verify it's a valid PDF
        let pdfHeader = String(data: chromiumPdfData.prefix(4), encoding: .ascii)
        #expect(pdfHeader == "%PDF", "File with embedded files should be a valid PDF")

        // Test LibreOffice with embed files
        let docContent = """
            Invoice Document

            Invoice Number: INV-12345
            Amount: $1,000.00
            Date: January 1, 2025
            """.data(using: .utf8)!

        let libreOfficeOptions = LibreOfficeConversionOptions(
            embeds: [
                "invoice.xml": invoiceXML,
                "metadata.json": metadataJSON,
            ]
        )

        // Test with actual LibreOffice conversion (using .txt file which LibreOffice can handle)
        let libreOfficeResponse = try await client.convertWithLibreOffice(
            documents: ["invoice.txt": docContent],
            options: libreOfficeOptions
        )

        let libreOfficePdfData = try await client.toData(libreOfficeResponse)
        #expect(libreOfficePdfData.count > 0, "LibreOffice PDF with embedded files should contain data")

        // Verify it's a valid PDF
        let libreOfficePdfHeader = String(data: libreOfficePdfData.prefix(4), encoding: .ascii)
        #expect(libreOfficePdfHeader == "%PDF", "LibreOffice file with embedded files should be a valid PDF")

        // Save files for manual inspection
        try chromiumPdfData.write(to: URL(fileURLWithPath: "/tmp/conversion_chromium_embeds.pdf"))
        try libreOfficePdfData.write(to: URL(fileURLWithPath: "/tmp/conversion_libreoffice_embeds.pdf"))

        print("🔍 Conversion Embed Files Test:")
        print("📄 Chromium PDF: /tmp/conversion_chromium_embeds.pdf")
        print("📄 LibreOffice PDF: /tmp/conversion_libreoffice_embeds.pdf")
        print("📎 Embedded files: invoice.xml, metadata.json")
    }

    /// Test dedicated embedFiles method with documents
    @Test
    func testDedicatedEmbedFiles() async throws {
        // Create a simple base PDF first
        let htmlContent = """
            <!DOCTYPE html>
            <html>
            <head><title>Base Document</title></head>
            <body>
                <h1>Invoice #INV-2025-001</h1>
                <p>Total Amount: $1,500.00</p>
            </body>
            </html>
            """

        // Create base PDF without embeds
        let basePdfResponse = try await client.convert(
            html: htmlContent.data(using: .utf8)!,
            options: ChromiumOptions()
        )

        let basePdfData = try await client.toData(basePdfResponse)

        // Create files to embed
        let invoiceXML = """
            <?xml version="1.0" encoding="UTF-8"?>
            <Invoice xmlns="urn:un:unece:uncefact:data:standard:CrossIndustryInvoice:100">
                <ExchangedDocument>
                    <ID>INV-2025-001</ID>
                    <TypeCode>380</TypeCode>
                </ExchangedDocument>
                <SupplyChainTradeTransaction>
                    <ApplicableHeaderTradeAgreement>
                        <SellerTradeParty>
                            <Name>Example Corp</Name>
                        </SellerTradeParty>
                    </ApplicableHeaderTradeAgreement>
                </SupplyChainTradeTransaction>
            </Invoice>
            """.data(using: .utf8)!

        let metadataJSON = """
            {
                "invoice_id": "INV-2025-001",
                "amount": 1500.00,
                "currency": "USD",
                "date": "2025-01-01",
                "status": "paid"
            }
            """.data(using: .utf8)!

        // Test embedding files into existing PDF
        let embedOptions = PDFEngineOptions(
            embeds: [
                "factur-x.xml": invoiceXML,
                "invoice-metadata.json": metadataJSON,
            ]
        )

        let embeddedResponse = try await client.embedFiles(
            documents: ["invoice.pdf": basePdfData],
            options: embedOptions
        )

        let embeddedPdfData = try await client.toData(embeddedResponse)
        #expect(embeddedPdfData.count > 0, "PDF with embedded files should contain data")

        // Verify it's still a valid PDF
        let pdfHeader = String(data: embeddedPdfData.prefix(4), encoding: .ascii)
        #expect(pdfHeader == "%PDF", "File with embedded files should be a valid PDF")

        // Test with additional options (metadata override + embeds)
        let metadata = Metadata(
            author: "Embed Test",
            copyright: "Test Copyright",
            creator: "GotenbergKit Embed Test",
            marked: true,
            producer: "Swift Test Suite",
            subject: "Embedded Files Test",
            title: "Invoice with Embedded Files"
        )

        let advancedOptions = PDFEngineOptions(
            metadata: metadata,
            embeds: [
                "factur-x.xml": invoiceXML,
                "metadata.json": metadataJSON,
            ]
        )

        let advancedEmbeddedResponse = try await client.embedFiles(
            documents: ["advanced-invoice.pdf": basePdfData],
            options: advancedOptions
        )

        let advancedEmbeddedData = try await client.toData(advancedEmbeddedResponse)
        #expect(advancedEmbeddedData.count > 0, "Advanced embedded PDF should contain data")

        // Save files for inspection
        try embeddedPdfData.write(to: URL(fileURLWithPath: "/tmp/dedicated_embedded_basic.pdf"))
        try advancedEmbeddedData.write(to: URL(fileURLWithPath: "/tmp/dedicated_embedded_advanced.pdf"))

        print("🔍 Dedicated Embed Files Test:")
        print("📄 Basic embedded: /tmp/dedicated_embedded_basic.pdf")
        print("📄 Advanced embedded: /tmp/dedicated_embedded_advanced.pdf")
        print("📎 Embedded files: factur-x.xml, invoice-metadata.json")
    }

    /// Test dedicated embedFiles method with URLs
    @Test
    func testDedicatedEmbedFilesWithURLs() async throws {
        // Create files to embed
        let sampleXML = """
            <?xml version="1.0" encoding="UTF-8"?>
            <Document>
                <ID>TEST-001</ID>
                <Type>Sample</Type>
            </Document>
            """.data(using: .utf8)!

        // Test with invalid URLs (should fail gracefully)
        let urls = [
            DownloadFrom(url: "https://httpbin.org/status/404")
        ]

        let embedOptions = PDFEngineOptions(
            embeds: [
                "sample.xml": sampleXML
            ]
        )

        // This should fail due to invalid PDF URL
        do {
            _ = try await client.embedFiles(
                urls: urls,
                options: embedOptions
            )
            #expect(Bool(false), "Should fail with invalid PDF URL")
        } catch {
            // Expected to fail with invalid URL, but method should work
            #expect(error is GotenbergError, "Should fail gracefully with invalid PDF URL")
        }
    }

    /// Test embedFiles validation (should require embeds)
    @Test
    func testEmbedFilesValidation() async throws {
        // Create a simple PDF
        let htmlContent = "<h1>Test Document</h1>"
        let pdfResponse = try await client.convert(
            html: htmlContent.data(using: .utf8)!,
            options: ChromiumOptions()
        )
        let pdfData = try await client.toData(pdfResponse)

        // Test with empty embeds (should fail)
        let emptyOptions = PDFEngineOptions()

        do {
            _ = try await client.embedFiles(
                documents: ["test.pdf": pdfData],
                options: emptyOptions
            )
            #expect(Bool(false), "Should fail with empty embeds")
        } catch GotenbergError.invalidInput(let message) {
            #expect(message.contains("embed file is required"), "Should specify embed requirement")
        } catch {
            #expect(Bool(false), "Should throw invalidInput error")
        }

        // Test with empty documents (should fail)
        let validOptions = PDFEngineOptions(
            embeds: [
                "test.xml": "test".data(using: .utf8)!
            ]
        )

        do {
            _ = try await client.embedFiles(
                documents: [:],
                options: validOptions
            )
            #expect(Bool(false), "Should fail with empty documents")
        } catch GotenbergError.noPDFsProvided {
            // Expected error
        } catch {
            #expect(Bool(false), "Should throw noPDFsProvided error")
        }
    }

    /// Test empty embeds (should not affect normal operation)
    @Test
    func testEmptyEmbeds() async throws {
        let htmlContent = "<h1>Test Document</h1>"

        // Test with empty embeds dictionary
        let options = ChromiumOptions(embeds: [:])

        let response = try await client.convert(
            html: htmlContent.data(using: .utf8)!,
            options: options
        )

        let pdfData = try await client.toData(response)
        #expect(pdfData.count > 0, "PDF with empty embeds should generate normally")

        let pdfHeader = String(data: pdfData.prefix(4), encoding: .ascii)
        #expect(pdfHeader == "%PDF", "Should still be a valid PDF")
    }

    /// Test embed files with PDF processing operations
    @Test
    func testEmbedFilesWithPDFProcessing() async throws {
        // Create base PDFs
        let html1 = "<h1>Document 1</h1><p>First document content</p>"
        let html2 = "<h1>Document 2</h1><p>Second document content</p>"

        let pdf1Response = try await client.convert(
            html: html1.data(using: .utf8)!,
            options: ChromiumOptions()
        )
        let pdf2Response = try await client.convert(
            html: html2.data(using: .utf8)!,
            options: ChromiumOptions()
        )

        let pdf1Data = try await client.toData(pdf1Response)
        let pdf2Data = try await client.toData(pdf2Response)

        // Create embed files
        let attachmentData = """
            {
                "operation": "merge",
                "timestamp": "2025-01-01T00:00:00Z",
                "documents": ["doc1.pdf", "doc2.pdf"]
            }
            """.data(using: .utf8)!

        // Test merging with embeds
        let mergeOptions = PDFEngineOptions(
            embeds: [
                "merge-info.json": attachmentData
            ]
        )

        let mergedResponse = try await client.mergeWithPDFEngines(
            documents: [
                "doc1.pdf": pdf1Data,
                "doc2.pdf": pdf2Data,
            ],
            options: mergeOptions
        )

        let mergedPdfData = try await client.toData(mergedResponse)
        #expect(mergedPdfData.count > 0, "Merged PDF with embedded files should contain data")

        // Verify it's a valid PDF
        let pdfHeader = String(data: mergedPdfData.prefix(4), encoding: .ascii)
        #expect(pdfHeader == "%PDF", "Merged file with embedded files should be a valid PDF")

        // Test converting with embeds
        let convertOptions = PDFEngineOptions(
            format: .A1B,
            embeds: [
                "conversion-info.json": attachmentData
            ]
        )

        let convertedResponse = try await client.convertWithPDFEngines(
            documents: ["source.pdf": pdf1Data],
            options: convertOptions
        )

        let convertedPdfData = try await client.toData(convertedResponse)
        #expect(convertedPdfData.count > 0, "Converted PDF with embedded files should contain data")

        // Save files for inspection
        try mergedPdfData.write(to: URL(fileURLWithPath: "/tmp/processing_merged_embeds.pdf"))
        try convertedPdfData.write(to: URL(fileURLWithPath: "/tmp/processing_converted_embeds.pdf"))

        print("🔍 PDF Processing Embed Files Test:")
        print("📄 Merged PDF: /tmp/processing_merged_embeds.pdf")
        print("📄 Converted PDF: /tmp/processing_converted_embeds.pdf")
        print("📎 Embedded files: merge-info.json, conversion-info.json")
    }

    /// Test realistic ZUGFeRD invoice with German company data
    @Test
    func testZUGFeRDInvoiceExample() async throws {
        // Create realistic German invoice HTML based on Kraxi GmbH example
        let invoiceHTML = """
            <!DOCTYPE html>
            <html lang="de">
            <head>
                <meta charset="UTF-8">
                <title>Rechnung 2019-03</title>
                <style>
                    body { font-family: Arial, sans-serif; margin: 20px; }
                    .header { text-align: center; margin-bottom: 30px; }
                    .company-info { margin-bottom: 20px; }
                    .invoice-details { margin: 20px 0; }
                    table { width: 100%; border-collapse: collapse; margin: 20px 0; }
                    th, td { border: 1px solid #ccc; padding: 8px; text-align: left; }
                    th { background-color: #f5f5f5; }
                    .text-right { text-align: right; }
                    .totals { margin-top: 20px; }
                    .footer { margin-top: 30px; font-size: 12px; }
                </style>
            </head>
            <body>
                <div class="header">
                    <h1>Kraxi GmbH</h1>
                    <p>Flugzeugallee 17 • 12345 Papierfeld • Deutschland</p>
                    <p>Tel. (0123) 4567 • Fax (0123) 4568 • info@kraxi.com • www.kraxi.com</p>
                </div>

                <div class="company-info">
                    <p><strong>Papierflieger-Vertriebs-GmbH</strong><br>
                    Helga Musterfrau<br>
                    Rabattstr. 25<br>
                    34567 Osterhausen<br>
                    Deutschland</p>
                </div>

                <div class="invoice-details">
                    <p><strong>Rechnungsnummer:</strong> 2019-03</p>
                    <p><strong>Liefer- und Rechnungsdatum:</strong> 8. Mai 2019</p>
                    <p><strong>Kundennummer:</strong> 987-654</p>
                    <p><strong>Ihre Auftragsnummer:</strong> ABC-123</p>
                    <p><strong>Beträge in EUR</strong></p>
                </div>

                <table>
                    <thead>
                        <tr>
                            <th>Pos.</th>
                            <th>Artikelbeschreibung</th>
                            <th>Menge</th>
                            <th>Preis</th>
                            <th>Betrag</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr><td>1</td><td>Superdrachen</td><td>2</td><td class="text-right">20,00</td><td class="text-right">40,00</td></tr>
                        <tr><td>2</td><td>Turbo Flyer</td><td>5</td><td class="text-right">40,00</td><td class="text-right">200,00</td></tr>
                        <tr><td>3</td><td>Sturzflug-Geier</td><td>1</td><td class="text-right">180,00</td><td class="text-right">180,00</td></tr>
                        <tr><td>4</td><td>Eisvogel</td><td>3</td><td class="text-right">50,00</td><td class="text-right">150,00</td></tr>
                        <tr><td>5</td><td>Storch</td><td>10</td><td class="text-right">20,00</td><td class="text-right">200,00</td></tr>
                        <tr><td>6</td><td>Adler</td><td>1</td><td class="text-right">75,00</td><td class="text-right">75,00</td></tr>
                        <tr><td>7</td><td>Kostenlose Zugabe</td><td>1</td><td class="text-right">0,00</td><td class="text-right">0,00</td></tr>
                    </tbody>
                </table>

                <div class="totals">
                    <table style="width: 300px; margin-left: auto;">
                        <tr><td><strong>Rechnungssumme netto</strong></td><td class="text-right"><strong>845,00</strong></td></tr>
                        <tr><td>zuzüglich 19% MwSt.</td><td class="text-right">160,55</td></tr>
                        <tr><td><strong>Rechnungssumme brutto</strong></td><td class="text-right"><strong>1.005,55</strong></td></tr>
                    </table>
                </div>

                <div class="footer">
                    <p>Zahlbar innerhalb von 30 Tagen netto auf unser Konto. Bitte geben Sie dabei die Rechnungsnummer an. Skontoabzüge werden nicht akzeptiert.</p>
                    <p><strong>Kraxi GmbH</strong> • Sitz der Gesellschaft München • HRB 999999 • USt-IdNr DE123456789<br>
                    GF Paul Kraxi • Postbank München • IBAN DE28700100809999999999</p>
                </div>
            </body>
            </html>
            """

        // Create realistic ZUGFeRD XML data for the invoice
        let zugferdXML = """
            <?xml version="1.0" encoding="UTF-8"?>
            <rsm:CrossIndustryInvoice xmlns:rsm="urn:un:unece:uncefact:data:standard:CrossIndustryInvoice:100"
                                     xmlns:qdt="urn:un:unece:uncefact:data:standard:QualifiedDataType:100"
                                     xmlns:ram="urn:un:unece:uncefact:data:standard:ReusableAggregateBusinessInformationEntity:100"
                                     xmlns:xs="http://www.w3.org/2001/XMLSchema"
                                     xmlns:udt="urn:un:unece:uncefact:data:standard:UnqualifiedDataType:100">
                <rsm:ExchangedDocumentContext>
                    <ram:GuidelineSpecifiedDocumentContextParameter>
                        <ram:ID>urn:cen.eu:en16931:2017#compliant#urn:zugferd.de:2p1:comfort</ram:ID>
                    </ram:GuidelineSpecifiedDocumentContextParameter>
                </rsm:ExchangedDocumentContext>
                <rsm:ExchangedDocument>
                    <ram:ID>2019-03</ram:ID>
                    <ram:TypeCode>380</ram:TypeCode>
                    <ram:IssueDateTime>
                        <udt:DateTimeString format="102">20190508</udt:DateTimeString>
                    </ram:IssueDateTime>
                </rsm:ExchangedDocument>
                <rsm:SupplyChainTradeTransaction>
                    <ram:IncludedSupplyChainTradeLineItem>
                        <ram:AssociatedDocumentLineDocument>
                            <ram:LineID>1</ram:LineID>
                        </ram:AssociatedDocumentLineDocument>
                        <ram:SpecifiedTradeProduct>
                            <ram:Name>Superdrachen</ram:Name>
                        </ram:SpecifiedTradeProduct>
                        <ram:SpecifiedLineTradeAgreement>
                            <ram:NetPriceProductTradePrice>
                                <ram:ChargeAmount>20.00</ram:ChargeAmount>
                            </ram:NetPriceProductTradePrice>
                        </ram:SpecifiedLineTradeAgreement>
                        <ram:SpecifiedLineTradeDelivery>
                            <ram:BilledQuantity unitCode="C62">2</ram:BilledQuantity>
                        </ram:SpecifiedLineTradeDelivery>
                        <ram:SpecifiedLineTradeSettlement>
                            <ram:SpecifiedTradeSettlementLineMonetarySummation>
                                <ram:LineTotalAmount>40.00</ram:LineTotalAmount>
                            </ram:SpecifiedTradeSettlementLineMonetarySummation>
                        </ram:SpecifiedLineTradeSettlement>
                    </ram:IncludedSupplyChainTradeLineItem>
                    <ram:ApplicableHeaderTradeAgreement>
                        <ram:SellerTradeParty>
                            <ram:Name>Kraxi GmbH</ram:Name>
                            <ram:PostalTradeAddress>
                                <ram:PostcodeCode>12345</ram:PostcodeCode>
                                <ram:LineOne>Flugzeugallee 17</ram:LineOne>
                                <ram:CityName>Papierfeld</ram:CityName>
                                <ram:CountryID>DE</ram:CountryID>
                            </ram:PostalTradeAddress>
                            <ram:SpecifiedTaxRegistration>
                                <ram:ID schemeID="VA">DE123456789</ram:ID>
                            </ram:SpecifiedTaxRegistration>
                        </ram:SellerTradeParty>
                        <ram:BuyerTradeParty>
                            <ram:Name>Papierflieger-Vertriebs-GmbH</ram:Name>
                            <ram:PostalTradeAddress>
                                <ram:PostcodeCode>34567</ram:PostcodeCode>
                                <ram:LineOne>Rabattstr. 25</ram:LineOne>
                                <ram:CityName>Osterhausen</ram:CityName>
                                <ram:CountryID>DE</ram:CountryID>
                            </ram:PostalTradeAddress>
                        </ram:BuyerTradeParty>
                    </ram:ApplicableHeaderTradeAgreement>
                    <ram:ApplicableHeaderTradeDelivery>
                        <ram:ActualDeliverySupplyChainEvent>
                            <ram:OccurrenceDateTime>
                                <udt:DateTimeString format="102">20190508</udt:DateTimeString>
                            </ram:OccurrenceDateTime>
                        </ram:ActualDeliverySupplyChainEvent>
                    </ram:ApplicableHeaderTradeDelivery>
                    <ram:ApplicableHeaderTradeSettlement>
                        <ram:InvoiceCurrencyCode>EUR</ram:InvoiceCurrencyCode>
                        <ram:ApplicableTradeTax>
                            <ram:CalculatedAmount>160.55</ram:CalculatedAmount>
                            <ram:TypeCode>VAT</ram:TypeCode>
                            <ram:CategoryCode>S</ram:CategoryCode>
                            <ram:RateApplicablePercent>19</ram:RateApplicablePercent>
                        </ram:ApplicableTradeTax>
                        <ram:SpecifiedTradeSettlementHeaderMonetarySummation>
                            <ram:LineTotalAmount>845.00</ram:LineTotalAmount>
                            <ram:TaxBasisTotalAmount>845.00</ram:TaxBasisTotalAmount>
                            <ram:TaxTotalAmount currencyID="EUR">160.55</ram:TaxTotalAmount>
                            <ram:GrandTotalAmount>1005.55</ram:GrandTotalAmount>
                        </ram:SpecifiedTradeSettlementHeaderMonetarySummation>
                    </ram:ApplicableHeaderTradeSettlement>
                </rsm:SupplyChainTradeTransaction>
            </rsm:CrossIndustryInvoice>
            """.data(using: .utf8)!

        // Create invoice metadata JSON
        let invoiceMetadata = """
            {
                "invoice_number": "2019-03",
                "invoice_date": "2019-05-08",
                "delivery_date": "2019-05-08",
                "customer_number": "987-654",
                "order_number": "ABC-123",
                "seller": {
                    "name": "Kraxi GmbH",
                    "address": "Flugzeugallee 17, 12345 Papierfeld, Deutschland",
                    "vat_id": "DE123456789",
                    "phone": "(0123) 4567",
                    "email": "info@kraxi.com"
                },
                "buyer": {
                    "name": "Papierflieger-Vertriebs-GmbH",
                    "contact": "Helga Musterfrau",
                    "address": "Rabattstr. 25, 34567 Osterhausen, Deutschland"
                },
                "totals": {
                    "net_amount": 845.00,
                    "vat_rate": 19,
                    "vat_amount": 160.55,
                    "gross_amount": 1005.55,
                    "currency": "EUR"
                },
                "line_items": [
                    {"pos": 1, "description": "Superdrachen", "quantity": 2, "unit_price": 20.00, "total": 40.00},
                    {"pos": 2, "description": "Turbo Flyer", "quantity": 5, "unit_price": 40.00, "total": 200.00},
                    {"pos": 3, "description": "Sturzflug-Geier", "quantity": 1, "unit_price": 180.00, "total": 180.00},
                    {"pos": 4, "description": "Eisvogel", "quantity": 3, "unit_price": 50.00, "total": 150.00},
                    {"pos": 5, "description": "Storch", "quantity": 10, "unit_price": 20.00, "total": 200.00},
                    {"pos": 6, "description": "Adler", "quantity": 1, "unit_price": 75.00, "total": 75.00},
                    {"pos": 7, "description": "Kostenlose Zugabe", "quantity": 1, "unit_price": 0.00, "total": 0.00}
                ],
                "payment_terms": "Zahlbar innerhalb von 30 Tagen netto",
                "standards_compliance": "ZUGFeRD 2.1 Comfort Profile"
            }
            """.data(using: .utf8)!

        // Create ZUGFeRD compliant invoice PDF with embedded XML
        let zugferdOptions = ChromiumOptions(
            metadata: Metadata(
                author: "Kraxi GmbH",
                copyright: "Kraxi GmbH 2019",
                creator: "GotenbergKit ZUGFeRD Generator",
                marked: true,
                producer: "Swift PDF Generator",
                subject: "ZUGFeRD Rechnung 2019-03",
                title: "Rechnung 2019-03 - Kraxi GmbH"
            ),
            embeds: [
                "ZUGFeRD-invoice.xml": zugferdXML,
                "factur-x.xml": zugferdXML,  // Also embed as Factur-X format
                "invoice-metadata.json": invoiceMetadata,
            ]
        )

        let invoicePdfResponse = try await client.convert(
            html: invoiceHTML.data(using: .utf8)!,
            options: zugferdOptions
        )

        let invoicePdfData = try await client.toData(invoicePdfResponse)
        #expect(invoicePdfData.count > 0, "ZUGFeRD invoice PDF should contain data")

        // Verify it's a valid PDF
        let pdfHeader = String(data: invoicePdfData.prefix(4), encoding: .ascii)
        #expect(pdfHeader == "%PDF", "ZUGFeRD invoice should be a valid PDF")

        // Test dedicated embedding of additional documents to existing invoice
        let additionalXML = """
            <?xml version="1.0" encoding="UTF-8"?>
            <DeliveryNote>
                <ID>LN-2019-03</ID>
                <Date>2019-05-08</Date>
                <Items>
                    <Item>
                        <Description>Superdrachen</Description>
                        <Quantity>2</Quantity>
                        <SerialNumbers>SD001, SD002</SerialNumbers>
                    </Item>
                    <Item>
                        <Description>Turbo Flyer</Description>
                        <Quantity>5</Quantity>
                        <SerialNumbers>TF001, TF002, TF003, TF004, TF005</SerialNumbers>
                    </Item>
                </Items>
            </DeliveryNote>
            """.data(using: .utf8)!

        // Use dedicated embed route to add delivery note to invoice
        let additionalEmbedOptions = PDFEngineOptions(
            embeds: [
                "delivery-note.xml": additionalXML
            ]
        )

        let completeInvoiceResponse = try await client.embedFiles(
            documents: ["invoice-2019-03.pdf": invoicePdfData],
            options: additionalEmbedOptions
        )

        let completeInvoiceData = try await client.toData(completeInvoiceResponse)
        #expect(completeInvoiceData.count > 0, "Complete invoice with delivery note should contain data")

        // Save files for inspection
        try invoicePdfData.write(to: URL(fileURLWithPath: "/tmp/zugferd_kraxi_invoice.pdf"))
        try completeInvoiceData.write(to: URL(fileURLWithPath: "/tmp/zugferd_kraxi_complete.pdf"))

        print("🔍 ZUGFeRD Kraxi GmbH Invoice Test:")
        print("📄 ZUGFeRD Invoice: /tmp/zugferd_kraxi_invoice.pdf")
        print("📄 Complete Invoice: /tmp/zugferd_kraxi_complete.pdf")
        print("📎 Embedded files: ZUGFeRD-invoice.xml, factur-x.xml, invoice-metadata.json, delivery-note.xml")
        print("💰 Total: €1.005,55 (Net: €845,00 + 19% VAT: €160,55)")
        print("🏢 Seller: Kraxi GmbH, Papierfeld")
        print("🏪 Buyer: Papierflieger-Vertriebs-GmbH, Osterhausen")
        print("📋 Standards: ZUGFeRD 2.1 Comfort Profile + Factur-X compliant")
    }
}
