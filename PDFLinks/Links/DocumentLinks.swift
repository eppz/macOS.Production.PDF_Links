//
//  DocumentLinks.swift
//  PDFLinks
//
//  Created by Geri Borbás on 2020. 02. 11..
//  Copyright © 2020. Geri Borbás. All rights reserved.
//

import Foundation


struct DocumentLinks: Codable
{
    
    
    let pageLinks: [PageLinks]
    
    
    enum CodingKeys: String, CodingKey
    {
        case pageLinks = "pages" // More readable in JSON context
    }
}


extension DocumentLinks
{
    
    
    init?(from pdfUrl: URL)
    {
        // Document.
        guard
            let document = CGPDFDocument(pdfUrl as CFURL)
        else
        {
            print("Cannot open PDF.")
            return nil
        }
        
        // Lookup options file (if any).
        var options: Options?
        let optionsJsonUrl = pdfUrl.deletingPathExtension().appendingPathExtension("json")
        if FileManager.default.fileExists(atPath: optionsJsonUrl.path)
        {
            do
            {
                let data = try Data(contentsOf: optionsJsonUrl)
                options = try JSONDecoder().decode(Options.self, from: data)
            }
            catch
            { print(error) }
        }
            
        // Process each page.
        var pageLinks: [PageLinks] = []
        (0...document.numberOfPages).forEach
        {
            eachPageIndex in
            if let eachPageLinks = PageLinks(from: document.page(at: eachPageIndex), options: options)
            { pageLinks.append(eachPageLinks) }
        }
        
        // Set.
        self.pageLinks = pageLinks
    }
    
    func write(to jsonURL: URL)
    {
        do
        {
            let encoder = JSONEncoder()
                encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(self)
            try data.write(to: jsonURL, options: [])
        }
        catch
        { print(error) }
    }
}
