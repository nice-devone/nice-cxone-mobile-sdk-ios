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

struct SettingsView: View {

    // MARK: - Properties

    @ObservedObject var viewModel: SettingsViewModel

    // MARK: - Content

    var body: some View {
        Form {
            sdkInfoSectionView

            logsSectionView

            brandLogoSectionView

            themeColorSectionView
        }
        .navigationBarTitle(L10n.Settings.title)
    }
}

// MARK: - Subviews

private extension SettingsView {
    
    var sdkInfoSectionView: some View {
        Section(header: Text(L10n.Settings.Sdk.title)) {
            HStack {
                Text(L10n.Settings.Sdk.version)

                Spacer()

                Text(viewModel.sdkVersion)
                    .font(Font.body.bold())
            }
        }
    }

    var logsSectionView: some View {
        Section(header: Text(L10n.Settings.Logs.title)) {
            HStack {
                Text(L10n.Settings.Logs.Share.label)

                Spacer()

                Button(L10n.Settings.Logs.Share.button) {
                    viewModel.shouldShareLogs.toggle()
                }
                .sheet(isPresented: $viewModel.shouldShareLogs) {
                    SettingsShareLogsDialogView()
                }
            }
            HStack {
                Text(L10n.Settings.Logs.Remove.label)

                Spacer()

                Button(L10n.Settings.Logs.Remove.button) {
                    viewModel.showRemoveLogsAlert = true
                }
                .alert(isPresented: $viewModel.showRemoveLogsAlert) {
                    Alert(title: Text(L10n.Settings.Logs.Remove.label), message: Text(viewModel.removeLogs()))
                }
            }
        }
    }

    var brandLogoSectionView: some View {
        Section(header: Text(L10n.Settings.BrandLogo.title)) {
            Text(L10n.Settings.BrandLogo.label)

            HStack {
                Spacer()

                viewModel.brandLogoImage()
                    .resizable()
                    .scaledToFill()
                    .frame(width: 50, height: 50, alignment: .center)
                    .foregroundColor(.blue)
                    .onTapGesture {
                        viewModel.presentingBrandLogoActionSheet.toggle()
                    }

                Spacer()
            }
            .actionSheet(isPresented: $viewModel.presentingBrandLogoActionSheet) {
                ActionSheet(
                    title: Text(L10n.FileLoader.title),
                    buttons: [
                        .default(Text(L10n.FileLoader.imageFromLibrary)) {
                            viewModel.showingImagePicker.toggle()
                        },
                        .default(Text(L10n.FileLoader.fileManager)) {
                            viewModel.showingFileManager.toggle()
                        },
                        .cancel()
                    ]
                )
            }
            .sheet(isPresented: $viewModel.showingFileManager) {
                SettingsFilePickerView(image: $viewModel.brandLogo)
            }
            .sheet(isPresented: $viewModel.showingImagePicker) {
                SettingsImagePickerView(image: $viewModel.brandLogo)
            }
        }
    }

    var themeColorSectionView: some View {
        Section(header: Text(L10n.Settings.Theme.title)) {
            Text(L10n.Settings.Theme.info)

            SettingsThemeColorView(
                color: viewModel.navigationBarColor,
                title: L10n.Settings.Theme.ChatNavigationBarColorField.placeholder
            ) { fieldTitle, color in
                viewModel.colorDidChange(color: color, for: fieldTitle)
            }

            SettingsThemeColorView(
                color: viewModel.navigationElementsColor,
                title: L10n.Settings.Theme.ChatNavigationElementsColorField.placeholder
            ) { fieldTitle, color in
                viewModel.colorDidChange(color: color, for: fieldTitle)
            }

            SettingsThemeColorView(
                color: viewModel.backgroundColor,
                title: L10n.Settings.Theme.ChatBackgroundColorField.placeholder
            ) { fieldTitle, color in
                viewModel.colorDidChange(color: color, for: fieldTitle)
            }

            SettingsThemeColorView(
                color: viewModel.agentCellColor,
                title: L10n.Settings.Theme.ChatAgentCellColorField.placeholder
            ) { fieldTitle, color in
                viewModel.colorDidChange(color: color, for: fieldTitle)
            }

            SettingsThemeColorView(
                color: viewModel.customerCellColor,
                title: L10n.Settings.Theme.ChatCustomerCellColorField.placeholder
            ) { fieldTitle, color in
                viewModel.colorDidChange(color: color, for: fieldTitle)
            }

            SettingsThemeColorView(
                color: viewModel.agentFontColor,
                title: L10n.Settings.Theme.ChatAgentFontColorField.placeholder
            ) { fieldTitle, color in
                viewModel.colorDidChange(color: color, for: fieldTitle)
            }

            SettingsThemeColorView(
                color: viewModel.customerFontColor,
                title: L10n.Settings.Theme.ChatCustomerFontColorField.placeholder
            ) { fieldTitle, color in
                viewModel.colorDidChange(color: color, for: fieldTitle)
            }
        }
    }
}

// MARK: - Previews

struct SettingsView_Previews: PreviewProvider {
    
    static private let coordinator = LoginCoordinator(navigationController: UINavigationController())
    static private let appModule = PreviewAppModule(coordinator: coordinator)

    static var previews: some View {
        Group {
            NavigationView {
                // swiftlint:disable:next force_unwrapping
                appModule.resolver.resolve(SettingsView.self)!
            }
            .preferredColorScheme(.light)
            .previewDisplayName("Light Mode")

            NavigationView {
                // swiftlint:disable:next force_unwrapping
                appModule.resolver.resolve(SettingsView.self)!
            }
            .preferredColorScheme(.dark)
            .previewDisplayName("Dark Mode")
        }
    }
}
