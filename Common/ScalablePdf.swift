//
// Copyright 2024 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/PdfPrintScaler/blob/main/LICENSE.
//

import Foundation
import Observation
import PDFKit

// Model of a scalable PDF
@Observable class ScalablePdf {
    let data: Data
    let doc: PDFDocument
    var pageNumber = 1
    var scale = 100

    init?(url: URL) {
        guard let data = try? Data(contentsOf: url) else { return nil }
        guard let doc = PDFDocument(data: data) else { return nil }
        guard doc.pageCount > 0 else { return nil }
        
        self.data = data
        self.doc = doc
    }
    
    var pageCount: Int { doc.pageCount }
    var preview: UIImage { doc.page(at: pageNumber - 1)!.uiImage(dpi: 150.0) }
    var scaleFactor: CGFloat { CGFloat(scale)/100.0 }

    func scalePdf() async -> Data {
        // Must be detached to avoid hogging MainActor
        let task = Task.detached { [data, scaleFactor] in
            PDFDocument(data: data)!.scaleBy(scaleFactor)
        }
        return await task.result.get()
    }
}
