import UIKit

class SettingsViewController: UITableViewController {
    
    private let userSettings = UserSettings.shared
    
    private let settingsList = ["Alphabet order sorting", "Reset password"]

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingsList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        var config = UIListContentConfiguration.cell()
        
        config.text = settingsList[indexPath.row]
        cell.contentConfiguration = config
        
        if indexPath.row == 0 {
            cell.accessoryType = userSettings.getCurrentSort() ? .checkmark : .none
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            userSettings.reverseSort()
            tableView.reloadSections([0], with: .automatic)
            
        } else if indexPath.row == 1 {
            userSettings.resetUserPassword()
            let vc = LoginViewController()
            navigationController?.pushViewController(vc, animated: true)
            
        } else {
            print("Unknown indexpath")
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }
}
