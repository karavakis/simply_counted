//
//  LoginViewController.swift
//  simply_counted
//
//  Created by Nicholas Karavakis on 7/26/17.
//  Copyright © 2017 Jennifer Karavakis. All rights reserved.
//

import UIKit
import CoreData

struct KeychainConfiguration {
    static let serviceName = "SimplyCounted"
    static let accessGroup: String? = nil
}

protocol LoginViewControllerDelegate: class {
    func dismissed(_ successfulLogin: Bool)
}

class LoginViewController: UIViewController, UITextFieldDelegate {

    var client:Client? = nil //passed in from last view
    var delegate: LoginViewControllerDelegate?
    
    let touchAuth = TouchIDAuth()
    let createLoginButtonTag = 1
    let loginButtonTag = 1
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var touchIdButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        usernameTextField.delegate = self
        passwordTextField.delegate = self
        
        let hasLogin = UserDefaults.standard.bool(forKey: "hasLoginKey")
        
        if hasLogin {
            loginButton.setTitle("Login", for: UIControlState.normal)
            loginButton.tag = loginButtonTag
        } else {
            loginButton.setTitle("Create", for: UIControlState.normal)
            loginButton.tag = createLoginButtonTag
        }
        
        if let storedUsername = UserDefaults.standard.value(forKey: "username") as? String {
            usernameTextField.text = storedUsername
        }
        
        touchIdButton.isHidden = !touchAuth.canEvaluatePolicy();
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func cancelButtonAction(_ sender: Any) {
        delegate?.dismissed(false)
        self.dismiss(animated: true, completion: nil) //dismiss this modally
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == usernameTextField {
            usernameTextField.placeholder = nil
        }
        if textField == passwordTextField {
            passwordTextField.placeholder = nil
        }
    }
    
    @IBAction func login(_ sender: AnyObject) {
        guard
            let newAccountName = usernameTextField.text,
            let newPassword = passwordTextField.text,
            !newAccountName.isEmpty &&
                !newPassword.isEmpty else {
                    
                    let alertView = UIAlertController(title: "Login Problem",
                                                      message: "Wrong username or password.",
                                                      preferredStyle:. alert)
                    let okAction = UIAlertAction(title: "Foiled Again!", style: .default, handler: nil)
                    alertView.addAction(okAction)
                    present(alertView, animated: true, completion: nil)
                    return
        }

        usernameTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        
        if sender.tag == createLoginButtonTag {
            let hasLoginKey = UserDefaults.standard.bool(forKey: "hasLoginKey")
            if !hasLoginKey {
                UserDefaults.standard.setValue(usernameTextField.text, forKey: "username")
            }
        }
        
        do {
            let passwordItem = KeychainPasswordItem(service: KeychainConfiguration.serviceName,
                                                    account: newAccountName,
                                                    accessGroup: KeychainConfiguration.accessGroup)
            
            try passwordItem.savePassword(newPassword)
        } catch {
            fatalError("Error updating keychain - \(error)")
        }
        
        UserDefaults.standard.set(true, forKey: "hasLoginKey")
        loginButton.tag = loginButtonTag
        
        
        func goToEditPage() {
            performSegue(withIdentifier: "LoginSucceeded", sender: self)
        }
        
        unlockUser(goToEditPage)
        
    }
    @IBAction func touchIdButton(_ sender: Any) {
        touchAuth.authenticateUser() { message in
            
            if let message = message {
                let alertView = UIAlertController(title: "Error",
                                                  message: message,
                                                  preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Darn!", style: .default)
                alertView.addAction(okAction)
                self.present(alertView, animated: true)
                
            } else {
//                self.performSegue(withIdentifier: "LoginSucceeded", sender: self)
                self.dismiss(animated: true, completion: nil) //dismiss this modally
            }
        }
    }
    
    /**********/
    /* Segues */
    /**********/
    //Might not need this anymore since this view isnt doing any segues and is being dismissed.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "LoginSucceeded") {
            if let client = client {
                let controller = (segue.destination as! EditClientViewController)
                let backItem = UIBarButtonItem()
                backItem.title = "Back"
                navigationItem.backBarButtonItem = backItem
                //Code to have the back button on the MoreOptions view skip the LoginViewController
                self.navigationController?.popToViewController(self.navigationController?.viewControllers[(self.navigationController?.viewControllers.count)! - 2] as! ClientViewController, animated: true)
                
                controller.client = client
            }
        }
    }

}
