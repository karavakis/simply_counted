//
//  LoginViewController.swift
//  GiftStash
//
//  Created by Jennifer Karavakis on 11/27/15.
//  Copyright © 2016 Jennifer Karavakis. All rights reserved.
//

import UIKit
import ParseFacebookUtilsV4

var loggedInWithFacebook = false
var loggedInWithLogin = false

class LoginViewController: UIViewController, FBSDKLoginButtonDelegate, UITextFieldDelegate {

    @IBOutlet weak var facebookLoginButton: FBSDKLoginButton!
    @IBOutlet weak var loginView: UIView!
    @IBOutlet weak var joinButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var emailTextField: TextFieldValidator!
    @IBOutlet weak var passwordTextField: TextFieldValidator!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    var originalTopConstraint : CGFloat!
    var logoutClicked = false

    override func viewDidLoad() {
        if( logoutClicked ) {
            loginButtonDidLogOut(nil)
        }
        setupButtonHiding()
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //addKeyboardNotifications()
        addRoundCorners()
        //addValidators()
        addFacebookPermissions()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewWillAppear(true)
        // Do any additional setup after loading the view, typically from a nib.
        addKeyboardNotifications()
        isLoggedIn()
    }

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        hideKeyboard(self)
        super.touchesBegan(touches, withEvent: event)
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        hideKeyboard(self)
        return shouldReturn()
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(true)
        removeKeyboardNotifications()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }



    /**********************/
    /* Round View Corners */
    /**********************/
    func addRoundCorners() {
        roundCorners(loginView, radius: 5.0)
        roundCorners(joinButton)
        roundCorners(loginButton)
    }


    /***********************/
    /* Keyboard moves view */
    /***********************/
//TODO figure out why this isn't working
    func addKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LoginViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: self)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LoginViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: self)
    }

    //TODO pull into a new class so we can just import the class at the top instead of duplicating
    func keyboardWillShow(notification:NSNotification) {
        let joinButtonBottom = self.joinButton.frame.origin.y + self.joinButton.frame.height
        let movement = calculateViewMovementWhenKeyboardAppears(self, notification: notification, bottomOfElements: joinButtonBottom)
        if movement <= 0 {
            self.originalTopConstraint = self.topConstraint.constant
            UIView.animateWithDuration(MOVE_VIEW_ANIMATE_TIME, animations: { () -> Void in
                self.topConstraint.constant += movement
            })
        }
    }

    func keyboardWillHide(notification:NSNotification) {
        if let originalTopConstraint = self.originalTopConstraint {
            UIView.animateWithDuration(MOVE_VIEW_ANIMATE_TIME, animations: { () -> Void in
                self.topConstraint.constant = originalTopConstraint
            })
        }
    }

    func removeKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    


    /******************/
    /* Facebook Login */
    /******************/

    func addFacebookPermissions() {
        facebookLoginButton.readPermissions = ["public_profile", "email", "user_friends"]
    }

    func isLoggedIn() -> Bool {
        if (FBSDKAccessToken.currentAccessToken() != nil)
        {
            // User is already logged in, do work such as go to next view controller.
            // Log In (create/update currentUser) with FBSDKAccessToken
            self.performSegueWithIdentifier("LoginSuccessful", sender: self)
            loggedInWithFacebook = true
            return true
        }
        return false
    }

    //Facebook Login button clicked
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        if ((error) != nil)
        {
            // Process error
        }
        else if result.isCancelled {
            // Handle cancellations
        }
        else {
            // If you ask for multiple permissions at once, you
            // should check if specific permissions missing
            if result.grantedPermissions.contains("email")
            {
                // Do work
                // Log In (create/update currentUser) with FBSDKAccessToken
                PFFacebookUtils.logInInBackgroundWithAccessToken(FBSDKAccessToken.currentAccessToken(), block: {
                    (user: PFUser?, error: NSError?) -> Void in
                    if user != nil {
                    } else {
                        print("Uh oh. There was an error logging in.")
                    }
                })
            }
        }
    }

    //Facebook Logout button clicked
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        PFUser.logOut()
        loggedInWithFacebook = false
        loggedInWithLogin = false
        logoutClicked = false
        setupButtonHiding()
    }

    func returnUserData()
    {
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: nil)
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in

            if ((error) != nil)
            {
                // Process error
                print("Error: \(error)")
            }
            else
            {
                print("fetched user: \(result)")
                let userName : NSString = result.valueForKey("name") as! NSString
                print("User Name is: \(userName)")
                let userEmail : NSString = result.valueForKey("email") as! NSString
                print("User Email is: \(userEmail)")
            }
        })
    }


    /***************/
    /* Parse Login */
    /***************/
    @IBAction func loginButtonClicked(sender: AnyObject) {

        if(loggedInWithLogin) {

            loggedInWithLogin = true
            setupButtonHiding()
        }
        let username = unwrapOptionalAsString(emailTextField.text)
        let password = unwrapOptionalAsString(passwordTextField.text)


       // Run a spinner to show a task in progress
        let spinner: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRectMake(0, 0, 150, 150)) as UIActivityIndicatorView
        spinner.startAnimating()

        // Send a request to login
        PFUser.logInWithUsernameInBackground(username, password: password, block: { (user, error) -> Void in

            // Stop the spinner
            spinner.stopAnimating()

            if ((user) != nil) {
                self.performSegueWithIdentifier("LoginSuccessful", sender: self)
                loggedInWithLogin = true
            }
            else {
                var message = String(error)
                if let error = error {
                    message = error.localizedDescription
                }
                let errorAlert = UIAlertController(title: "Error", message: message, preferredStyle: UIAlertControllerStyle.Alert)
                errorAlert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (action: UIAlertAction!) in
                }))
                self.presentViewController(errorAlert, animated: true, completion: nil)
            }
        })
    }


    /****************/
    /* Hide Buttons */
    /****************/
    func setupButtonHiding() {
        if(loggedInWithFacebook) {
            self.loginView.hidden = true
            self.joinButton.hidden = true
//            self.loginButton.setTitle("Login", forState: .Normal)
        }
        if(loggedInWithLogin) {
            self.loginView.hidden = false
            self.joinButton.hidden = true
            self.loginButton.setTitle("Logout", forState: .Normal)
        }
    }
}



