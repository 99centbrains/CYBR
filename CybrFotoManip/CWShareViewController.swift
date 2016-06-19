//
//  CWShareViewController.swift
//  OMGWTFSTFU
//
//  Created by Franky Aguilar on 9/20/15.
//  Copyright © 2015 99centbrains. All rights reserved.
//

import Foundation
import UIKit
import MessageUI
import Social
import PKHUD
import StoreKit
import MobileCoreServices
import iNotify
import TMTumblrSDK
import iNotify


class CWSharePopUpViewController: UIViewController, MFMessageComposeViewControllerDelegate, UIDocumentInteractionControllerDelegate{
    
    var userImage:UIImage!
    var uiDocController:UIDocumentInteractionController!
    var parent:CWPlayViewController!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func iba_dismiss(){
        
        self.view.removeFromSuperview()
        parent.setUpNavbar()
        
        iNotify.sharedInstance().checkForNotifications()
    
    }
    
    @IBAction func iba_saveImage(){
        
        PhotoSaver().saveAssetToAlbum(userImage) { 
            //
            
           
        }
        
        PKHUD.sharedHUD.contentView = PKHUDSuccessView()
        PKHUD.sharedHUD.show()
        PKHUD.sharedHUD.hide(afterDelay: 1.0);
        
        
    }
    
    func image(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo:UnsafePointer<Void>) {
        
    }
    
