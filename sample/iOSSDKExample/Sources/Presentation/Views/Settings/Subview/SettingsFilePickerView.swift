//
// Copyright (c) 2021-2023. NICE Ltd. All rights reserved.
//
// Licensed under the NICE License;
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    https://github.com/nice-devone/nice-cxone-mobile-sdk-ios/blob/main/LICENSE
//
// TO THE EXTENT PERMITTED BY APPLICABLE LAW, THE CXONE MOBILE SDK IS PROVIDED ON
// AN “AS IS” BASIS. NICE HEREBY DISCLAIMS ALL WARRANTIES AND CONDITIONS, EXPRESS
// OR IMPLIED, INCLUDING (WITHOUT LIMITATION) WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE, NON-INFRINGEMENT, AND TITLE.
//

import SwiftUI
import UniformTypeIdentifiers

struct SettingsFilePickerView: UIViewControllerRepresentable {

    // MARK: - Properties

    @Environment(\.presentationMode) var presentationMode

    @Binding var image: UIImage?
    
    // MARK: - Body

    class Coordinator: NSObject, UIDocumentPickerDelegate {
        
        let parent: SettingsFilePickerView

        init(_ parent: SettingsFilePickerView) {
            self.parent = parent
        }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let imageUrl = urls.first, imageUrl.startAccessingSecurityScopedResource() else {
                Log.error(.failed("Unable to access image url."))
                return
            }
            
            defer {
                imageUrl.stopAccessingSecurityScopedResource()
            }
            
            do {
                let data = try Data(contentsOf: imageUrl)
                try FileManager.default.storeFileData(data, named: "brandLogo.png", in: .documentDirectory)
                
                if let uiImage = UIImage(data: data) {
                    parent.image = uiImage
                }
            } catch {
                error.logError()
            }
            
            parent.presentationMode.wrappedValue.dismiss()
        }

        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }

    // MARK: - Functions

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker: UIDocumentPickerViewController
        
        if #available(iOS 14.0, *) {
            picker = UIDocumentPickerViewController(forOpeningContentTypes: [.image])
        } else {
            picker = UIDocumentPickerViewController(documentTypes: ["public.image"], in: .import)
        }
        
        picker.allowsMultipleSelection = false
        picker.delegate = context.coordinator
        
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) { }
}
