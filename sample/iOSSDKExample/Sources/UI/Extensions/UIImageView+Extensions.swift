import UIKit

extension UIImageView {
    
    func load(url: URL) {
        URLSession.shared
            .dataTask(with: url) { (data, _, error) in
                guard let imageData = data else {
                    error?.logError()
                    return
                }
              
              DispatchQueue.main.async {
                self.image = UIImage(data: imageData)
              }
            }
            .resume()
    }
}
