import SwiftUI

struct PrimaryButtonStyle: ButtonStyle {
    
    func makeBody(configuration: ButtonStyle.Configuration) -> some View {
        configuration.label
            .adjustForA11y()
            .frame(maxWidth: .infinity)
            .foregroundColor(.white)
            .background(configuration.isPressed ? UIColor.primaryButtonColor.withAlphaComponent(0.8).color : UIColor.primaryButtonColor.color)
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
