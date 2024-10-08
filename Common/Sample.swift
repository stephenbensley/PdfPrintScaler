//
// Copyright 2024 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/PdfPrintScaler/blob/main/LICENSE.
//

import PDFKit
import SwiftUI

// Sample data for previews.
struct Sample {
    static var url: URL { Bundle.main.url(forResource: "Sample", withExtension: "pdf")! }
    static var doc: PDFDocument { PDFDocument(url: url)! }
}
