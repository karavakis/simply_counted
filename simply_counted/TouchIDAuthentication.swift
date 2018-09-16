//
//  TouchIDAuthentication.swift
//  TouchMeIn
//
//  Created by Marin Benčević on 21/04/2017.
//  Copyright © 2017 iT Guy Technologies. All rights reserved.
//

import Foundation
import LocalAuthentication

class TouchIDAuth {
  let useTouchId = UserDefaults.standard.object(forKey: "use_touchid") as? Bool
  var context = LAContext()
  
  func canEvaluatePolicy() -> Bool {
    return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
  }
  
  func authenticateUser(completion: @escaping (String?) -> Void) {
    context = LAContext()
    
    context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics,
      localizedReason: "Logging in with Touch ID") {
        (success, evaluateError) in
        if success {
            print("Biometrics successfully passed")
          DispatchQueue.main.async {
            // User authenticated successfully, take appropriate action
            completion(nil)
          }  
        } else {
                              
          let message: String
                              
          switch evaluateError {
          case LAError.authenticationFailed?:
            message = "There was a problem verifying your identity."
            print("There was a problem verifying your identity.")
          case LAError.userCancel?:
            message = "You pressed cancel."
            print("You pressed cancel.")
          case LAError.userFallback?:
            message = "You pressed password."
            print("You pressed password.")
          default:
            message = "Touch ID may not be configured. Turn off \"Use TouchId\" setting in Settings"
            print("Touch ID may not be configured. Turn off \"Use TouchId\" setting in Settings")
          }
          
          completion(message)
        }
    }
  }
}
