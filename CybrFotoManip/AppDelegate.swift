//
//  AppDelegate.swift
//  CatwangFree
//
//  Created by Franky Aguilar on 9/16/15.
//  Copyright (c) 2015 99centbrains. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import iNotify

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        //[[Button sharedButton] configureWithApplicationId:@"YOUR-APP-ID" completion:NULL];
        
        
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        iNotify.sharedInstance().notificationsPlistURL = "http://labz.99centbrains.com/cybrfm/cybr_notifs.plist"
        iNotify.sharedInstance().showOnFirstLaunch = false
        iNotify.sharedInstance().okButtonLabel = "Ok"
        iNotify.sharedInstance().ignoreButtonLabel = "No Thnx!"
        iNotify.sharedInstance().remindButtonLabel = "Remind Me Later"

        //
        
        

        
        return true
    }

    

    func application(app: UIApplication, openURL url: NSURL, options: [String : AnyObject]) -> Bool {
        
//        PushReview.configureWithAppId("659186916", appDelegate: self)
//        PushReview.registerNotificationSettings()
//        PushReview.usesBeforePresenting = 2
        
        return FBSDKApplicationDelegate.sharedInstance().application(app, didFinishLaunchingWithOptions: options)
        
//        
        

    }
    

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        
        FBSDKAppEvents.activateApp()
        
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.

    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}


//DESIGNABLES

@IBDesignable
class CircleButton: UIButton {


    @IBInspectable var rounded: Bool = true {
        didSet {
            
            layer.cornerRadius = self.frame.size.width/2
            layer.masksToBounds = self.frame.size.width/2 > 0
        }
    }
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    @IBInspectable var borderColor: UIColor? {
        didSet {
            layer.borderColor = borderColor?.CGColor
        }
    }
    
    @IBInspectable var bgColor: UIColor? {
        didSet {
            layer.backgroundColor = bgColor?.CGColor
        }
    }

    
   
    
}

enum UIUserInterfaceIdiom : Int {
    case Unspecified
    case Phone // iPhone and iPod touch style UI
    case Pad // iPad style UI
}

