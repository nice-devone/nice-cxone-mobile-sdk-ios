import SwiftUI

struct SettingsShareLogsDialogView: UIViewControllerRepresentable {

    // MARK: - Properties

    typealias UIViewControllerType = UIActivityViewController

    // MARK: - Functions

    func makeUIViewController(context: Context) -> UIActivityViewController {
        guard let activityView = try? Log.getLogShareDialog() else {
            return UIActivityViewController(activityItems: [], applicationActivities: nil)
        }
        return activityView
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) { }
}
