//
// Copyright 2024 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/PdfPrintScaler/blob/main/LICENSE.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Text("PDF Print Scaler")
                .font(.title)
            ScaledPrintView()
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
