//
//  JoinViewController.swift
//  GiftStash
//
//  Created by Jennifer Karavakis on 11/30/15.
//  Copyright © 2016 Jennifer Karavakis. All rights reserved.
//

import UIKit
import Parse

class JoinViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var textFieldsView: UIView!
    @IBOutlet weak var joinButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var emailTextField: TextFieldValidator!
    @IBOutlet weak var passwordTextField: TextFieldValidator!
    @IBOutlet weak var confirmPasswordTextField: TextFieldValidator!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!


    var email : String = ""
    var password : String = ""
    var firstName : String = ""
    var lastName : String = ""
    var phoneNumber : String = ""
    var originalTopConstraint : CGFloat!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        addKeyboardNotifications()
        addRoundCorners()
        addValidators()
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
        removeKeyboardNotifications()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }





    /************************/
    /* Validate Text Fields */
    /************************/
    func addValidators() {
        emailTextField.addRegx(".*@.*\\..*", withMsg: "Email not valid.")
        emailTextField.validateOnCharacterChanged = false
        confirmPasswordTextField.addConfirmValidationTo(passwordTextField, withMsg: "Passwords do not match.")
    }

    /**********************/
    /* Round View Corners */
    /**********************/
    func addRoundCorners() {
        roundCorners(textFieldsView, radius: 5.0)
        roundCorners(joinButton)
        roundCorners(cancelButton)
    }

    /***************/
    /* Join Button */
    /***************/
    @IBAction func joinClicked(sender: AnyObject) {
        let user = PFUser()
        user.username = unwrapOptionalAsString(emailTextField.text)
        user.password = unwrapOptionalAsString(passwordTextField.text)
        user.email = unwrapOptionalAsString(emailTextField.text)

        // other fields can be set just like with PFObject
        //user["phone"] = "415-392-0202"

        user.signUpInBackgroundWithBlock {
            (succeeded: Bool, error: NSError?) -> Void in
            if let error = error {
                let errorString = error.userInfo["error"] as? NSString
                // Show the errorString somewhere and let the user try again.
                print(errorString)
            } else {
                // Hooray! Let them use the app now.
                dispatch_async(dispatch_get_main_queue()) {
                    [unowned self] in
                    self.performSegueWithIdentifier("joinSuccessful", sender: self)
                }
            }
        }
    }

    /***********************/
    /* Keyboard moves view */
    /***********************/
    func addKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(JoinViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: self.view.window)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(JoinViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: self.view.window)
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

    //TODO Hide keyboard isn't working with the notifications

}

