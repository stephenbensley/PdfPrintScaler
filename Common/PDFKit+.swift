//
// Copyright 2024 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/PdfPrintScaler/blob/main/LICENSE.
//

import PDFKit

public extension PDFPage {
    // Renders page as a UIImage
    func uiImage(dpi: CGFloat = 300.0) -> UIImage {
        // PDF coordinates are in points with 72 points per inch.
        let ppi = 72.0
        let pageSize = self.bounds(for: .mediaBox)
        // Multiply by DPI first to avoid float rounding issues.
        let imageSize = CGSize(
            width:  (pageSize.width  * dpi) / ppi,
            height: (pageSize.height * dpi) / ppi
        )
        
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1.0
        return UIGraphicsImageRenderer(size: imageSize, format: format).image { context in
            // Y coordinates are reversed between PDF and UIImage
            context.cgContext.translateBy(x: 0.0, y: imageSize.height)
            let scaleBy = dpi / ppi
            context.cgContext.scaleBy(x: scaleBy, y: -scaleBy)
            self.draw(with: .mediaBox, to: context.cgContext)
        }
    }
    
    // Scales the page by the given scale factor. Page size remains unchanged, only the content is
    // scaled.
    func scaleBy(_ scaleFactor: CGFloat, dpi: CGFloat = 300.0) -> PDFPage {
        let bounds = bounds(for: .mediaBox)
        let data = UIGraphicsPDFRenderer(bounds: bounds).pdfData { context in
            let pageSize = bounds.size
            let image = uiImage(dpi: dpi)
            let originScale = 0.5 * (1.0 - scaleFactor)
            let imageOrigin = CGPoint(
                x: pageSize.width  * originScale,
                y: pageSize.height * originScale
            )
            let imageSize = CGSize(
                width:  pageSize.width  * scaleFactor,
                height: pageSize.height * scaleFactor
            )
            context.beginPage()
            image.draw(in: .init(origin: imageOrigin, size: imageSize))
        }
        
        // We just created the PDF, so we know it exists and has a page.
        return PDFDocument(data: data)!.page(at: 0)!
    }
}

public extension PDFDocument {
    // Scales each page in the document by the given scale factor. The pageComplete closure is
    // invoked to report progress. The function is cancellable; in which case, it returns a partial
    // document with only the pages scaled so far.
    func scaleBy(
        _ scaleFactor: CGFloat,
        dpi: CGFloat = 300.0,
        pageComplete: (Int) -> Void = { _ in }
    ) -> Data {
        let doc = PDFDocument()
        for page in self {
            let scaled = page.scaleBy(scaleFactor)
            doc.insert(scaled, at: doc.pageCount)
            pageComplete(doc.pageCount)
            if Task.isCancelled { break }
        }
        return doc.dataRepresentation()!
    }
}

// Extend PDFDocument to support RandomAcessCollection. Useful for iterating through all the pages.
extension PDFDocument: @retroactive RandomAccessCollection {
    public typealias Index = Int
    public typealias Element = PDFPage
    
    public var startIndex: Index { 0 }
    public var endIndex: Index { pageCount }
    public subscript(index: Index) -> Iterator.Element {page(at: index)! }
    public func index(after i: Index) -> Index { i + 1 }
}
