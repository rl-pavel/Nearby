import UIKit
import SnapKit
import MultipeerConnectivity

class ChatListController: UIViewController {
  
  // MARK: - Properties
  
  let tableView = UITableView()
  
  
  // MARK: - Functions
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    navigationItem.title = "Nearby Chats"
    navigationController?.navigationBar.prefersLargeTitles = true
    
    view.addSubview(tableView)
    tableView.snp.makeConstraints { make in
      make.edges.equalTo(view.safeAreaLayoutGuide)
    }
  }
}


// MARK: - UITableView Functions

extension ChatListController: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 3
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    return tableView.dequeueReusableCell(UITableViewCell.self)
  }
}
