import CXoneChatSDK
import SwiftUI

struct EventSenderListView: View {
    
    // MARK: - Properties

    let analyticsProvider: AnalyticsProvider
    let done: () -> Void

    // MARK: - Content

    var body: some View {
        VStack {
            NavigationView {
                List {
                    PageViewSenderView(analyticsProvider: analyticsProvider)
                        .adjustForA11y()
                    ConversionSenderView(analyticsProvider: analyticsProvider)
                        .adjustForA11y()
                }
                .listStyle(.plain)
                .navigationBarTitle("Send Events")
            }
            Spacer()
            Button("Cancel", action: done)
        }
    }
}

// MARK: - Preview

struct EventSenderListView_Previews: PreviewProvider {
    static var previews: some View {
        EventSenderListView(analyticsProvider: PreviewAnalyticsProvider()) {}
    }
}
