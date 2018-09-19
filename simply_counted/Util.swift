//
//  Util.swift
//  GiftStash
//
//  Created by Jennifer Karavakis on 11/25/15.
//  Copyright © 2017 Jennifer Karavakis. All rights reserved.
//

import UIKit
import LocalAuthentication

//TODO Animate is not working
let MOVE_VIEW_ANIMATE_TIME : TimeInterval = 10


func unwrapOptionalAsString(_ optionalString: String?) -> String {
    if( optionalString != nil && !optionalString!.isEmpty ) {
        return optionalString!
    }
    return ""
}

func convertEnteredStringValueToInt(_ enteredStringValue: String) -> Int {
    if( Int(enteredStringValue) != nil ) {
        return Int(enteredStringValue)!
    }
    return -1
}

/*********************/
/* add round corners */
/*********************/
func roundCorners(_ element : AnyObject, radius: CGFloat = 3.0) {
    element.layer.masksToBounds = true
    element.layer.cornerRadius = radius
}


/***********************/
/* Keyboard moves view */
/***********************/
func calculateViewMovementWhenKeyboardAppears(_ view: UIViewController, notification:Notification, bottomOfElements: CGFloat) -> CGFloat {
    var movement : CGFloat = 0
    var info = notification.userInfo!
    let keyboardFrame: CGRect = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
    let extraSpace = view.view.bounds.maxY - bottomOfElements
    movement = extraSpace - keyboardFrame.size.height
    if (movement > 0) {
        movement = 0
    }
    else {
        movement -= 10 //Add a little padding
    }
    return movement
}

/***********************/
/* Keyboard moves view */
/***********************/
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        tap.cancelsTouchesInView = false
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}


/*****************/
/* Hide keyboard */
/*****************/
func hideKeyboard(_ viewController : UIViewController) {
    viewController.view.endEditing(true)
}
func shouldReturn() -> Bool {
    return false
}


/*********/
/* Delay */
/*********/
func delay(_ delay: Double, closure: @escaping ()->()) {
    DispatchQueue.main.asyncAfter(
        deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC),
        execute: closure
    )
}


/*********************/
/* Authenticate User */
/*********************/
func unlockUser(_ unlockSuccess: @escaping () -> Void) {
    let context = LAContext()

    if (LAContext().canEvaluatePolicy(.deviceOwnerAuthentication, error: nil)) {
        context.evaluatePolicy(LAPolicy.deviceOwnerAuthentication, localizedReason: "Please authenticate to proceed.") { (success, error) in

            guard success else {
                DispatchQueue.main.async {
                    // show something here to block the user from continuing
                }

                return
            }

            DispatchQueue.main.async {
                // do something here to continue loading your app, e.g. call a delegate method
                unlockSuccess()
            }
        }
    }
    else {
        //Passcode not set
        unlockSuccess()
    }
    return
}


/*************/
/* Separator */
/*************/
class HairlineView: UIView {
    override func awakeFromNib() {
        guard let backgroundColor = self.backgroundColor?.cgColor else { return }
        self.layer.borderColor = backgroundColor
        self.layer.borderWidth = (1.0 / UIScreen.main.scale) / 2;
        self.backgroundColor = UIColor.clear
    }
}


/********************/
/* Arrow Anchor Bug */
/********************/
// Fix for IOS 9 pop-over arrow anchor bug
// ---------------------------------------
// - IOS9 points pop-over arrows on the top left corner of the anchor view
// - It seems that the popover controller's sourceRect is not being set
//   so, if it is empty  CGRect(0,0,0,0), we simply set it to the source view's bounds
//   which produces the same result as the IOS8 behaviour.
// - This method is to be called in the prepareForSegue method override of all
//   view controllers that use a PopOver segue
//
//   example use:
//
//          override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
//          {
//             fixIOS9PopOverAnchor(segue)
//          }
//
extension UIViewController
{
    func fixIOS9PopOverAnchor(_ segue:UIStoryboardSegue?)
    {
        guard #available(iOS 9.0, *) else { return }
        if let popOver = segue?.destination.popoverPresentationController,
            let anchor  = popOver.sourceView
            , popOver.sourceRect == CGRect()
                && segue!.source === self
        { popOver.sourceRect = anchor.bounds }
    }       
}
