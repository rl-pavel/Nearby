import UIKit

extension UIImage {
  convenience init?(symbol: String, size: CGFloat, weight: SymbolWeight = .regular) {
    let configuration = UIImage.SymbolConfiguration(pointSize: size, weight: weight)
    self.init(systemName: symbol, withConfiguration: configuration)
  }
}
