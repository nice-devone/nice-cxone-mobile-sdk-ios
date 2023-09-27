//
// Copyright (c) 2021-2023. NICE Ltd. All rights reserved.
//
// Licensed under the NICE License;
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    https://github.com/nice-devone/nice-cxone-mobile-sdk-ios/blob/main/LICENSE
//
// TO THE EXTENT PERMITTED BY APPLICABLE LAW, THE CXONE MOBILE SDK IS PROVIDED ON
// AN “AS IS” BASIS. NICE HEREBY DISCLAIMS ALL WARRANTIES AND CONDITIONS, EXPRESS
// OR IMPLIED, INCLUDING (WITHOUT LIMITATION) WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE, NON-INFRINGEMENT, AND TITLE.
//

import SwiftUI

struct PaymentView: View {
    
    // MARK: - Properties
    
    @ObservedObject var viewModel: PaymentViewModel
    
    // MARK: - Builder
    
    var body: some View {
        LoadingView(isVisible: $viewModel.isLoading, isTransparent: .constant(true)) {
            VStack(alignment: .leading) {
                Text(L10n.Payment.cardNumberTitle)
                    .font(.headline)
                    .foregroundColor(.gray)
                    .padding(.top, 24)
                
                HStack(spacing: 16) {
                    Asset.masterCard.swiftUIImage
                        .resizable()
                        .scaledToFit()
                        .frame(width: 64, height: 44)
                    
                    Text("**** **** **** 4759")
                        .fontWeight(.bold)
                        .foregroundColor(.gray)
                    
                    Spacer()
                }
                .grayRoundedRectangleWithPadding(vertical: 6, horizontal: 16)
                
                HStack(alignment: .center, spacing: 24) {
                    VStack(alignment: .leading) {
                        Text(L10n.Payment.validUntilTitle)
                            .font(.headline)
                            .foregroundColor(.gray)
                        
                        Text(viewModel.validUntil)
                            .fontWeight(.bold)
                            .foregroundColor(.gray)
                            .grayRoundedRectangleWithPadding(vertical: 10, horizontal: 0)
                    }
                    
                    VStack(alignment: .leading) {
                        Text(L10n.Payment.ccvTitle)
                            .font(.headline)
                            .foregroundColor(.gray)
                        
                        Text("***")
                            .fontWeight(.bold)
                            .foregroundColor(.gray)
                            .grayRoundedRectangleWithPadding(vertical: 10, horizontal: 0)
                    }
                }
                
                VStack(alignment: .leading) {
                    Text(L10n.Payment.cardHolderNameTitle)
                        .font(.headline)
                        .foregroundColor(.gray)
                    
                    Text("John Doe")
                        .fontWeight(.bold)
                        .foregroundColor(.gray)
                        .grayRoundedRectangleWithPadding(vertical: 10, horizontal: 0)
                }
                
                Spacer()
                
                HStack(alignment: .center) {
                    Spacer()
                    
                    Text(L10n.Payment.totalAmountTitle)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.gray)
                    
                    HStack(alignment: .top, spacing: 2) {
                        Text("$")
                            .font(.headline)
                        
                        Text(String(format: "%0.2f", viewModel.totalAmount))
                            .font(.title)
                            .fontWeight(.bold)
                    }
                    
                    Spacer()
                }
                
                Button {
                    Task { @MainActor in
                        await viewModel.checkout()
                    }
                } label: {
                    Text(L10n.Payment.confirmationButtonTitle)
                        .fontWeight(.bold)
                }
                .buttonStyle(PrimaryButtonStyle())
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .transition(.opacity)
        .onAppear(perform: viewModel.onAppear)
        .navigationBarTitle(viewModel.isLoading ? "" : L10n.Payment.title)
    }
}

// MARK: - Helper

private extension View {
    
    func grayRoundedRectangleWithPadding(vertical: CGFloat, horizontal: CGFloat) -> some View {
        self
            .frame(maxWidth: .infinity)
            .padding(.vertical, vertical)
            .padding(.horizontal, horizontal)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(.systemGray5))
            )
    }
}

// MARK: - Preview

// swiftlint:disable force_unwrapping
struct PaymentView_Previews: PreviewProvider {
    
    private static let coordinator = LoginCoordinator(navigationController: UINavigationController())
    private static var appModule = PreviewAppModule(coordinator: coordinator) {
        didSet {
            coordinator.assembler = appModule.assembler
        }
    }
    
    static var previews: some View {
        Group {
            NavigationView {
                appModule.resolver.resolve(PaymentView.self)!
            }
            .previewDisplayName("Light Mode")
            
            NavigationView {
                appModule.resolver.resolve(PaymentView.self)!
            }
            .preferredColorScheme(.dark)
            .previewDisplayName("Dark Mode")
        }
    }
}
