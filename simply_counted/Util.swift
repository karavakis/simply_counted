//
//  Util.swift
//  GiftStash
//
//  Created by Jennifer Karavakis on 11/25/15.
//  Copyright © 2016 Jennifer Karavakis. All rights reserved.
//

import UIKit

//TODO Animate is not working
let MOVE_VIEW_ANIMATE_TIME : NSTimeInterval = 10


func unwrapOptionalAsString(optionalString: String?) -> String {
    if( optionalString != nil && !optionalString!.isEmpty ) {
        return optionalString!
    }
    return ""
}

func convertEnteredStringValueToInt(enteredStringValue: String) -> Int {
    if( Int(enteredStringValue) != nil ) {
        return Int(enteredStringValue)!
    }
    return -1
}

/*********************/
/* add round corners */
/*********************/
func roundCorners(element : AnyObject, radius: CGFloat = 3.0) {
    element.layer.masksToBounds = true
    element.layer.cornerRadius = radius
}


/***********************/
/* Keyboard moves view */
/***********************/
func calculateViewMovementWhenKeyboardAppears(view: UIViewController, notification:NSNotification, bottomOfElements: CGFloat) -> CGFloat {
    var movement : CGFloat = 0
    var info = notification.userInfo!
    let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
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


/*****************/
/* Hide keyboard */
/*****************/
func hideKeyboard(viewController : UIViewController) {
    viewController.view.endEditing(true)
}
func shouldReturn() -> Bool {
    return false
}


/*********/
/* Delay */
/*********/
func delay(delay: Double, closure: ()->()) {
    dispatch_after(
        dispatch_time(
            DISPATCH_TIME_NOW,
            Int64(delay * Double(NSEC_PER_SEC))
        ),
        dispatch_get_main_queue(),
        closure
    )
}