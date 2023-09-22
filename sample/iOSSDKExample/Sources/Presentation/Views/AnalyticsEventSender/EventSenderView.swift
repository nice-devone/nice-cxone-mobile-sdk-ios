import CXoneChatSDK
import SwiftUI

struct EventSenderView<Content: View>: View {
    
    // MARK: - Properties

    let label: String
    let action: () -> Void
    let enabled: () -> Bool
    @ViewBuilder let content: () -> Content

    // MARK: - Content

    var body: some View {
        NavigationLink(label) {
            VStack {
                content()

                Button(action: action) {
                    Text("Send")
                }
                .disabled(!enabled())
                .padding(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(.black)
                )

                Spacer()
            }
            .navigationBarTitle(label)
            .padding()
        }
    }
}
