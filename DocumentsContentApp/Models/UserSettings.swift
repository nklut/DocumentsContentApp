import KeychainSwift
import Foundation

enum UserLoginStatus {
    case passwordExists
    case passwordFirstAtempt
    case passwordSecondAtempt
}

final class UserSettings {
    static let shared = UserSettings()
    private let defaults = UserDefaults.standard
    
    func getCurrentSort() -> Bool {
        return defaults.bool(forKey: "keyUserSort")
    }
    
    func reverseSort() {
        var currentSort = getCurrentSort()
        currentSort.toggle()
        defaults.set(currentSort, forKey: "keyUserSort")
    }

    func setUserPassword(as password: String) {
        KeychainSwift().set(password, forKey: "keyUserPassword")
    }
    
    func resetUserPassword() {
        if KeychainSwift().allKeys.contains("keyUserPassword"){
            KeychainSwift().delete("keyUserPassword")
        }
    }
    
    func getUserPassword() -> String {
        if let password = KeychainSwift().get("keyUserPassword") {
            return password
        } else {
            return "Password doesn`t exist"
        }
    }
    
    func isPasswordExists() -> Bool {
        if let pass = KeychainSwift().get("keyUserPassword") {
            print("WE got this password from chain.get: \(pass)" )
            return true
        } else {
            print("Password is not set")
            return false
        }
    }
}
