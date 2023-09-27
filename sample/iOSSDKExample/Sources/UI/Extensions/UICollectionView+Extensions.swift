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

import UIKit

extension UICollectionView {
    
    // MARK: - Properties
    
    // MessageKit puts each message into a new section.
    var indexPathForLastItem: IndexPath? {
        guard numberOfSections > 0 else {
            return nil
        }

        return IndexPath(item: 0, section: numberOfSections - 1)
    }
    
    // MARK: - Methods
    
    func dequeue<T: UICollectionViewCell>(for indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withReuseIdentifier: T.reuseIdentifier, for: indexPath) as? T else {
            fatalError("Error: cell with id: \(T.reuseIdentifier) for indexPath: \(indexPath) is not \(T.self)")
        }
        
        return cell
    }
    
    func register<T: UICollectionViewCell>(cell: T.Type) {
        register(cell, forCellWithReuseIdentifier: cell.reuseIdentifier)
    }
    
    func refreshSectionToAddNewItem(_ index: Int) {
        self.performBatchUpdates({
            if index > numberOfSections - 1 {
                self.insertSections(IndexSet(integer: numberOfSections))
            }
            
            self.insertItems(at: [IndexPath(item: 0, section: numberOfSections)])
            
            if index >= 1 {
                self.reloadSections([index - 1])
            }
        }, completion: { [weak self] _ in
            if let indexPath = self?.indexPathForLastItem {
                self?.scrollToItem(at: indexPath, at: .bottom, animated: true)
            }
        })
    }
    
    func refreshSection(_ index: Int) {
        guard index >= 0 else {
            return
        }
        
        self.performBatchUpdates {
            self.reloadItems(at: [IndexPath(item: 0, section: index)])
        } completion: { [weak self] _ in
            if let indexPath = self?.indexPathForLastItem {
                self?.scrollToItem(at: indexPath, at: .bottom, animated: true)
            }
        }
    }
}
