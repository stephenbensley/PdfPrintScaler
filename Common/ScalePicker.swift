//
// Copyright 2024 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/PdfPrintScaler/blob/main/LICENSE.
//

import SwiftUI

// A control for selecting the scale factor.
struct ScalePicker: View {
    // Width of text field needs to vary with font size.
    @ScaledMetric(relativeTo: .body) private var maxWidth = 50.0
    // Value being configured
    @Binding private var scalePct: Int
    // Used to hide keypad
    @FocusState private var textIsFocused: Bool
    
    init(scalePct: Binding<Int>) {
        self._scalePct = scalePct
    }
    
    var body: some View {
        HStack {
            Text("Scale:")
            TextField("Scale", value: $scalePct, format: .number)
                .keyboardType(.numberPad)
                .multilineTextAlignment(.trailing)
                .focused($textIsFocused)
                .textFieldStyle(.roundedBorder)
                .frame(maxWidth: maxWidth)
            Text("%")
                .padding(.trailing)
            Stepper("Scale", onIncrement: {
                scalePct += 1
            }, onDecrement: {
                if scalePct > 0 { scalePct -= 1}
             })
            .labelsHidden()
        }
        .toolbar {
            ToolbarItem(placement: .keyboard) {
                Button("Hide Keypad") { textIsFocused = false }
            }
        }
        .onChange(of: scalePct) {
            if scalePct < 1 { scalePct = 1 }
        }
    }
}

#Preview {
    @Previewable @State var scalePct = 100
    ScalePicker(scalePct: $scalePct)
}
