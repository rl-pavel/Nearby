import UIKit

class ChatController: UIViewController {
  
  // MARK: - Properties
  
  let tableView = UITableView()
  let entryView = EntryView()
  
  
  // MARK: - Functions
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.addSubview(tableView)
    tableView.snp.makeConstraints { make in
      make.top.equalTo(view.safeAreaLayoutGuide)
      make.horizontal.equalToSuperview()
    }
    
    view.addSubview(entryView)
    entryView.snp.makeConstraints { make in
      make.top.lessThanOrEqualTo(tableView.snp.bottom)
      make.horizontal.equalToSuperview().inset(Int.x2)
      make.bottom.equalTo(view.keyboardLayoutGuide).inset(Int.x2).priority(.high)
      make.bottom.lessThanOrEqualTo(view.safeAreaLayoutGuide)
    }
  }
}
