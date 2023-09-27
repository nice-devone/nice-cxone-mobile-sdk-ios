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

struct CartSummaryView: View {
    
    // MARK: - Properties
    
    @Binding var totalAmount: Double
    var onCheckout: () -> Void
    
    // MARK: - Builder
    
    var body: some View {
        VStack(spacing: 8) {
            Text(L10n.Cart.Summary.title)
                .boldHeadline(foregroundColor: .gray)
                .padding(.bottom, 10)
            
            HStack(alignment: .top) {
                Text(L10n.Cart.Summary.totalTitle)
                    .boldHeadline(foregroundColor: .gray)
                
                Spacer()
                
                HStack(alignment: .top, spacing: 2) {
                    Text("$")
                        .font(.headline)
                    
                    Text(String(format: "%0.2f", $totalAmount.wrappedValue))
                        .font(.title)
                        .fontWeight(.bold)
                        .animation(.spring())
                }
            }
            
            HStack(alignment: .top) {
                Text(L10n.Cart.Summary.Vat.title)
                    .boldHeadline(foregroundColor: .gray)
                
                Spacer()
                
                Text(L10n.Cart.Summary.Vat.included)
                    .boldHeadline(foregroundColor: .accentColor)
            }
            
            HStack(alignment: .top) {
                Text(L10n.Cart.Summary.Shipping.title)
                    .boldHeadline(foregroundColor: .gray)
                
                Spacer()
                
                Text(L10n.Cart.Summary.Shipping.free)
                    .boldHeadline(foregroundColor: .accentColor)
            }
            
            Button {
                onCheckout()
            } label: {
                Text(L10n.Cart.Summary.Checkout.title)
                    .fontWeight(.bold)
            }
            .buttonStyle(PrimaryButtonStyle())
            .padding(.top, 24)
        }
        .padding([.top, .leading, .trailing], 16)
        .padding(.bottom, UIDevice.hasBottomSafeAreaInsets ? 32 : 16)
        .background(Color(.systemGray6))
        .cornerRadius(20, corners: [.topLeft, .topRight])
        .padding(.top, -14)
        .shadow(color: .black.opacity(0.1), radius: 4, y: -4)
    }
}

// MARK: - Helpers

private extension Text {

    func boldHeadline(foregroundColor: Color) -> some View {
        self
            .font(.headline)
            .fontWeight(.bold)
            .foregroundColor(foregroundColor)
    }
}

// MARK: - Preview

struct CartSummaryView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            VStack {
                Spacer()
                
                CartSummaryView(totalAmount: .constant(2500)) { }
            }
            .edgesIgnoringSafeArea(.bottom)
            .previewDisplayName("Light Mode")
            
            VStack {
                Spacer()
                
                CartSummaryView(totalAmount: .constant(2500)) { }
            }
            .edgesIgnoringSafeArea(.bottom)
            .preferredColorScheme(.dark)
            .previewDisplayName("Dark Mode")
        }
    }
}
