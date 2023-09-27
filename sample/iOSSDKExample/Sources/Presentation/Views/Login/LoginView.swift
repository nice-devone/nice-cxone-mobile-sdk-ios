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

import CXoneChatSDK
import SwiftUI

struct LoginView: View {
    
    // MARK: - Properties
    
    @ObservedObject var viewModel: LoginViewModel
    
    // MARK: - Builder
    
    var body: some View {
        LoadingView(isVisible: $viewModel.isLoading, isTransparent: $viewModel.isLoadingTransparent) {
            VStack(alignment: .center) {
                Text(L10n.Login.Oauth.availableProvidersTitle)
                    .fontWeight(.bold)
                    .font(.caption)
                    .foregroundColor(Color(.systemGray))
                
                Button {
                    viewModel.invokeLoginWithAmazon()
                } label: {
                    Asset.OAuth.loginWithAmazon.swiftUIImage
                }
                
                guestLoginDivider
                
                Text(L10n.Login.Guest.buttonTitle)
                    .fontWeight(.bold)
                    .frame(maxWidth: 210)
                    .adjustForA11y()
                    .foregroundColor(.white)
                    .background(Color(.primaryButtonColor))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .onTapGesture {
                        viewModel.navigateToStore()
                    }
            }
        }
        .onAppear(perform: viewModel.onAppear)
        .alert(isPresented: $viewModel.shouldShowError) {
            Alert.genericError
        }
        .navigationBarTitle(L10n.Login.title)
        .navigationBarItems(
            leading: Button(
                action: {
                    viewModel.signOut()
                }, label: {
                    Asset.Common.disconnect
                        .opacity(viewModel.isLoading ? 0 : 1)
                }),
            trailing: Button(
                action: {
                    viewModel.navigateToSettings()
                }, label: {
                    Asset.Common.settings
                        .opacity(viewModel.isLoading ? 0 : 1)
                }
            )
        )
    }
}

// MARK: - Subviews

private extension LoginView {
    
    var guestLoginDivider: some View {
        HStack {
            VStack {
                Divider()
                    .background(Color(.systemGray2))
            }
            .padding(.horizontal, 20)
            
            Text(L10n.Login.Guest.dividerTitle)
                .font(.headline)
                .foregroundColor(Color(.systemGray2))
            
            VStack {
                Divider()
                    .background(Color(.systemGray2))
            }
            .padding(.horizontal, 20)
        }
    }
}

// MARK: - Preview

// swiftlint:disable force_unwrapping
struct LoginView_Previews: PreviewProvider {
    
    private static let coordinator = LoginCoordinator(navigationController: UINavigationController())
    private static var appModule = PreviewAppModule(coordinator: coordinator) {
        didSet {
            coordinator.assembler = appModule.assembler
        }
    }
    private static let viewModel = LoginViewModel(
        coordinator: coordinator,
        configuration: Configuration(
            brandId: 1386,
            channelId: "chat_51eafb4e-8829-4efe-b58c-3bc9febf18c4",
            environment: .NA1
        ),
        deeplinkOption: nil,
        loginWithAmazon: appModule.resolver.resolve(LoginWithAmazonUseCase.self)!,
        getChannelConfiguration: appModule.resolver.resolve(GetChannelConfigurationUseCase.self)!
    )
    
    static var previews: some View {
        Group {
            NavigationView {
                LoginView(viewModel: viewModel)
            }
            .previewDisplayName("Light Mode")
            
            NavigationView {
                LoginView(viewModel: viewModel)
            }
            .preferredColorScheme(.dark)
            .previewDisplayName("Dark Mode")
        }
    }
}
