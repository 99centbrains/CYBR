//
//  ViewController.swift
//  CatwangFree
//
//  Created by Franky Aguilar on 9/16/15.
//  Copyright (c) 2015 99centbrains. All rights reserved.
//

import UIKit
import Foundation
import SafariServices
import TAPromotee
import iNotify
class ViewController: UIViewController , UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    @IBOutlet weak var ibo_systemModel:UILabel!
    @IBOutlet weak var ibo_backgroundView:UIImageView!

    override func viewDidLoad() {
        
       
        
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //SET FREE STICKERS//
        
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: "com.99centbrains.cybrfm.free00")
         NSUserDefaults.standardUserDefaults().setBool(true, forKey: "com.99centbrains.cybrfm.free01")
        
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: "emojitab01")
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: "emojitab02")
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: "emojitab03")
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: "emojitab04")
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: "emojitab05")
  
        navigationController?.navigationBar.tintColor = UIColor.magentaColor()
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "ui_cropview_checkers")!)
        
        let bundle = NSBundle.mainBundle().infoDictionary!["CFBundleName"] as! String
        let version = NSBundle.mainBundle().infoDictionary!["CFBundleShortVersionString"] as! String
        ibo_systemModel.text = "\(bundle)::\(version)"
    
        
        
        
//        if DocumentManager().getSavedImages(kAlbum.kSettings).count > 0 {
//            let file = DocumentManager().getFullAssetName(kAlbum.kSettings, file: DocumentManager().getSavedImages(kAlbum.kSettings)[0])
//            let img = UIImage(contentsOfFile: file)
//            self.ibo_backgroundView.image = img
//        }
        
        for family in UIFont.familyNames() as [String]
        {
            //print("\(family)")
            
            for name in UIFont.fontNamesForFamilyName(family)
            {
                print("   \(name)")
            }
        }
        
       
        //PushReview.scheduleReviewNotification()
        
        //CrossPromoManager().retrievePromoIDS(self)
    
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func viewWillAppear(animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: false)
        
//        arr_userImages = [""]
//        if let images = AssetManager().getSavedImages() {
//            
//            arr_userImages += images
//        
//        }
//        
    }
    
    override func viewDidAppear(animated: Bool) {
        
        super.viewDidAppear(animated)
        
        
    
    }
    
    override func viewDidLayoutSubviews() {
        //
        super.viewDidLayoutSubviews()
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func iba_openEditor(){
        
        let storyboard = self.storyboard
        let playView = storyboard?.instantiateViewControllerWithIdentifier("sb_CWPlayViewController") as! CWPlayViewController
        self.navigationController?.pushViewController(playView, animated: true)

    }
    
    @IBAction func iba_openEdits(){
    
    }
    
    @IBAction func iba_openInternet(){
    
    }
    
    @IBAction func iba_openTwitter(){
        
        let webview = SFSafariViewController(URL: NSURL(string:"https://twitter.com/search?f=images&vertical=default&q=cybrfm&src=typd")!)
        self.presentViewController(webview, animated: true, completion: nil)
    
    }
    
    @IBAction func iba_openSettings(){
        
        let alertController = UIAlertController(
            title: "Choose Image",
            message: nil,
            preferredStyle: .ActionSheet
        )
        
        let imagePicker = UIImagePickerController()
        
        imagePicker.allowsEditing = false
        imagePicker.delegate = self
        
        alertController.addAction(UIAlertAction(title: "Camera", style: .Default) { _ in
            imagePicker.sourceType = .Camera
            self.presentViewController(imagePicker, animated: true, completion: nil)
            })
        
        alertController.addAction(UIAlertAction(title: "Photo Library", style: .Default) { _ in
            imagePicker.sourceType = .PhotoLibrary
            self.presentViewController(imagePicker, animated: true, completion: nil)
            })
        
        if ibo_backgroundView.image != nil {
            alertController.addAction(UIAlertAction(title: "Clear", style: .Default) { _ in
                imagePicker.sourceType = .PhotoLibrary
                self.ibo_backgroundView.image = nil
                DocumentManager().clearDirectory(kAlbum.kSettings)
            })
        }
        
        alertController.addAction(UIAlertAction(title: "Never Mind", style: .Cancel) { _ in
            alertController.dismissViewControllerAnimated(true, completion: { () -> Void in
                //
            })
            })
        //
        //        if let popoverController = alertController.popoverPresentationController {
        //            popoverController.sourceView = sender
        //            popoverController.sourceRect = sender.bounds
        //        }
        
        
        presentViewController(alertController, animated: true) { () -> Void in
            //
        }

        
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        dismissViewControllerAnimated(true, completion: { () -> Void in
            
            print("Dismiss")
            if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
                
                self.ibo_backgroundView.image = pickedImage
                DocumentManager().clearDirectory(kAlbum.kSettings)
                DocumentManager().saveImage(pickedImage, directory: kAlbum.kSettings)
                
            }
            
        })
        
        
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController){
        
        dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    
    @IBAction func iba_openTexter(){
        
    }
    
    
    @IBAction func iba_openChatter(){
        
        let webview = SFSafariViewController(URL: NSURL(string:"http://cybrfm.chatango.com")!)
        self.presentViewController(webview, animated: true, completion: nil)
        
    }
    
  
}

class HeaderCollectionCell:UICollectionReusableView {
    
    @IBOutlet var ibo_backgroundView:UIView!
    @IBOutlet var ibo_dailyImage:UIImageView!
    
    func setView(){
    
//        ibo_backgroundView.backgroundColor = UIColor(patternImage: UIImage(named: "ui_cropview_checkers")!)
//        
//        TMAPIClient.sharedInstance().OAuthConsumerKey = "c5GyLE1sxb1h7DIcAQu3Dum6ALeZGMssHuaL2XWv0es5Ayhh6S"
//        TMAPIClient.sharedInstance().posts("cybrfm.99centbrains.com", type: "photo", parameters:
//            ["limit" : 1, "offset" : 0, "filter" : "raw"]) { (result:AnyObject!, error:NSError!) -> Void in
//                
//                if (error == nil){
//                    
//                    //print(result)
//                    
//                }
//        }

    }
    
    
}

class UserImageCollectionCell:UICollectionViewCell {
    
    var userImagePath:String!
    @IBOutlet var ibo_imagePath:UIImageView!
    
    func setupImage(path:String){
        
        ibo_imagePath.image = nil
        
        print(path)
        
        let image = UIImage(contentsOfFile: path)
        if image != nil {
            ibo_imagePath.image = image
        }
        
    }
    
}

