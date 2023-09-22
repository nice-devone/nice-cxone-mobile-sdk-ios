import SwiftUI

struct PaymentDoneView: View {
    
    // MARK: - Properties
    
    let viewModel: PaymentDoneViewModel
    
    // MARK: - Builder
    
    var body: some View {
        VStack {
            Asset.Common.success
                .resizable()
                .frame(width: 100, height: 100)
                .foregroundColor(.green)
                .padding(.bottom, 24)
            
            Text(L10n.PurchaseDone.message)
                .font(.headline)
                .multilineTextAlignment(.center)
                .padding(.bottom, 40)
            
            Button {
                viewModel.popToStore()
            } label: {
                Text(L10n.PurchaseDone.backToStore)
                    .fontWeight(.bold)
            }
            .frame(maxWidth: 250)
            .buttonStyle(PrimaryButtonStyle())
        }
        .padding(.horizontal, 24)
        .onAppear(perform: viewModel.onAppear)
        .navigationBarBackButtonHidden()
    }
}

// MARK: - Preview

// swiftlint:disable force_unwrapping
struct PaymentDoneView_Previews: PreviewProvider {
    
    private static let coordinator = LoginCoordinator(navigationController: UINavigationController())
    private static var appModule = PreviewAppModule(coordinator: coordinator) {
        didSet {
            coordinator.assembler = appModule.assembler
        }
    }
    
    static var previews: some View {
        Group {
            appModule.resolver.resolve(PaymentDoneView.self)!
                .previewDisplayName("Light Mode")
            
            appModule.resolver.resolve(PaymentDoneView.self)!
                .preferredColorScheme(.dark)
                .previewDisplayName("Dark Mode")
        }
    }
}
