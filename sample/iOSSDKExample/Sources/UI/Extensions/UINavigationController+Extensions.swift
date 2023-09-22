import UIKit

extension UINavigationController {
    
    func setNormalNavigationBarAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = .systemBackground
        appearance.shadowColor = nil
        appearance.shadowImage = nil
        
        navigationBar.shadowImage = UIImage()
        navigationBar.tintColor = .systemBlue
        navigationBar.barTintColor = .systemBackground
        navigationBar.standardAppearance = appearance
        navigationBar.compactAppearance = appearance
        navigationBar.scrollEdgeAppearance = appearance
    }
    
    func setCustomNavigationBarAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = ChatAppearance.navigationBarColor
        appearance.shadowColor = nil
        appearance.shadowImage = nil
        appearance.titleTextAttributes = [.foregroundColor: ChatAppearance.navigationElementsColor]
        appearance.largeTitleTextAttributes = [.foregroundColor: ChatAppearance.navigationElementsColor]
        
        navigationBar.shadowImage = UIImage()
        navigationBar.tintColor = ChatAppearance.navigationElementsColor
        navigationBar.barTintColor = ChatAppearance.navigationBarColor
        navigationBar.standardAppearance = appearance
        navigationBar.compactAppearance = appearance
        navigationBar.scrollEdgeAppearance = appearance
    }
}
