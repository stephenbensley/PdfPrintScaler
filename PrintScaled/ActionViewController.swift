//
// Copyright 2024 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/PdfPrintScaler/blob/main/LICENSE.
//

import SwiftUI
import UIKit
import UniformTypeIdentifiers

struct ContentView: View {
    private let url: URL
    private let dismiss: () -> Void
    @State private var pdf: ScalablePdf?
    
    init(url: URL, dismiss: @escaping () -> Void) {
        self.url = url
        self.dismiss = dismiss
    }
    
    var body: some View {
        Group {
            if let pdf = pdf {
                ScalablePdfView(pdf: pdf, dismiss: dismiss)
            } else {
                ProgressView()
            }
        }
        .onAppear {
             if let pdf = ScalablePdf(url: url) {
                self.pdf = pdf
            } else {
                dismiss()
            }
        }
    }
}

final class ActionViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name("close"),
            object: nil,
            queue: nil
        ) { _ in
            DispatchQueue.main.async {
                self.close()
            }
        }
        
        guard let extensionItem = extensionContext?.inputItems.first as? NSExtensionItem,
              let itemProvider = extensionItem.attachments?.first else {
            return close()
        }
        
        itemProvider.loadItem(forTypeIdentifier: UTType.pdf.identifier) { (item, _) in
            guard let url = item as? URL else { return Self.postClose() }
            self.performAction(on: url)
        }
    }
    
    private func close() {
        extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
    }
    
    nonisolated static func postClose() {
        NotificationCenter.default.post(name: NSNotification.Name("close"), object: nil)
    }
    
    nonisolated private func performAction(on url: URL) {
        DispatchQueue.main.async {
            let ctrl = UIHostingController(rootView: ContentView(url: url, dismiss: Self.postClose))
            self.addChild(ctrl)
            self.view.addSubview(ctrl.view)
            
            ctrl.view.translatesAutoresizingMaskIntoConstraints = false
            ctrl.view.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
            ctrl.view.bottomAnchor.constraint (equalTo: self.view.bottomAnchor).isActive = true
            ctrl.view.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
            ctrl.view.rightAnchor.constraint (equalTo: self.view.rightAnchor).isActive = true
        }
    }
}
