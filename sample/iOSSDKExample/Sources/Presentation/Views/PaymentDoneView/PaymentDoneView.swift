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
