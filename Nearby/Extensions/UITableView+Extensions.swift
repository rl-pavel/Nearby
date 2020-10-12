import UIKit

extension UITableView {
  func dequeueReusableCell<T: UITableViewCell>(
    _ returningType: T.Type,
    style: UITableViewCell.CellStyle = .default) -> T {
    let identifier = String(describing: returningType)
    
    return dequeueReusableCell(returningType, style: style, withIdentifier: identifier)
  }
  
  func dequeueReusableCell<T: UITableViewCell>(
    _ returningType: T.Type,
    style: UITableViewCell.CellStyle = .default,
    withIdentifier identifier: String) -> T {
    
    if let cell = dequeueReusableCell(withIdentifier: identifier) as? T {
      return cell
      
    } else {
      // If there's not a cell available for reuse yet, create one with the cell type's metatype as identifier.
      return returningType.init(style: style, reuseIdentifier: identifier)
    }
  }
}
