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
