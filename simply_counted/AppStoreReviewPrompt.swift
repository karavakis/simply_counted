//
//  AppStoreReviewPrompt.swift
//  simply_counted
//
//  Created by Nicholas Karavakis on 10/3/18.
//  Copyright © 2018 Jennifer Karavakis. All rights reserved.
//

import Foundation
import StoreKit

class AppStoreReviewPrompt {
    var userDefaults = UserDefaults.standard
    
    func displayPrompt() {
        let currentBundle = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
        print("app bundle: " + currentBundle)
        
        let previousBundle = userDefaults.string(forKey: "previous_bundle_version");
        
        if(previousBundle != nil && previousBundle != currentBundle) {
            userDefaults.set(0, forKey: "app_store_prompt_counter")
            userDefaults.set(currentBundle, forKey: "previous_bundle_version")
        }
        
        var app_store_prompt_counter = userDefaults.integer(forKey: "app_store_prompt_counter");
        
        if app_store_prompt_counter == 0 {
            userDefaults.set(0, forKey: "app_store_prompt_counter")
        }
        else if app_store_prompt_counter < 20 {
            app_store_prompt_counter += 1
            userDefaults.set(app_store_prompt_counter, forKey: "app_store_prompt_counter")
        } else if #available( iOS 10.3,*){
            userDefaults.set(0, forKey: "app_store_prompt_counter")
            SKStoreReviewController.requestReview()
            userDefaults.set(currentBundle, forKey: "previous_bundle_version")
        }
    }
}
