import UIKit

final class LoginViewController: UIViewController {
    
    private let userStatus = UserStatus.shared
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
        
        return view
    }()
    
    private lazy var loginButton: UIButton = {
        
        let view = UIButton(type: .roundedRect)
        let currentStatus = userStatus.isPasswordExists()

        if currentStatus {
            view.setTitle("Input Password", for: .normal)
        } else {
            view.setTitle("Create Password", for: .normal)
        }

        view.translatesAutoresizingMaskIntoConstraints = false
        view.addTarget(self, action: #selector(didTapLoginButton), for: .touchUpInside)
        
        return view
    }()
    private lazy var resetButton: UIButton = {
        let view = UIButton(type: .roundedRect)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addTarget(self, action: #selector(didTapResetButton), for: .touchUpInside)
        view.setTitle("Reset(Delete) password", for: .normal)
        
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
       
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

        if userStatus.isPasswordExists(), userLoginStatus != .passwordSecondAtempt {
            // If password exists
            userLoginStatus = .passwordExists
            if passwordField.text == userStatus.getUserPassword() {
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
                    userStatus.setUserPassword(as: pass)
                    passwordField.text = ""
                    userLoginStatus = .passwordSecondAtempt
                    buttonLabel = "Repeat Password"
                } else {
                    passwordAlert("Password is too short. Should be at least 5 symbols")
                    passwordField.text = ""
                }
                
            } else if userLoginStatus == .passwordSecondAtempt {
                // And its 2nd attempt
                if passwordField.text == userStatus.getUserPassword() {
                    // And password set correctly
                    loginAlert("Password succesfully added. Welcome!")
                    buttonLabel = "Input Password"
                    userLoginStatus = .passwordExists
                    return true
                } else {
                    // And password set incorrectly
                    passwordAlert("Passwords mismatch. Please try again.")
                    userStatus.resetUserPassword()
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
        view.addSubview(resetButton)
        
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
            
            resetButton.leadingAnchor.constraint(equalTo: passwordField.leadingAnchor),
            resetButton.trailingAnchor.constraint(equalTo: passwordField.trailingAnchor),
            resetButton.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 16),
            resetButton.heightAnchor.constraint(equalToConstant: 32)
        ])
    }
    
    @objc func didTapLoginButton() {
        if checkStatus() {
            let vc = ContentViewController()
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @objc func didTapResetButton() {
        userStatus.resetUserPassword()
        userLoginStatus = .passwordFirstAtempt
        buttonLabel = "Create password"
        print(userStatus.isPasswordExists())
    }
    
}
