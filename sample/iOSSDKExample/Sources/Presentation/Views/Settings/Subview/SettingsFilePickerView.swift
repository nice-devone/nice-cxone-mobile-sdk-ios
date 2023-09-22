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
