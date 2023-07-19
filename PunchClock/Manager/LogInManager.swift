//
//  LogInManager.swift
//  PunchClock
//
//  Created by Jube on 2023/7/11.
//

import AuthenticationServices

class LogInManager: NSObject {
    
    var account: String? {
        if UserDefaults.standard.string(forKey: "account") != nil {
            isSignInSuccess = true
        }
        return UserDefaults.standard.string(forKey: "account")
    }
    
    var isSignInSuccess: Bool = false
    
    private func saveAccount(_ account: String) {
        UserDefaults.standard.set(account, forKey: "account")
    }
    
    private func clearAccount() {
        UserDefaults.standard.removeObject(forKey: "account")
    }
    
    @objc func appleSignIn() {
        let authorizationAppleIDRequests = [
            ASAuthorizationAppleIDProvider().createRequest(),
            ASAuthorizationPasswordProvider().createRequest()
        ]
        
        let controller: ASAuthorizationController = ASAuthorizationController(authorizationRequests: authorizationAppleIDRequests)
        controller.delegate = self
        
        controller.performRequests()
    }
    
    func checkAppleSignInState() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        
        if let account = self.account {
            appleIDProvider.getCredentialState(forUserID: account) { state, error in
                
                switch state {
                    
                case .revoked:
                    print("====== Apple SignIn Revoked ======")
                    self.clearAccount()
                    
                case .authorized:
                    print("====== Apple SignIn authorized ======")
                    self.isSignInSuccess = true
                    
                case .notFound:
                    print("====== Apple SignIn Not Found ======")
                
                default:
                    break
                }
                
                guard let error else { return }
                print(error.localizedDescription)
            }
        }
    }
}

extension LogInManager: ASAuthorizationControllerDelegate {
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        
        self.isSignInSuccess = true
        
        switch authorization.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            self.saveAccount(appleIDCredential.user)
            
            print("====== Apple SignIn Success ======\nAccount: \(appleIDCredential.user)")
            
        case let passwordCredential as ASPasswordCredential:
            self.saveAccount(passwordCredential.user)
            
            print("====== Apple SignIn Success ======\nAccount: \(passwordCredential.user)")
            
        default:
            print("====== Apple SignIn Success ======\nInfo not complete.")
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        
        self.isSignInSuccess = false
        
        let err = error as! ASAuthorizationError
        
        switch err.code {
        case .canceled:
            print("====== Apple SignIn Canceled ======\nError: \(error.localizedDescription)")
        case .unknown:
            print("====== Apple SignIn Unknown Error ======\nError: \(error.localizedDescription)")
        case .invalidResponse:
            print("====== Apple SignIn Invalid Response ======\nError: \(error.localizedDescription)")
        case .notHandled:
            print("====== Apple SignIn Not Handled ======\nError: \(error.localizedDescription)")
        case .failed:
            print("====== Apple SignIn Failed ======\nError: \(error.localizedDescription)")
        case .notInteractive:
            print("====== Apple SignIn Not Interactive ======\nError: \(error.localizedDescription)")
        @unknown default:
            break
        }
    }
}
