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

struct GridStack<Content>: View where Content: View {
    
    // MARK: - Properties
    
    private let gridCalculator = GridCalculator()
    
    private let minCellWidth: CGFloat
    private let spacing: CGFloat
    private let numItems: Int
    private let alignment: HorizontalAlignment
    private let content: (_ index: Int) -> Content
    
    var items: [Int] {
        Array(0..<numItems).map { $0 }
    }
    
    // MARK: - Init
    
    init(
        minCellWidth: CGFloat,
        spacing: CGFloat,
        numItems: Int,
        alignment: HorizontalAlignment = .leading,
        @ViewBuilder content: @escaping (_ index: Int) -> Content
    ) {
        self.minCellWidth = minCellWidth
        self.spacing = spacing
        self.numItems = numItems
        self.alignment = alignment
        self.content = content
    }
    
    // MARK: - Builder
    
    var body: some View {
        GeometryReader { geometry in
            InnerGrid(
                width: geometry.size.width,
                spacing: self.spacing,
                items: self.items,
                alignment: self.alignment,
                content: self.content,
                gridDefinition: self.gridCalculator.calculate(
                    availableWidth: geometry.size.width,
                    minimumCellWidth: self.minCellWidth,
                    cellSpacing: self.spacing
                )
            )
        }
    }
}

// MARK: - Private Views

private struct InnerGrid<Content>: View where Content: View {
    
    // MARK: - Properties
    
    private let width: CGFloat
    private let spacing: CGFloat
    private let rows: [[Int]]
    private let alignment: HorizontalAlignment
    private let content: (Int) -> Content
    private let columnWidth: CGFloat
    
    // MARK: - Init
    
    init(
        width: CGFloat,
        spacing: CGFloat,
        items: [Int],
        alignment: HorizontalAlignment = .leading,
        @ViewBuilder content: @escaping (Int) -> Content,
        gridDefinition: GridCalculator.GridDefinition
    ) {
        self.width = width
        self.spacing = spacing
        self.alignment = alignment
        self.content = content
        self.columnWidth = gridDefinition.columnWidth
        rows = items.chunked(into: gridDefinition.columnCount)
    }
    
    // MARK: - Builder
    
    var body: some View {
        ScrollView(.vertical) {
            VStack(alignment: alignment, spacing: spacing) {
                if self.columnWidth > 0 {
                    ForEach(rows, id: \.self) { row in
                        HStack(alignment: .top, spacing: self.spacing) {
                            ForEach(row, id: \.self) { item in
                                self.content(item)
                                    .frame(width: self.columnWidth)
                            }
                        }
                        .padding(.horizontal, self.spacing)
                    }
                }
            }
            .padding(.top, spacing)
            .frame(width: width)
        }
    }
}

// MARK: - Helpers

private struct GridCalculator {
    
    // MARK: - Typealiases
    
    typealias GridDefinition = (columnWidth: CGFloat, columnCount: Int)
    
    // MARK: - Methods
    
    func calculate(availableWidth: CGFloat, minimumCellWidth: CGFloat, cellSpacing: CGFloat) -> GridDefinition {
        guard availableWidth != 0 else {
            return (columnWidth: 0, columnCount: 0)
        }
        
        let columnsThatFit = Int((availableWidth - cellSpacing) / (minimumCellWidth + cellSpacing))
        let columnCount = max(1, columnsThatFit)
        let totalSpacing = CGFloat((columnCount + 1)) * cellSpacing
        let remainingWidth = availableWidth - totalSpacing
        
        return (
            columnWidth: remainingWidth / CGFloat(columnCount),
            columnCount: columnCount
        )
    }
}

private extension Array {
    
    func chunked(into size: Int) -> [[Element]] {
        guard size > 0 else {
            return [self]
        }
        
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}
