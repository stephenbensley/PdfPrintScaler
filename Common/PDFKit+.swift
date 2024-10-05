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
        // Mutliply by DPI first to avoid float rounding issues.
        let imageSize = CGSize(
            width:  (pageSize.width  * dpi) / ppi,
            height: (pageSize.height * dpi) / ppi
        )
        
        // Y coordinates are reversed between PDF and UIImage
        return UIGraphicsImageRenderer(size: imageSize).image { context in
            context.cgContext.translateBy(x: 0.0, y: imageSize.height)
            let scaleBy = dpi / ppi
            context.cgContext.scaleBy(x: scaleBy, y: -scaleBy)
            self.draw(with: .mediaBox, to: context.cgContext)
        }
    }
}

public extension PDFDocument {
    // Scales each page in the document by the given scale factor. Page size remains unchanged,
    // only the content is scaled.
    func scaleBy(
        _ scaleFactor: CGFloat,
        dpi: CGFloat = 300.0,
        pageComplete: (Int) -> Void = { _ in }
    ) -> Data {
        // PDF coordinates are in points with 72 points per inch.
        let ppi = 72.0
        // Letter-sized rectangle.
        let letter = CGRect(x: 0.0, y: 0.0, width: 8.5 * ppi, height: 11.0 * ppi)
        
        // Use the first page as the bounds for the renderer -- or just default to letter.
        let bounds = self.page(at: 0)?.bounds(for: .mediaBox) ?? letter
        
        return UIGraphicsPDFRenderer(bounds: bounds).pdfData { context in
            for i in 0..<self.pageCount {
                guard !Task.isCancelled else { break }
                guard let page = self.page(at: i) else { continue }
                let pageSize = page.bounds(for: .mediaBox).size
                let image = page.uiImage(dpi: dpi)
                let originScale = 0.5 * (1.0 - scaleFactor)
                let imageOrigin = CGPoint(
                    x: pageSize.width  * originScale,
                    y: pageSize.height * originScale
                )
                let imageSize = CGSize(
                    width:  pageSize.width  * scaleFactor,
                    height: pageSize.height * scaleFactor
                )
                context.beginPage(withBounds: page.bounds(for: .mediaBox), pageInfo: .init())
                image.draw(in: .init(origin: imageOrigin, size: imageSize))
                pageComplete(i + 1)
            }
        }
    }
}
