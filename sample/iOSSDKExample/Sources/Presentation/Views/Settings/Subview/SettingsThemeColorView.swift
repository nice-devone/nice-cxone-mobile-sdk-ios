import SwiftUI

struct SettingsThemeColorView: View {
    
    // MARK: - Properties

    @State private var colorCodeString: String
    
    private let title: String
    private let didUpdateColor: (String, UIColor) -> Void

    // MARK: - Content

    init(color: UIColor, title: String, didUpdateColor: @escaping (String, UIColor) -> Void) {
        self.title = title
        self.didUpdateColor = didUpdateColor
        
        _colorCodeString = State(initialValue: color.toHexString)
    }
    
    // MARK: - Builder
    
    var body: some View {
        HStack {
            VStack {
                Text(title)
                    .font(Font.footnote.weight(.light))
                    .frame(maxWidth: .infinity, alignment: .leading)

                TextField("", text: $colorCodeString) { isEditing in
                    guard !isEditing, let color = UIColor(hexString: colorCodeString) else {
                        return
                    }
                    
                    didUpdateColor(title, color)
                }
            }

            Spacer()

            Color(hex: colorCodeString)
                .frame(width: 50, height: 25, alignment: .trailing)
                .border(.black)
        }
    }
}

// MARK: - Previews

struct SettingsThemeColorView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsThemeColorView(color: .red, title: "Title") { _, _ in }
            .preferredColorScheme(.dark)
            .previewDisplayName("Dark Mode")
            .previewLayout(.sizeThatFits)
            .padding()

        SettingsThemeColorView(color: .red, title: "Title") { _, _ in }
            .previewDisplayName("Light Mode")
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
