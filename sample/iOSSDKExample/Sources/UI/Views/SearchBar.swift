import SwiftUI

struct SearchBar: View {

    // MARK: - Properties
    
    @Binding var text: String
    
    // MARK: - Builder
    
    var body: some View {
        HStack(spacing: 16) {
            HStack {
                Asset.Store.search
                    .foregroundColor(Color(.systemGray2))
                
                TextField(L10n.Common.search, text: $text)
                    .autocorrectionDisabled()
                    .autocapitalization(.none)
                
                if !text.isEmpty {
                    Asset.Common.clear
                        .imageScale(.medium)
                        .foregroundColor(Color(.systemGray2))
                        .onTapGesture {
                            withAnimation {
                                self.text = ""
                            }
                        }
                }
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(.systemGray6))
            )
            .animation(.spring(), value: text)
            
            if !text.isEmpty {
                Button(L10n.Common.cancel) {
                    withAnimation {
                        self.text = ""
                    }
                    
                    self.hideKeyboard()
                }
            }
        }
        .padding()
    }
}

// MARK: - Preview

struct SearchBar_Previews: PreviewProvider {
    
    @State private static var searchText = ""
    
    static var previews: some View {
        Group {
            SearchBar(text: $searchText)
                .previewDisplayName("Light Mode")
            
            SearchBar(text: $searchText)
                .preferredColorScheme(.dark)
                .previewDisplayName("Dark Mode")
        }
    }
}
