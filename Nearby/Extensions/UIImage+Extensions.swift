import UIKit

extension UIImage {
  convenience init?(symbol: String, size: CGFloat, weight: SymbolWeight = .regular) {
    let configuration = UIImage.SymbolConfiguration(pointSize: size, weight: weight)
    self.init(systemName: symbol, withConfiguration: configuration)
  }
  
  func resized(toWidth width: CGFloat, isOpaque: Bool = true) -> UIImage? {
    let height = ceil(width / size.width * size.height)
    let canvas = CGSize(width: width, height: height)
    
    imageRendererFormat.opaque = isOpaque
    
    return UIGraphicsImageRenderer(size: canvas, format: imageRendererFormat).image { _ in
      draw(in: CGRect(origin: .zero, size: canvas))
    }
  }
}
