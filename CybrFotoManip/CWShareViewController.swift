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
    
    func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo:UnsafeRawPointer) {
        
    }
    
    @IBAction func iba_mms(){
        
        if MFMessageComposeViewController.canSendText() == false {
            
            let alert = UIAlertController(title: "Oops", message: "Cant send message with this device!", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
        } else {
            
            let messageVC = MFMessageComposeViewController()
            messageVC.body = "Catwang by @99centbrains";
            messageVC.addAttachmentData(UIImagePNGRepresentation(userImage)!, typeIdentifier: kUTTypePNG as String, filename: "catwang.png")
            messageVC.messageComposeDelegate = self;
            
            self.present(messageVC, animated: false, completion: nil)
            
        }
        
    }
    
    @IBAction func iba_facebook(){
        
        if SLComposeViewController.isAvailable(forServiceType: SLServiceTypeFacebook) {
            
            let fbShare:SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
            fbShare.add(userImage)
            self.present(fbShare, animated: true, completion: nil)
            
        } else {
            
            let alert = UIAlertController(title: "Accounts", message: "Please login to a Facebook account to share.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
        }
        
    }
    
    @IBAction func iba_twitter(){
        
        if SLComposeViewController.isAvailable(forServiceType: SLServiceTypeTwitter) {
            
            let tweetShare:SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
            tweetShare.add(userImage)
            self.present(tweetShare, animated: true, completion: nil)
            
        } else {
            
            let alert = UIAlertController(title: "Accounts", message: "Please login to a Twitter account to tweet.", preferredStyle: UIAlertControllerStyle.alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
    @IBAction func iba_snapchat(){
        
        if UIApplication.shared.canOpenURL(URL(string: "snapchat://")!) == false{
            
            let alertController = UIAlertController(
                title: "Oops!",
                message: "Looks like you dont have that app installed.",
                preferredStyle: .alert
            )
            
            alertController.addAction(UIAlertAction(title: "Die", style: .cancel ) { _ in
                alertController.dismiss(animated: true, completion: { () -> Void in
                    
                })
                })
            
            self.present(alertController, animated: true, completion: { () -> Void in
                //
            })
            
        } else {
            
            let pngPath = NSHomeDirectory() + "/Documents/99centbrains.png"
            try? UIImagePNGRepresentation(userImage)?.write(to: URL(fileURLWithPath: pngPath), options: [.atomic])
            
            let url = URL(fileURLWithPath: pngPath)
            
            let interactionController = UIDocumentInteractionController(url: url)
            interactionController.delegate = self
            
            uiDocController = interactionController;
            let rect = CGRect(x: 0 ,y: 0 , width: 0, height: 0);
            uiDocController.presentOpenInMenu(from: rect, in: self.view, animated: true)
            
        }
        
    }
    
    @IBAction func iba_tumblr(){
        
        if (TMTumblrAppClient.isTumblrInstalled()) {
            //
            UIPasteboard.general.image = UIImage(data: UIImagePNGRepresentation(userImage)!)
            let post = "tumblr://x-callback-url/photo?caption=Cybrfm&tags=cybrfm&tags=cyberart&tags=netart&tags=vaporart"
            let url = URL(string: post)!
            UIApplication.shared.openURL(url)
            
        } else {
            
            let pngPath = NSHomeDirectory() + "/Documents/99centbrains.png"
            try? UIImagePNGRepresentation(userImage)?.write(to: URL(fileURLWithPath: pngPath), options: [.atomic])
            
            let url = URL(fileURLWithPath: pngPath)
            
            let interactionController = UIDocumentInteractionController(url: url)
            interactionController.delegate = self
            
            uiDocController = interactionController;
            let rect = CGRect(x: 0 ,y: 0 , width: 0, height: 0);
            uiDocController.presentOpenInMenu(from: rect, in: self.view, animated: true)
            
        }
        

        
        
        
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        
        self.dismiss(animated: true) { () -> Void in
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
        
        let titleBarLogo = UIImageView(frame: CGRect(x: 0, y: 0, width: 130, height: 30))
        titleBarLogo.contentMode = .scaleAspectFit
        titleBarLogo.image = UIImage(named: "ui_nav_title_share")
        navigationItem.titleView = titleBarLogo
        
        self.navigationItem.rightBarButtonItem =  UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(CWShareViewController.iba_goback(_:)))
        self.navigationItem.leftBarButtonItem =  UIBarButtonItem(title: "New", style: .plain, target: self, action: #selector(CWShareViewController.iba_newDesign(_:)))
        
        ibo_userImage.layer.shadowColor = UIColor.black.cgColor
        ibo_userImage.layer.shadowRadius = 2.0
        ibo_userImage.layer.shadowOpacity = 0.5
        ibo_userImage.layer.shadowOffset = CGSize(width: 0,height: 0)
        ibo_userImage.clipsToBounds = false

        
    }
    
    @IBAction func iba_goback(_ sender:UIBarButtonItem){
        navigationController?.popViewController(animated: true)
    }
    
    func iba_newDesign(_ sender:UIBarButtonItem){
        
        let alertController = UIAlertController(
            title: "Create New",
            message: "Start new with the freshness?!",
            preferredStyle: .alert
        )
        
        alertController.addAction(UIAlertAction(title: "Create New", style: .default) { _ in
            self.navigationController?.popToRootViewController(animated: true)
        })
        
        alertController.addAction(UIAlertAction(title: "No Thanks", style: .cancel ) { _ in
            alertController.dismiss(animated: true, completion: { () -> Void in
                //
            })
        })
        
        present(alertController, animated: true, completion: nil)
 
    }

    override func viewWillLayoutSubviews() {
        //
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if userImage != nil {
            self.ibo_userImage.image = userImage
        }
        
    }
    @IBAction func iba_shareOnYoshirt(_ sender:UIButton){
        
        if UIApplication.shared.canOpenURL(URL(string: "yoshirt://")!) == false{
            
            let alertController = UIAlertController(
                title: "Print Yoshirt",
                message: "Looks like you dont have the Yoshirt app installed. Get it for Free from the App Store!",
                preferredStyle: .alert
            )
            
            alertController.addAction(UIAlertAction(title: "Download Now", style: .default ) { _ in
                
                    let storeViewer = SKStoreProductViewController()
                    storeViewer.delegate = self
                    let params = [
                        SKStoreProductParameterITunesItemIdentifier:785725887,
                        SKStoreProductParameterAffiliateToken:"10ly5p"
                    ] as [String : Any]
                    
                    storeViewer.loadProduct(withParameters: params, completionBlock: { (open:Bool, error:NSError?) -> Void in
                        if open {
                            self.present(storeViewer, animated: true, completion: nil)
                        }
                    } as! (Bool, Error?) -> Void)
                    
                })
            
            self.present(alertController, animated: true, completion:nil)
            
        } else {
            
            UIPasteboard.general.image = self.userImage
            let yoshirtURL = URL(string: yoshirtRefURL)
            UIApplication.shared.openURL(yoshirtURL!)
            
        }
     
        
        
    }
    
    
    func productViewControllerDidFinish(_ viewController: SKStoreProductViewController) {
        
        viewController.dismiss(animated: true) { () -> Void in
            
            if UIApplication.shared.canOpenURL(URL(string: "yoshirt://")!){
                UIPasteboard.general.image = self.userImage
                let yoshirtURL = URL(string: self.yoshirtRefURL)
                UIApplication.shared.openURL(yoshirtURL!)
                
            }
        }
        
       
        
    }
    
    
    @IBAction func iba_shareSnapchat(_ sender:UIButton){
        
        
        
    }
    
    @IBAction func iba_shareFB(_ sender:UIButton){
        
        
        
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
    
    @IBAction func iba_shareTW(_ sender:UIButton){
        
        
        
    }
    
    @IBAction func iba_saveToLib(_ sender:UIButton){
        
       
        
    }
    
    func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo:UnsafeRawPointer) {
            //Saved
    
    }
    
    @IBAction func iba_message(_ sender:UIButton){
    
        
        
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        
        self.dismiss(animated: true) { () -> Void in
            //
        }
    }
    
    
    
}
