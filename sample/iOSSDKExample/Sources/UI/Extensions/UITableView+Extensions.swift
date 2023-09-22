import UIKit

extension UITableView {

    func dequeue<T: UITableViewCell>(_ cellClass: T.Type) -> T? {
        dequeueReusableCell(withIdentifier: cellClass.reuseIdentifier) as? T
    }

    func dequeue<T: UITableViewCell>(_ cellClass: T.Type, forIndexPath indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withIdentifier: cellClass.reuseIdentifier, for: indexPath) as? T else {
            fatalError("Error: cell with id: \(cellClass.reuseIdentifier) for indexPath: \(indexPath) is not \(T.self)")
        }
        
        return cell
    }
    
    func register<T: UITableViewCell>(_ cellClass: T.Type) {
        register(cellClass, forCellReuseIdentifier: cellClass.reuseIdentifier)
    }
}
