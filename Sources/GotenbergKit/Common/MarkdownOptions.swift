//
//  MarkdownOptions.swift
//  gotenberg-kit
//
//  Created by Stevenson Michel on 4/11/25.
//

// MARK: MarkdownOptions
public struct MarkdownOptions {
    public var paperWidth: Double?
    public var paperHeight: Double?
    public var marginTop: Double?
    public var marginBottom: Double?
    public var marginLeft: Double?
    public var marginRight: Double?
    public var preferCssPageSize: Bool?
    public var printBackground: Bool?
    public var landscape: Bool?
    public var scale: Double?
    public var nativePageRanges: String?
    public var headerHTML: String?
    public var footerHTML: String?
    
    public init(
        paperWidth: Double? = nil,
        paperHeight: Double? = nil,
        marginTop: Double? = nil,
        marginBottom: Double? = nil,
        marginLeft: Double? = nil,
        marginRight: Double? = nil,
        preferCssPageSize: Bool? = nil,
        printBackground: Bool? = nil,
        landscape: Bool? = nil,
        scale: Double? = nil,
        nativePageRanges: String? = nil,
        headerHTML: String? = nil,
        footerHTML: String? = nil
    ) {
        self.paperWidth = paperWidth
        self.paperHeight = paperHeight
        self.marginTop = marginTop
        self.marginBottom = marginBottom
        self.marginLeft = marginLeft
        self.marginRight = marginRight
        self.preferCssPageSize = preferCssPageSize
        self.printBackground = printBackground
        self.landscape = landscape
        self.scale = scale
        self.nativePageRanges = nativePageRanges
        self.headerHTML = headerHTML
        self.footerHTML = footerHTML
    }
    
    var formValues: [String: String] {
        var values: [String: String] = [:]
        
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
        
        if let preferCssPageSize = preferCssPageSize {
            values["preferCssPageSize"] = preferCssPageSize ? "true" : "false"
        }
        
        if let printBackground = printBackground {
            values["printBackground"] = printBackground ? "true" : "false"
        }
        
        if let landscape = landscape {
            values["landscape"] = landscape ? "true" : "false"
        }
        
        if let scale = scale {
            values["scale"] = "\(scale)"
        }
        
        if let nativePageRanges = nativePageRanges {
            values["nativePageRanges"] = nativePageRanges
        }
        
        if let headerHTML = headerHTML {
            values["headerHTML"] = headerHTML
        }
        
        if let footerHTML = footerHTML {
            values["footerHTML"] = footerHTML
        }
        
        return values
    }
}
