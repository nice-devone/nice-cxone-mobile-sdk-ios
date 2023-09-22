import CXoneChatSDK
import SwiftUI

struct ConversionSenderView: View {
    
    // MARK: - Properties

    let analyticsProvider: AnalyticsProvider
    @State var type: String = ""
    @State var value: String = ""

    // MARK: - Content

    var body: some View {
        EventSenderView(
            label: "Conversion") {
                guard let value = Double(value) else {
                    return
                }
                
                Task {
                    do {
                        try await analyticsProvider.conversion(type: type, value: value)
                    } catch {
                        error.logError()
                    }
                }
            } enabled: {
                !type.isEmpty && Double(value) != nil
            } content: {
                ValidatedTextField("Type", text: $type, validator: required)
                
                ValidatedTextField("Value", text: $value, validator: allOf(required, numeric))
                    .keyboardType(.decimalPad)
            }
    }
}
