//
// Copyright 2024 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/PdfPrintScaler/blob/main/LICENSE.
//

import Foundation
import Observation
import PDFKit

enum PdfError: LocalizedError {
    case invalidData
    case emptyFile
    
    var errorDescription: String? {
        switch self {
        case .invalidData:
            "Data in PDF file is invalid or corrupt."
        case .emptyFile:
            "PDF file does not contain any pages."
        }
    }
}

// Model of a scalable PDF
@Observable class ScalablePdf {
    let data: Data
    let doc: PDFDocument
    var pageNumber = 1
    var scale = 100
    
    init(url: URL) throws {
        let data = try Data(contentsOf: url)
        guard let doc = PDFDocument(data: data) else { throw PdfError.invalidData }
        guard doc.pageCount > 0 else { throw PdfError.emptyFile }
        
        self.data = data
        self.doc = doc
    }
    
    var pageCount: Int { doc.pageCount }
    var preview: UIImage { doc.page(at: pageNumber - 1)!.uiImage(dpi: 150.0) }
    var scaleFactor: CGFloat { CGFloat(scale)/100.0 }
    
    func scalePdf(pageComplete: (Int) -> Void) -> Data {
        PDFDocument(data: data)!.scaleBy(scaleFactor, pageComplete: pageComplete)
    }
}
