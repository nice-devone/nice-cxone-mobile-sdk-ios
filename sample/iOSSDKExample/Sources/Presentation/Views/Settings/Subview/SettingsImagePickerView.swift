import SwiftUI
import UIKit

struct SettingsImagePickerView: UIViewControllerRepresentable {
    
    // MARK: - Properties

    @Environment(\.presentationMode) var presentationMode
    
    @Binding var image: UIImage?

    // MARK: - Body

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        
        let parent: SettingsImagePickerView
        
        init(_ parent: SettingsImagePickerView) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let editedImage = info[.editedImage] as? UIImage {
                parent.image = editedImage
            } else if let originalImage = info[.originalImage] as? UIImage {
                parent.image = originalImage
            }
            
            if let data = parent.image?.pngData() {
                do {
                    try FileManager.default.storeFileData(data, named: "brandLogo.png", in: .documentDirectory)
                } catch {
                    error.logError()
                }
            }
            
            parent.presentationMode.wrappedValue.dismiss()
        }
    }

    // MARK: - Functions
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<SettingsImagePickerView>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) { }
}
