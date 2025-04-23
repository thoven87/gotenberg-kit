//
//  LibreOfficeConversionOptions.swift
//  gotenberg-kit
//
//  Created by Stevenson Michel on 4/11/25.
//

/// LibreOffice conversion options for Gotenberg
public struct LibreOfficeConversionOptions {
    /// Landscape orientation flag
    public var landscape: Bool?
    
    /// Paper width in inches
    public var paperWidth: Double?
    
    /// Paper height in inches
    public var paperHeight: Double?
    
    /// Page margins in inches
    public var marginTop: Double?
    public var marginBottom: Double?
    public var marginLeft: Double?
    public var marginRight: Double?
    
    /// PDF/A compliance level (can be "1a", "1b", "2a", "2b", "2u", "3a", "3b", or "3u")
    public var pdfFormat: PDFFormat? //String?
    
    public var merge: Bool
    
    /// Initialize with default values
    public init(
        landscape: Bool? = nil,
        paperWidth: Double? = nil,
        paperHeight: Double? = nil,
        marginTop: Double? = nil,
        marginBottom: Double? = nil,
        marginLeft: Double? = nil,
        marginRight: Double? = nil,
        pdfFormat: PDFFormat? = nil,
        merge: Bool = false
    ) {
        self.landscape = landscape
        self.paperWidth = paperWidth
        self.paperHeight = paperHeight
        self.marginTop = marginTop
        self.marginBottom = marginBottom
        self.marginLeft = marginLeft
        self.marginRight = marginRight
        self.pdfFormat = pdfFormat
        self.merge = merge
    }
    
    /// Convert options to form values for the API request
    var formValues: [String: String] {
        var values: [String: String] = [:]
        
        if let landscape = landscape {
            values["landscape"] = landscape ? "true" : "false"
        }
        
        if let paperWidth = paperWidth {
            values["paperWidth"] = "\(paperWidth)"
        }
        
        if let paperHeight = paperHeight {
            values["paperHeight"] = "\(paperHeight)"
        }
        
        if let marginTop = marginTop {
            values["marginTop"] = "\(marginTop)"
        }
        
        if let marginBottom = marginBottom {
            values["marginBottom"] = "\(marginBottom)"
        }
        
        if let marginLeft = marginLeft {
            values["marginLeft"] = "\(marginLeft)"
        }
        
        if let marginRight = marginRight {
            values["marginRight"] = "\(marginRight)"
        }
        
        if let pdfFormat = pdfFormat {
            values["pdfFormat"] = pdfFormat.rawValue
        }
        
        values["merge"] = merge ? "true" : "false"
        
        return values
    }
}
