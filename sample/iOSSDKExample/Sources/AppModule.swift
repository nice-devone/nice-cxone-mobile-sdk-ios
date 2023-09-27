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

import Swinject

class AppModule {

    // MARK: - Properties
    
    private let coordinator: LoginCoordinator
    
    private let mainAssembly: Assembly
    private let container = Swinject.Container()
    
    private(set) var assembler: Assembler

    let resolver: Swinject.Resolver
    
    // MARK: - Init
    
    init(coordinator: LoginCoordinator) {
        self.coordinator = coordinator
        self.mainAssembly = AppAssembly(coordinator: coordinator)
        self.assembler = Assembler(container: container)
        
        assembler.apply(assembly: self.mainAssembly)
        resolver = container.synchronize()
    }
}

// MARK: - Preview

class PreviewAppModule {

    // MARK: - Properties
    
    private let coordinator: LoginCoordinator
    
    private let mainAssembly: Assembly
    private let container = Swinject.Container()
    
    private(set) var assembler: Assembler

    let resolver: Swinject.Resolver
    
    // MARK: - Init
    
    init(coordinator: LoginCoordinator) {
        self.coordinator = coordinator
        self.mainAssembly = PreviewAppAssembly(coordinator: coordinator)
        self.assembler = Assembler(container: container)
        
        assembler.apply(assembly: self.mainAssembly)
        resolver = container.synchronize()
    }
}
