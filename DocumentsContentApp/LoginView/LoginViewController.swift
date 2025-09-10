import UIKit

final class LoginViewController: UIViewController {
    
    private let userSettings = UserSettings.shared
    private var userLoginStatus: UserLoginStatus = .passwordFirstAtempt
    private var buttonLabel: String = "Create Password" {
        didSet {
            loginButton.setTitle(buttonLabel, for: .normal)
        }
    }
    
    private lazy var passwordField: UITextField = {
        let view = UITextField()
        
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isSecureTextEntry = true
        view.placeholder = "Enter Password"
        view.textAlignment = .center
        view.clearButtonMode = .whileEditing
        
        view.layer.borderWidth = 2
        view.layer.borderColor = UIColor.systemGray5.cgColor
        
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 10
        
        
        
        return view
    }()
    
    private lazy var loginButton: UIButton = {
        
        let view = UIButton(type: .roundedRect)
        let currentStatus = userSettings.isPasswordExists()

        if currentStatus {
            view.setTitle("Input Password", for: .normal)
        } else {
            view.setTitle("Create Password", for: .normal)
        }

        view.translatesAutoresizingMaskIntoConstraints = false
        view.addTarget(self, action: #selector(didTapLoginButton), for: .touchUpInside)
        
        return view
    }()
    private lazy var resetUserButton: UIButton = {
        let view = UIButton(type: .roundedRect)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addTarget(self, action: #selector(didTapResetUserButton), for: .touchUpInside)
        view.setTitle("Reset Password and Settings", for: .normal)
        
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        self.tabBarController?.tabBar.isHidden = true
        
        setupView()
    }

    
    private func loginAlert(_ msg: String) {
        let alert = UIAlertController(title: "Welcome", message: msg, preferredStyle: .alert)
        let alerAction = UIAlertAction(title: "Ok", style: .cancel) {_ in 
            let vc = ContentViewController()
            self.navigationController?.pushViewController(vc, animated: true)
        }
        alert.addAction(alerAction)
        present(alert, animated: true)
    }
    
    private func passwordAlert(_ msg: String) {
        let alert = UIAlertController(title: "Password alert", message: msg, preferredStyle: .alert)
        let alerAction = UIAlertAction(title: "Ok", style: .cancel)
        alert.addAction(alerAction)
        present(alert, animated: true)
    }
    
    private func checkStatus() -> Bool {

        if userSettings.isPasswordExists(), userLoginStatus != .passwordSecondAtempt {
            // If password exists
            userLoginStatus = .passwordExists
            if passwordField.text == userSettings.getUserPassword() {
                // And password correct
                return true
            } else {
                passwordAlert("Wrong password")
            }
 
        } else {
            // If password doesn`t exist
            if userLoginStatus == .passwordFirstAtempt {
                // And its 1st attempt
                if let pass = passwordField.text, pass.count > 4 {
                    print("Succesfull 1st attempt")
                    userSettings.setUserPassword(as: pass)
                    passwordField.text = ""
                    userLoginStatus = .passwordSecondAtempt
                    buttonLabel = "Repeat Password"
                } else {
                    passwordAlert("Password is too short. Should be at least 5 symbols")
                    passwordField.text = ""
                }
                
            } else if userLoginStatus == .passwordSecondAtempt {
                // And its 2nd attempt
                if passwordField.text == userSettings.getUserPassword() {
                    // And password set correctly
                    
                    // Set default sorting
                    UserDefaults.standard.set(true, forKey: "keyUserSort")
                    
                    loginAlert("Password succesfully added. Welcome!")
                    buttonLabel = "Input Password"
                    userLoginStatus = .passwordExists
                    return true
                } else {
                    // And password set incorrectly
                    passwordAlert("Passwords mismatch. Please try again.")
                    userSettings.resetUserPassword()
                    userLoginStatus = .passwordFirstAtempt
                    buttonLabel = "Create Password"
                    passwordField.text = ""
                }
            }
        }
        return false
    }
    
    private func setupView() {
        view.addSubview(passwordField)
        view.addSubview(loginButton)
        view.addSubview(resetUserButton)
        
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            passwordField.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 16),
            passwordField.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -16),
            passwordField.centerYAnchor.constraint(equalTo: safeArea.centerYAnchor),
            passwordField.heightAnchor.constraint(equalToConstant: 32),
            
            loginButton.leadingAnchor.constraint(equalTo: passwordField.leadingAnchor),
            loginButton.trailingAnchor.constraint(equalTo: passwordField.trailingAnchor),
            loginButton.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: 16),
            loginButton.heightAnchor.constraint(equalToConstant: 32),
            
            resetUserButton.leadingAnchor.constraint(equalTo: passwordField.leadingAnchor),
            resetUserButton.trailingAnchor.constraint(equalTo: passwordField.trailingAnchor),
            resetUserButton.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 16),
            resetUserButton.heightAnchor.constraint(equalToConstant: 32)
        ])
    }
    
    @objc func didTapLoginButton() {
        if checkStatus() {
            let vc = ContentViewController()
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @objc func didTapResetUserButton() {
        // Debug button
        // Reset app settings to deafult
        
        UserDefaults.standard.set(true, forKey: "keyUserSort")
        userSettings.resetUserPassword()
        userLoginStatus = .passwordFirstAtempt
        buttonLabel = "Create password"
    }
    
}