    @IBAction func iba_mms(){
        
        if MFMessageComposeViewController.canSendText() == false {
            
            let alert = UIAlertController(title: "Oops", message: "Cant send message with this device!", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            
        } else {
            
            let messageVC = MFMessageComposeViewController()
            messageVC.body = "Catwang by @99centbrains";
            messageVC.addAttachmentData(UIImagePNGRepresentation(userImage)!, typeIdentifier: kUTTypePNG as String, filename: "catwang.png")
            messageVC.messageComposeDelegate = self;
            
            self.presentViewController(messageVC, animated: false, completion: nil)
            
        }
        
    }
    
    @IBAction func iba_facebook(){
        
        if SLComposeViewController.isAvailableForServiceType(SLServiceTypeFacebook) {
            
            let fbShare:SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
            fbShare.addImage(userImage)
            self.presentViewController(fbShare, animated: true, completion: nil)
            
        } else {
            
            let alert = UIAlertController(title: "Accounts", message: "Please login to a Facebook account to share.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            
        }
        
    }
    
    @IBAction func iba_twitter(){
        
        if SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter) {
            
            let tweetShare:SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
            tweetShare.addImage(userImage)
            self.presentViewController(tweetShare, animated: true, completion: nil)
            
        } else {
            
            let alert = UIAlertController(title: "Accounts", message: "Please login to a Twitter account to tweet.", preferredStyle: UIAlertControllerStyle.Alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            
            self.presentViewController(alert, animated: true, completion: nil)
        }
        
    }
    
    @IBAction func iba_snapchat(){
        
        if UIApplication.sharedApplication().canOpenURL(NSURL(string: "snapchat://")!) == false{
            
            let alertController = UIAlertController(
                title: "Oops!",
                message: "Looks like you dont have that app installed.",
                preferredStyle: .Alert
            )
            
            alertController.addAction(UIAlertAction(title: "Die", style: .Cancel ) { _ in
                alertController.dismissViewControllerAnimated(true, completion: { () -> Void in
                    
                })
                })
            
            self.presentViewController(alertController, animated: true, completion: { () -> Void in
                //
            })
            
        } else {
            
            let pngPath = NSHomeDirectory().stringByAppendingString("/Documents/99centbrains.png")
            UIImagePNGRepresentation(userImage)?.writeToFile(pngPath, atomically: true)
            
            let url = NSURL(fileURLWithPath: pngPath)
            
            let interactionController = UIDocumentInteractionController(URL: url)
            interactionController.delegate = self
            
            uiDocController = interactionController;
            let rect = CGRectMake(0 ,0 , 0, 0);
            uiDocController.presentOpenInMenuFromRect(rect, inView: self.view, animated: true)
            
        }
        
    }
    
    @IBAction func iba_tumblr(){
        
        if (TMTumblrAppClient.isTumblrInstalled()) {
            //
            UIPasteboard.generalPasteboard().image = UIImage(data: UIImagePNGRepresentation(userImage)!)
            let post = "tumblr://x-callback-url/photo?caption=Cybrfm&tags=cybrfm&tags=cyberart&tags=netart&tags=vaporart"
            let url = NSURL(string: post)!
            UIApplication.sharedApplication().openURL(url)
            
        } else {
            
            let pngPath = NSHomeDirectory().stringByAppendingString("/Documents/99centbrains.png")
            UIImagePNGRepresentation(userImage)?.writeToFile(pngPath, atomically: true)
            
            let url = NSURL(fileURLWithPath: pngPath)
            
            let interactionController = UIDocumentInteractionController(URL: url)
            interactionController.delegate = self
            
            uiDocController = interactionController;
            let rect = CGRectMake(0 ,0 , 0, 0);
            uiDocController.presentOpenInMenuFromRect(rect, inView: self.view, animated: true)
            
        }
        

        
        
        
    }
    
    func messageComposeViewController(controller: MFMessageComposeViewController, didFinishWithResult result: MessageComposeResult) {
        
        self.dismissViewControllerAnimated(true) { () -> Void in
            //
        }
    }
    
    
}

class CWShareViewController: UIViewController, MFMessageComposeViewControllerDelegate, SKStoreProductViewControllerDelegate, UIDocumentInteractionControllerDelegate {
    
    
    @IBOutlet var ibo_userImage:UIImageView!
    @IBOutlet var ibo_shirtPreview:UIImageView!
    
   
    var userImage:UIImage!
    var uiDocController:UIDocumentInteractionController!
    
    let yoshirtRefURL:String = "yoshirt://design?pb=1&yscid=APPDIRECT&referring_app=CatwangFree&rid=com.99centbrains.catwang"
    
    override func viewDidLoad() {
        
        let titleBarLogo = UIImageView(frame: CGRectMake(0, 0, 130, 30))
        titleBarLogo.contentMode = .ScaleAspectFit
        titleBarLogo.image = UIImage(named: "ui_nav_title_share")
        navigationItem.titleView = titleBarLogo
        
        self.navigationItem.rightBarButtonItem =  UIBarButtonItem(title: "Back", style: .Plain, target: self, action: "iba_goback:")
        self.navigationItem.leftBarButtonItem =  UIBarButtonItem(title: "New", style: .Plain, target: self, action: "iba_newDesign:")
        
        ibo_userImage.layer.shadowColor = UIColor.blackColor().CGColor
        ibo_userImage.layer.shadowRadius = 2.0
        ibo_userImage.layer.shadowOpacity = 0.5
        ibo_userImage.layer.shadowOffset = CGSizeMake(0,0)
        ibo_userImage.clipsToBounds = false

        
    }
    
    @IBAction func iba_goback(sender:UIBarButtonItem){
        navigationController?.popViewControllerAnimated(true)
    }
    
    func iba_newDesign(sender:UIBarButtonItem){
        
        let alertController = UIAlertController(
            title: "Create New",
            message: "Start new with the freshness?!",
            preferredStyle: .Alert
        )
        
        alertController.addAction(UIAlertAction(title: "Create New", style: .Default) { _ in
            self.navigationController?.popToRootViewControllerAnimated(true)
        })
        
        alertController.addAction(UIAlertAction(title: "No Thanks", style: .Cancel ) { _ in
            alertController.dismissViewControllerAnimated(true, completion: { () -> Void in
                //
            })
        })
        
        presentViewController(alertController, animated: true, completion: nil)
 
    }

    override func viewWillLayoutSubviews() {
        //
    }
    
    override func viewWillAppear(animated: Bool) {
        
        if userImage != nil {
            self.ibo_userImage.image = userImage
        }
        
    }
    @IBAction func iba_shareOnYoshirt(sender:UIButton){
        
        if UIApplication.sharedApplication().canOpenURL(NSURL(string: "yoshirt://")!) == false{
            
            let alertController = UIAlertController(
                title: "Print Yoshirt",
                message: "Looks like you dont have the Yoshirt app installed. Get it for Free from the App Store!",
                preferredStyle: .Alert
            )
            
            alertController.addAction(UIAlertAction(title: "Download Now", style: .Default ) { _ in
                
                    let storeViewer = SKStoreProductViewController()
                    storeViewer.delegate = self
                    let params = [
                        SKStoreProductParameterITunesItemIdentifier:785725887,
                        SKStoreProductParameterAffiliateToken:"10ly5p"
                    ]
                    
                    storeViewer.loadProductWithParameters(params, completionBlock: { (open:Bool, error:NSError?) -> Void in
                        if open {
                            self.presentViewController(storeViewer, animated: true, completion: nil)
                        }
                    })
                    
                })
            
            self.presentViewController(alertController, animated: true, completion:nil)
            
        } else {
            
            UIPasteboard.generalPasteboard().image = self.userImage
            let yoshirtURL = NSURL(string: yoshirtRefURL)
            UIApplication.sharedApplication().openURL(yoshirtURL!)
            
        }
     
        
        
    }
    
    
    func productViewControllerDidFinish(viewController: SKStoreProductViewController) {
        
        viewController.dismissViewControllerAnimated(true) { () -> Void in
            
            if UIApplication.sharedApplication().canOpenURL(NSURL(string: "yoshirt://")!){
                UIPasteboard.generalPasteboard().image = self.userImage
                let yoshirtURL = NSURL(string: self.yoshirtRefURL)
                UIApplication.sharedApplication().openURL(yoshirtURL!)
                
            }
        }
        
       
        
    }
    
    
    @IBAction func iba_shareSnapchat(sender:UIButton){
        
        
        
    }
    
    @IBAction func iba_shareFB(sender:UIButton){
        
        
        
    }
    
//    @IBAction func iba_shareIG(sender:UIButton){
//        
//        var items = [AnyObject]()
//        var activities = [UIActivity]()
//        
//        items.append(UIImage(data: UIImagePNGRepresentation(userImage)!)!)
//        items.append("#Catwang by @99centbrains")
//        
//        activities.append(SafariActivity())
//        activities.append(InstagramActivity(presenter: { (controller: UIDocumentInteractionController) in
//            controller.presentOpenInMenuFromRect(sender.frame, inView: self.view, animated: true)
//        }))
//        
//        print("Selected \(activities.first)...")
//        
//        let controller = UIActivityViewController(activityItems: items, applicationActivities: activities)
//        controller.completionWithItemsHandler = { (type: String?, completed: Bool, returnedItems: [AnyObject]?, error: NSError?) -> Void in
//            print("Type = \(type)")
//            print("Completed = \(completed)")
//            print("ReturnedItems = \(returnedItems)")
//            print("Error = \(error)")
//        }
//        
//        if let popoverController = controller.popoverPresentationController {
//            popoverController.sourceView = sender
//            popoverController.sourceRect = sender.bounds
//        }
//        
//        self.presentViewController(controller, animated: true, completion: nil)
//        
//    }
    
    @IBAction func iba_shareTW(sender:UIButton){
        
        
        
    }
    
    @IBAction func iba_saveToLib(sender:UIButton){
        
       
        
    }
    
    func image(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo:UnsafePointer<Void>) {
            //Saved
    
    }
    
    @IBAction func iba_message(sender:UIButton){
    
        
        
    }
    
    func messageComposeViewController(controller: MFMessageComposeViewController, didFinishWithResult result: MessageComposeResult) {
        
        self.dismissViewControllerAnimated(true) { () -> Void in
            //
        }
    }
    
    
    
}