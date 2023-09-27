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
import Swinject

struct ConfigurationView: View {
    
    // MARK: - Properties
    
    @State private var isShowingEnvironmentsSheet = false
    @State private var isShowingConfigurationsSheet = false
    
    @ObservedObject var viewModel: ConfigurationViewModel
    
    // MARK: - Builder
    
    var body: some View {
        VStack {
            Spacer()
            
            if viewModel.isDefaultConfigurationHidden {
                customConfigurationSection
                    .transition(.opacity)
            } else {
                defaultConfigurationSection
                    .transition(.opacity)
            }
            
            Button(viewModel.isDefaultConfigurationHidden ? L10n.Configuration.Default.buttonTitle : L10n.Configuration.Custom.buttonTitle) {
                withAnimation {
                    viewModel.isDefaultConfigurationHidden.toggle()
                }
            }
            .padding(.vertical, 24)
            
            Button {
                viewModel.onConfirmButtonTapped()
            } label: {
                Text(L10n.Common.continue)
                    .fontWeight(.bold)
            }
            .buttonStyle(PrimaryButtonStyle())
            .padding(.bottom, 10)
            .alert(isPresented: $viewModel.isShowingInvalidFieldsAlert) {
                Alert(
                    title: Text(L10n.Configuration.Default.MissingFields.title),
                    message: Text(L10n.Configuration.Default.MissingFields.message)
                )
            }
        }
        .background(UIColor.systemBackground.color)
        .padding(.horizontal, 24)
        .onAppear(perform: viewModel.onAppear)
        .animation(.easeInOut(duration: 0.2))
        .navigationBarTitle(L10n.Configuration.title)
        .navigationBarBackButtonHidden()
        .navigationBarItems(
            trailing: Button(
                action: {
                    viewModel.navigateToSettings()
                }, label: {
                    Asset.Common.settings
                }
            )
        )
    }
}

// MARK: - Subviews

private extension ConfigurationView {
    
    var defaultConfigurationSection: some View {
        VStack {
            HStack {
                Text(L10n.Configuration.environmentSelectionTitle)
                
                Spacer()
                
                Button(viewModel.environment.rawValue) {
                    isShowingConfigurationsSheet = true
                }
                .actionSheet(isPresented: $isShowingConfigurationsSheet) {
                    var options: [ActionSheet.Button] = CXoneChatSDK.Environment.allCases
                        .map { option in
                                .default(Text(option.rawValue)) { viewModel.environment = option }
                        }
                    options.append(.cancel())
                    
                    return ActionSheet(
                        title: Text(L10n.Configuration.environmentSelectionTitle),
                        buttons: options
                    )
                }
            }
            
            ValidatedTextField(
                "1234",
                text: $viewModel.brandId,
                validator: allOf(required, numeric),
                label: L10n.Configuration.Default.brandIdPlaceholder
            )
            .keyboardType(.numberPad)
            .padding(.top, 24)
            
            ValidatedTextField(
                "chat_e11131fa...",
                text: $viewModel.channelId,
                validator: required,
                label: L10n.Configuration.Default.channelIdPlaceholder
            )
            .padding(.top, 10)
        }
    }

    var customConfigurationSection: some View {
        HStack {
            Text(L10n.Configuration.configurationSelectionTitle)
            
            Spacer()
            
            Button(viewModel.customConfiguration.title) {
                isShowingEnvironmentsSheet = true
            }
            .actionSheet(isPresented: $isShowingEnvironmentsSheet) {
                var options: [ActionSheet.Button] = viewModel.configurations
                    .map { option in
                        .default(Text(option.title)) { viewModel.customConfiguration = option }
                    }
                options.append(.cancel())
                
                return ActionSheet(
                    title: Text(L10n.Configuration.environmentSelectionTitle),
                    buttons: options
                )
            }
        }
    }
}

// MARK: - Preview

// swiftlint:disable force_unwrapping
struct ConfigurationView_Previews: PreviewProvider {
    
    private static let coordinator = LoginCoordinator(navigationController: UINavigationController())
    private static var appModule = PreviewAppModule(coordinator: coordinator) {
        didSet {
            coordinator.assembler = appModule.assembler
        }
    }
    
    static var previews: some View {
        Group {
            NavigationView {
                appModule.resolver.resolve(ConfigurationView.self)!
            }
            .previewDisplayName("Light Mode")
            
            NavigationView {
                appModule.resolver.resolve(ConfigurationView.self)!
            }
            .preferredColorScheme(.dark)
            .previewDisplayName("Dark Mode")
        }
    }
}
