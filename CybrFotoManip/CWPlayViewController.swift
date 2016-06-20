//
//  CWPlayViewController.swift
//  OMGWTFSTFU
//
//  Created by Franky Aguilar on 9/16/15.
//  Copyright (c) 2015 99centbrains. All rights reserved.
//

import Foundation
import UIKit
import TWPhotoPicker
import SwiftInAppPurchase
import iNotify


class CWPlayViewController:UIViewController, CWToolBarViewControllerDelegate, CWStickerEditVCDelgate, PaintToolViewControllerDelegate, StickerSelectDelegate, UIGestureRecognizerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate, FontToolViewControllerDelegate, CWColorSelectViewControllerDelegate, CFInterWebsViewControllerDelegate, CutOutPainterDelegate {
    //
    
    var ibo_container:CanvasToolContViewController!
    var ibo_toolBar:CWToolBarViewController!
    var ibo_editBar:CWStickerEditViewController!
    var ibo_canvas:CanvasViewController!
    var userImage:UIImage!
    var currentSticker:StickyImageView!
    
    
    var ibo_vcColorSelect:CWColorSelectViewController!
    
    var ibo_toolPainter:PaintToolViewController!
    var ibo_emojiPainter:PaintToolViewController!
    
    var ibo_drawingView:SwiftDrawView!
    var ibo_emojiPaintView:EmojiDrawView!
    
    var ibo_tool_fontEdit:FontToolViewController!
    
    var ibo_shareVC:CWSharePopUpViewController!
    

    var panGesture:UIPanGestureRecognizer!
    var pinchGesture:UIPinchGestureRecognizer!
    var rotateGesture:UIRotationGestureRecognizer!
    var longTapGesture:UILongPressGestureRecognizer!
    
    var newLabel:UITextView!
    
    var boolBackgroundImage = false
    
    override func viewDidLoad() {
        

        
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(patternImage: UIImage(named: "ui_cropview_checkers")!)
        
        createGestures()
        
    }
    
    @IBAction func iba_goback(){
        
        if ibo_tool_fontEdit != nil {
            self.font_done()
            return
        }
        
        
        let alertController = UIAlertController(
            title: "Start Over",
            message: nil,
            preferredStyle: .Alert
        )
        
        
        alertController.addAction(UIAlertAction(title: "Yes", style: .Default) { _ in
            self.navigationController?.popViewControllerAnimated(true)
            iNotify.sharedInstance().checkForNotifications()

            })
        

        
        alertController.addAction(UIAlertAction(title: "Never Mind", style: .Cancel) { _ in
            alertController.dismissViewControllerAnimated(true, completion: { () -> Void in
                //
            })
            })
        
        self.presentViewController(alertController, animated: true, completion: nil)
        
        
        
        
    
    }
    
    func setUpNavbar () {
        

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.changeCurrentSticker(_:)), name:"StickerTap", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        

    }
    
    override func viewWillAppear(animated: Bool) {
        
        setUpNavbar()

        
        
        ibo_canvas.ibo_stickerStage.backgroundColor = UIColor.clearColor()
        if ibo_drawingView == nil {
            setupPainter()
        }
        
        if userImage != nil {
            ibo_canvas.iba_userImage.image = userImage
        }
        
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
       
        NSNotificationCenter.defaultCenter().removeObserver(self)

        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        ibo_drawingView.frame = ibo_canvas.ibo_stickerStage.frame
        ibo_emojiPaintView.frame = ibo_canvas.ibo_stickerStage.frame
        ibo_toolBar.view.frame = ibo_container.view.frame
        
        print(ibo_toolBar.view.frame)
        print(ibo_container.view.frame)
    }
    
    override func viewDidLayoutSubviews() {
    
      
    }
    
    func iba_newDesign(sender:UIBarButtonItem){
        
        let alertController = UIAlertController(
            title: "Create New",
            message: "This will clear your current design. Are you sure you want to continue?",
            preferredStyle: .Alert
        )
        
        alertController.addAction(UIAlertAction(title: "Create New", style: .Default) { _ in
                self.navigationController?.popViewControllerAnimated(true)
        })
        
        alertController.addAction(UIAlertAction(title: "No Thanks", style: .Cancel ) { _ in
            alertController.dismissViewControllerAnimated(true, completion: { () -> Void in
                //
            })
        })
        
        
        presentViewController(alertController, animated: true, completion: nil)

        
        
    }

    func foto_save(){
        NSNotificationCenter.defaultCenter().removeObserver(self)
        
        
        if ibo_vcColorSelect != nil {
            return
        }
        
        edit_stickerDone()
        setBorderOFF()
        iba_dismissEdit()

        renderImage { (image:UIImage) -> () in
            

            //AssetManager().saveLocalImage(image)
            if self.ibo_shareVC == nil {
                self.ibo_shareVC = self.storyboard?.instantiateViewControllerWithIdentifier("sb_CWSharePopUpViewController") as! CWSharePopUpViewController
            }
            self.ibo_shareVC.userImage = UIImage(data: UIImagePNGRepresentation(image)!)
            self.ibo_shareVC.parent = self
            self.ibo_shareVC.view.frame = self.view.frame
            self.view.addSubview(self.ibo_shareVC.view)
            
            
    
        }

    }
    
    
        
        
    func renderImage(callback: (UIImage) -> ()) {
      
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.2 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            
            UIGraphicsBeginImageContextWithOptions(self.ibo_canvas.view.frame.size, false, 0.0)
            self.ibo_canvas.view.layer.renderInContext(UIGraphicsGetCurrentContext()!)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            callback(image)
        }
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        print("This Segue \(segue.identifier)")
        
        if segue.identifier == "sb_CanvasViewController"{
            ibo_canvas = segue.destinationViewController as! CanvasViewController
        }
        
        if segue.identifier == "sb_CanvasToolContViewController" {
            
            ibo_container = segue.destinationViewController as! CanvasToolContViewController
            
            
            ibo_toolBar = storyboard?.instantiateViewControllerWithIdentifier("sb_CWToolBarViewController") as! CWToolBarViewController
            ibo_container.view.addSubview(ibo_toolBar.view)
            
            ibo_toolBar.view.frame = CGRectMake(0, 0, ibo_container.view.frame.width, ibo_container.view.frame.height)
            ibo_toolBar.delegate = self

        }
        
    }
    

    @IBAction func iba_importWeb(){
        
       
    
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("sb_CFInterWebsViewController") as! CFInterWebsViewController
        let nav = UINavigationController(rootViewController: vc)
        vc.delegate = self
        self.presentViewController(nav, animated: true, completion: nil)
    }
    
    /*
    TOOL EDITOR
    */
    
    func foto_import(){
        
        boolBackgroundImage = false
        
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
                    
                    if self.boolBackgroundImage == false {
                        
                        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("sb_CutOutPainter") as! CutOutPainter
                        vc.delegate = self
                        vc.paintedImage = pickedImage
                        self.presentViewController(vc, animated: true, completion: nil)
                        
                    } else {
                        
                        self.ibo_canvas.iba_userImage.image = pickedImage
                        
                    }
                    
                    
                    
                    
                }
            
            
        })
        
        
    }
    
    func cutOutDidFinish(img:UIImage, vc:CutOutPainter){
        
        if currentSticker != nil {
            currentSticker.image = img
            vc.dismissViewControllerAnimated(true, completion: nil)

            return
        }
        
        self.stickerDidFinishChoosing(img)
        vc.dismissViewControllerAnimated(true, completion: nil)
    
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController){
        
        dismissViewControllerAnimated(true, completion: nil)
        
    }
    

    func letUserCreateSticker(img:UIImage!){
        
        self.stickerDidFinishChoosing(img)
        return
        
    }
    
   
    
    
    func tool_clearAll(){
        ibo_canvas.view.backgroundColor = UIColor.clearColor()
        
        for v in ibo_canvas.ibo_stickerStage.subviews {
            v.removeFromSuperview()
        }
        
        ibo_drawingView.clearBitmap()
        ibo_emojiPaintView.clearView()
        
    }

    func tool_background(){
        
        showColorSelector()
        return
    }
    
    func tool_backgroundPhoto(){
        
        boolBackgroundImage = true
        
        let alertController = UIAlertController(
            title: "Background Image",
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
        
        if self.ibo_canvas.iba_userImage.image != nil {
            alertController.addAction(UIAlertAction(title: "Clear Image", style: .Default) { _ in
                imagePicker.sourceType = .PhotoLibrary
                    self.ibo_canvas.iba_userImage.image = nil
                })
        }
        
        alertController.addAction(UIAlertAction(title: "Never Mind", style: .Cancel) { _ in
            alertController.dismissViewControllerAnimated(true, completion: { () -> Void in
                //
            })
            })
        
        
        presentViewController(alertController, animated: true) { () -> Void in
            //
        }
        
        
        
    }
    
    /*
    STICKER SELECT EDIT
    */
    func tool_stickerSelect(){
        
        let stickerBored = UIStoryboard(name: "StickerSelectStoryboard", bundle: nil)
        
        let stickerNC = stickerBored.instantiateInitialViewController() as! UINavigationController
        
        let viewStickers = stickerBored.instantiateViewControllerWithIdentifier("sb_StickerSectionViewController") as! StickerSectionViewController
        viewStickers.delegate = self
        viewStickers.title = "Stickers"
        let stickerdir = [
            "/stickers/com.99centbrains.cybrfm.free00/",
            "/stickers/com.99centbrains.cybrfm.free01/",
            "/stickers/com.99centbrains.cybrfm.icons01/",
            "/stickers/com.99centbrains.cybrfm.icons02/",
            "/stickers/com.99centbrains.cybrfm.3dword/",
            "/stickers/com.99centbrains.cybrfm.seajunk/",
            "/stickers/com.99centbrains.cybrfm.seajunk02/",
            "/stickers/com.99centbrains.cybrfm.seajunk03/",
            "/stickers/com.99centbrains.cybrfm.3dseajunk/",
            "/stickers/com.99cb.cybrfm.trap01/",
            "/stickers/com.99cb.cybrfm.trap02/",
            "/stickers/com.99cb.cybrfm.trap03/",
            "/stickers/com.99cb.cybrfm.trap04/",
            "/stickers/com.99cb.cybrfm.trap05/"
        ]
        viewStickers.loadDirectorys(stickerdir)
        
        let tabbar_stickers = UITabBarItem(title: "Stickers", image: UIImage(named:"ui_tabbar_all"), tag: 1)
        viewStickers.tabBarItem = tabbar_stickers

        stickerNC.pushViewController(viewStickers, animated: false)
        
        
        //////////
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("sb_CFInterWebsViewController") as! CFInterWebsViewController
        
        vc.delegate = self
        let tabbar_tumblr = UITabBarItem(title: "Tumblr", image: UIImage(named:"ui_tabbar_web"), tag: 3)
        vc.tabBarItem = tabbar_tumblr
        vc.title = vc.tabBarItem.title
        
        let webNav = UINavigationController(rootViewController: vc)
        
        ////////
        let tabbar = UITabBarController()
        tabbar.setViewControllers([stickerNC, webNav], animated: true)
                tabbar.tabBar.tintColor = UIColor.darkGrayColor()
        tabbar.tabBar.barTintColor = UIColor.whiteColor()
        
        presentViewController(tabbar, animated: true) { () -> Void in
 
        }
 
    }
    
    func stickerDidFinishChoosing(img:UIImage){
        
        print("dif finish")
        self.dismissViewControllerAnimated(true) { () -> Void in }
        
        
        if ibo_emojiPainter != nil {
            self.ibo_emojiPaintView.image = img
            ibo_emojiPainter.ibo_buttonPicker.setImage(img, forState: .Normal)
            return
        }
        
        //DocumentManager().saveImage(img, directory: kAlbum.kStickers)
        
        
        if currentSticker != nil {
            setBorderOFF()
            currentSticker = nil
        }
        
        let stickerImage = img.imageByTrimmingTransparentPixels()

        
        var imageSize:CGSize
        if stickerImage.size.width < stickerImage.size.height {
            
            imageSize = CGSizeMake(stickerImage.size.width/stickerImage.size.height * 300, 300)
            
        } else {
            
            imageSize = CGSizeMake(300, stickerImage.size.height/stickerImage.size.width * 300)
            
        }
        
        
        let stickyImage = StickyImageView(frame: CGRectMake(0, 0, imageSize.width, imageSize.height))
        stickyImage.stickyKind = StickyImageType.Image
        stickyImage.image = stickerImage
        stickyImage.center = ibo_canvas.ibo_stickerStage.center
        stickyImage.clipsToBounds = true
        stickyImage.contentMode = UIViewContentMode.ScaleAspectFit
        
        currentSticker = stickyImage
        stickyImage.tag = ibo_canvas.ibo_stickerStage.subviews.count + 1
        ibo_canvas.ibo_stickerStage.addSubview(currentSticker)
        
        setBorderON()
    }
    
    func changeCurrentSticker(notification: NSNotification){
        
        setBorderOFF()
        if let tappedObject = notification.object as? StickyImageView {
            currentSticker = tappedObject
            print(tappedObject.tag)
        }
        setBorderON()
        
    }
    
    func setBorderON(){
    
        currentSticker.layer.borderColor = UIColor.magentaColor().CGColor
        currentSticker.layer.borderWidth = 2
        currentSticker.layer.backgroundColor = UIColor(white: 1.0, alpha: 0.5).CGColor
        
        if ibo_editBar == nil {
            
            ibo_editBar = storyboard?.instantiateViewControllerWithIdentifier("sb_CWStickerEditViewController") as! CWStickerEditViewController
            ibo_container.view.addSubview(ibo_editBar.view)
            ibo_canvas.ibo_stickerStage.userInteractionEnabled = true
            ibo_editBar.view.frame = CGRectMake(0, 0, ibo_container.view.frame.size.width, ibo_container.view.frame.size.height)
            ibo_editBar.delegate = self
            
        }
        
    }
    
    func setBorderOFF(){
        
        if  currentSticker != nil {
            currentSticker.layer.borderColor = nil
            currentSticker.layer.borderWidth = 0
            currentSticker.layer.backgroundColor = nil
            
            currentSticker = nil
        }
    }
    
    func createGestures() {
        
        // GESTURES
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.stickyMove(_:)))
        pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(self.stickyPinch(_:)))
        rotateGesture = UIRotationGestureRecognizer(target: self, action: #selector(self.stickyRotate(_:)))
        longTapGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.stickyLongTap(_:)))
        
        panGesture.delegate = self
        pinchGesture.delegate = self
        rotateGesture.delegate = self
        longTapGesture.delegate = self
        
        panGesture.minimumNumberOfTouches = 1
        panGesture.maximumNumberOfTouches = 2
        longTapGesture.minimumPressDuration = 0.5
        
        self.view.addGestureRecognizer(panGesture)
        self.view.addGestureRecognizer(pinchGesture)
        self.view.addGestureRecognizer(rotateGesture)
        self.view.addGestureRecognizer(longTapGesture)
        
        ibo_canvas.view.userInteractionEnabled = true
        
    }
    
    func removeGestures(){
        
        self.view.removeGestureRecognizer(panGesture)
        self.view.removeGestureRecognizer(pinchGesture)
        self.view.removeGestureRecognizer(rotateGesture)
        self.view.removeGestureRecognizer(longTapGesture)
    
    }
    
    //MARK: - Gesture Handlers
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    var lastPinchScale: CGFloat = 1.0
    var currentlyScaling = false
    
    func stickyPinch(recognizer: UIPinchGestureRecognizer) {
        if let sticker = currentSticker {
            if recognizer.state == .Ended {
                currentlyScaling = false
                lastPinchScale = 1.0
                return
            }
            
            
            currentlyScaling = true
            
            let newScale = 1.0 - (lastPinchScale - recognizer.scale)
            
            let currentTransform:CGAffineTransform = currentSticker.transform
            let newTransform = CGAffineTransformScale(currentTransform, newScale, newScale)
            
            sticker.transform = newTransform
            
            lastPinchScale = recognizer.scale

        }
    
    }
    
    var currentlyRotating:Bool = false
    var lastRotation: CGFloat = 0
    func stickyRotate(recognizer: UIRotationGestureRecognizer) {
        if let sticker = currentSticker {
            
            
            if recognizer.state == .Ended {
                
                currentlyRotating = false
                lastRotation = 0.0
                return
            }
            
            currentlyRotating = true
            
            let newRotation = 0.0 - (lastRotation - recognizer.rotation)
            
            let currentTransform:CGAffineTransform = currentSticker.transform
            let newTransform = CGAffineTransformRotate(currentTransform, newRotation)
            
            sticker.transform = newTransform
            lastRotation = recognizer.rotation
            
            }
    }
    
    var lastMoveCenter = CGPoint(x: 0, y: 0)
    func stickyMove(recognizer: UIPanGestureRecognizer) {
        
        if let sticker = currentSticker {
            
            ibo_canvas.ibo_stickerStage.bringSubviewToFront(sticker)
            
            var newCenter = recognizer.translationInView(self.view)

            if recognizer.state == .Began {
                
                lastMoveCenter = CGPointMake(currentSticker.center.x, currentSticker.center.y)
            
            }
            
            newCenter = CGPointMake(lastMoveCenter.x + newCenter.x, lastMoveCenter.y + newCenter.y)
            sticker.center = newCenter

        }
    }
    
    func stickyLongTap(recognizer: UIPanGestureRecognizer) {
       //return
        
        if let sticker = currentSticker {
            sticker.superview?.bringSubviewToFront(sticker)
        }
        
    }



    /*
    FONT TOOL
    */
    func tool_fontTyper(){
        
        if newLabel != nil {
            return
        }
        
        setBorderOFF()
        
        newLabel = UITextView(frame: CGRectMake(0, 64, ibo_canvas.view.frame.size.width, ibo_canvas.view.frame.size.width/3 * 2))
        newLabel.backgroundColor = UIColor.clearColor()
        newLabel.text = "Type to Edit"
        newLabel.font = UIFont(name: "ArialRoundedMTBold", size: 64)
        newLabel.textAlignment = .Center
        newLabel.clearsOnInsertion = true
        newLabel.autocorrectionType = .No
        newLabel.delegate = self
        newLabel.becomeFirstResponder()

        newLabel.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
        
        self.view.addSubview(newLabel)
        
        ibo_canvas.view.alpha = 0.20
        

    }
    
    func keyboardWillShow(sender: NSNotification) {
        
        print("Keybaord Up")
        
        if let userInfo = sender.userInfo {
            if let keyboardSize = userInfo[UIKeyboardFrameBeginUserInfoKey]?.CGRectValue {
    
                if ibo_tool_fontEdit == nil {
                    ibo_tool_fontEdit = storyboard?.instantiateViewControllerWithIdentifier("seg_FontToolViewController") as! FontToolViewController
                    ibo_tool_fontEdit.delegate = self
                    let height = self.view.frame.size.height - keyboardSize.size.height - 50
                    ibo_tool_fontEdit.view.frame = CGRectMake(0, height, self.view.frame.size.width, 50)
                    self.view.addSubview(ibo_tool_fontEdit.view)
                }
                
            }
        }
    }
    func font_done(){
        self.iba_dismissEdit()
    }
    
    func iba_dismissEdit() {
        
        if ibo_tool_fontEdit != nil {
            
            ibo_canvas.view.alpha = 1.0
            
            ibo_tool_fontEdit.view.removeFromSuperview()
            ibo_tool_fontEdit.delegate = nil
            ibo_tool_fontEdit = nil
            
            newLabel.resignFirstResponder()
            
            newLabel.backgroundColor = UIColor.clearColor()
            newLabel.frame = CGRectMake(0, 0, newLabel.contentSize.width, newLabel.contentSize.height)
            
            
            UIGraphicsBeginImageContextWithOptions(newLabel.textInputView.frame.size, false, 4)
            newLabel.layer.renderInContext(UIGraphicsGetCurrentContext()!)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            self.textTyperDidFinishPicking(image)
            
            //Clean Up
            newLabel.removeFromSuperview()
            newLabel.delegate = nil
            newLabel.userInteractionEnabled = false
            newLabel = nil
            
            
            
            setUpNavbar()
        }

    }
    
    func font_changeColor(){
        
        newLabel.resignFirstResponder()
        showColorSelector()
    
    }
    
    func font_toggleAlignment(){
        
        let currentAlign:NSTextAlignment = newLabel.textAlignment
        
        switch currentAlign {
            
        case NSTextAlignment.Left:
            newLabel.textAlignment = NSTextAlignment.Right
            
        case NSTextAlignment.Center:
            newLabel.textAlignment = NSTextAlignment.Left
            
        case NSTextAlignment.Right:
            newLabel.textAlignment = NSTextAlignment.Center
            //
        
        default: break
           //
        }
    
    }
    
    func font_sizeUp(){
        
        newLabel.font = UIFont(name: newLabel.font!.fontName, size: newLabel.font!.pointSize + 10)
    
    }
    func font_sizeDown(){
        
        newLabel.font = UIFont(name: newLabel.font!.fontName, size: newLabel.font!.pointSize - 10)
    
    }
    func font_chooseFont(font:UIFont){
        
        newLabel.font = UIFont(name: font.fontName, size: newLabel.font!.pointSize)

    }
    
    func font_changeSaying(string:String){
        newLabel.text = string
    }
    
    func textTyperDidFinishPicking(img:UIImage){
       
        
        if ibo_vcColorSelect != nil {
            return
        }
        
        if currentSticker != nil {
            setBorderOFF()
            currentSticker = nil
        }
        
        let textImage = img.imageByTrimmingTransparentPixels()
        
        var imageSize:CGSize
        if textImage.size.width < textImage.size.height {
            
            imageSize = CGSizeMake(textImage.size.width/textImage.size.height * 300, 300)
        
        } else {
            
            imageSize = CGSizeMake(300, textImage.size.height/textImage.size.width * 300)
            
        }
        
        let stickyImage = StickyImageView(frame: CGRectMake(0, 0, imageSize.width, imageSize.height))
        stickyImage.stickyKind = StickyImageType.Text
        stickyImage.image = textImage
        stickyImage.center = ibo_canvas.ibo_stickerStage.center
        stickyImage.clipsToBounds = true
        stickyImage.contentMode = UIViewContentMode.ScaleAspectFit

        stickyImage.layer.shadowColor = UIColor.cyanColor().CGColor
        stickyImage.layer.shadowRadius = 0
        stickyImage.layer.shadowOffset = CGSizeMake(3, 3)
        stickyImage.layer.shadowOpacity = 1
        
        currentSticker = stickyImage
        stickyImage.tag = ibo_canvas.ibo_stickerStage.subviews.count + 1
        ibo_canvas.ibo_stickerStage.addSubview(currentSticker)
        ibo_canvas.view.alpha = 1.0
        
        setBorderON()
    }

    
    /*
    PAINTER EDIT
    */
    
    func tool_paintSelect(){
        
        ibo_toolPainter = storyboard?.instantiateViewControllerWithIdentifier("seg_PaintToolViewController") as! PaintToolViewController
        ibo_container.view.addSubview(ibo_toolPainter.view)
        ibo_canvas.ibo_stickerStage.userInteractionEnabled = false
        ibo_drawingView.userInteractionEnabled = true
        ibo_toolPainter.view.frame = CGRectMake(0, 0, ibo_container.view.frame.size.width, ibo_container.view.frame.size.height)
        ibo_toolPainter.delegate = self

        removeGestures()
        
    
    }
    
    func tool_paintMoji(){
               
        ibo_emojiPainter = storyboard?.instantiateViewControllerWithIdentifier("seg_EmojiToolViewController") as! PaintToolViewController
        ibo_container.view.addSubview(ibo_emojiPainter.view)
        ibo_canvas.ibo_stickerStage.userInteractionEnabled = false
        ibo_emojiPaintView.userInteractionEnabled = true
        ibo_emojiPainter.view.frame = CGRectMake(0, 0, ibo_container.view.frame.size.width, ibo_container.view.frame.size.height)
        ibo_emojiPainter.delegate = self
        
        ibo_emojiPainter.ibo_buttonPicker.setImage(ibo_emojiPaintView.image, forState: .Normal)
        
        removeGestures()
    
    }
    
    func paintSelectImage() {
        print("paint Select Image")
        
       tool_stickerSelect ()
        
    }
    
    var paintSize:CGFloat = 25.0
    
    func paintSizeAnimate(size:CGFloat, isPainter:Bool){
        
        print("paintSizeAnimate")
        
        let sampleView = UIImageView(frame: CGRectMake(0, 0, size, size))
        sampleView.center = ibo_canvas.view.center
        
        if isPainter {
            
            sampleView.backgroundColor = ibo_drawingView.lineColor
            sampleView.layer.cornerRadius = size/2
            sampleView.layer.borderColor = UIColor.blackColor().CGColor
            sampleView.layer.borderWidth = 2.0
            
        } else {
            
            sampleView.image = ibo_emojiPaintView.image
            
        }
        
        
        ibo_canvas.view.addSubview(sampleView)
        
        
        UIView.animateWithDuration(0.5, delay: 0.0, options: .CurveEaseOut, animations: {
           
            sampleView.alpha = 0
        
            }, completion: { finished in

                sampleView.removeFromSuperview()
                
            })
        
        paint_setSize(size)
    
    }
    
    
    
    func setupPainter(){
        
        ibo_drawingView = SwiftDrawView(frame: CGRectMake(0, 0, ibo_canvas.view.frame.width, ibo_canvas.view.frame.height))
        ibo_canvas.view.insertSubview(ibo_drawingView, belowSubview: ibo_canvas.ibo_stickerStage)
        ibo_drawingView.lineWidth = paintSize
        ibo_drawingView.userInteractionEnabled = false
        
//        ibo_drawingView.layer.shadowColor = UIColor.cyanColor().CGColor
//        ibo_drawingView.layer.shadowOffset = CGSizeMake(0, 0)
//        ibo_drawingView.layer.shadowRadius = 10
//        ibo_drawingView.layer.shadowOpacity = 1.0
        
        ibo_emojiPaintView = EmojiDrawView(frame: CGRectMake(0, 0, ibo_canvas.view.frame.width, ibo_canvas.view.frame.height))
        ibo_canvas.view.insertSubview(ibo_emojiPaintView, belowSubview: ibo_canvas.ibo_stickerStage)
        ibo_emojiPaintView.brushSize = paintSize
        ibo_emojiPaintView.userInteractionEnabled = false
        
        print(ibo_canvas.view.frame)
        print(ibo_drawingView.frame)
        
    }
    
    func paint_setSizeUP(isPaint:Bool){
        
        var currentsize = ibo_emojiPaintView.brushSize
        
        if currentsize > 150 {
            currentsize = 0
        }
        
        currentsize = currentsize + 25.0
        
        paintSizeAnimate(currentsize, isPainter: isPaint)
    
    }
    func paint_setSizeDown(isPaint:Bool){
        
        var currentsize = ibo_emojiPaintView.brushSize
        currentsize = currentsize - 25.0
        
        if currentsize <= 0 {
            currentsize = 25
        }
        
        paintSizeAnimate(currentsize, isPainter: isPaint)
    
    }
    
    func paint_setSize(size:CGFloat){
        
        ibo_emojiPaintView.brushSize = size
        ibo_drawingView.lineWidth = size

    }
    
    func paint_toggleEraser(state:Bool){
        
        if ibo_drawingView.eraserMode {
            ibo_drawingView.eraserMode = false
        } else {
            ibo_drawingView.eraserMode = true
        }
        
    }
    
    func paintSelectColor(){
       showColorSelector()
    }
    
    func paint_setImage(img:UIImage){
        
        
        ibo_emojiPaintView.image = img
        
    }
    
    func paint_clear() {
        if ibo_emojiPainter != nil {
            ibo_emojiPaintView.clearView()
        } else {
            ibo_drawingView.clearBitmap()
        }
    }
    
     func paint_popout(){
      
        
    
            
            let painter = ibo_drawingView.renderSticker()
            if painter == nil {
                return
            }
            paint_dismiss()
            stickerDidFinishChoosing(painter!)
        

    }
    
    func emoji_popOut(){
    
        let painter = ibo_emojiPaintView.renderSticker()
        if painter == nil {
            return
        }
        
        paint_dismiss()
        stickerDidFinishChoosing(painter!)
        
    
    }


    func paint_undo(){
    
    }
    func paint_dismiss(){
        
        ibo_drawingView.userInteractionEnabled = false
        ibo_emojiPaintView.userInteractionEnabled = false
        ibo_canvas.ibo_stickerStage.userInteractionEnabled = true
        
        createGestures()
        
        if ibo_emojiPainter != nil{
            
            ibo_emojiPainter.delegate = nil
            ibo_emojiPainter.view.removeFromSuperview()
            ibo_emojiPainter = nil
        
        } else {
            
            ibo_toolPainter.delegate = nil
            ibo_toolPainter.view.removeFromSuperview()
            ibo_toolPainter = nil
            
        }

    }
    
    
    /*
    STICKER EDIT
    */
    
    func edit_stickerDone() {
        
        setBorderOFF()
        
        if ibo_editBar != nil {
        
            ibo_editBar.delegate = nil
            ibo_editBar.view.removeFromSuperview()
            ibo_editBar = nil
            
        }
        
        
    }
    
    func edit_stickerTrash(){
        
        currentSticker.removeFromSuperview()
        setBorderOFF()
        
        ibo_editBar.delegate = nil
        ibo_editBar.view.removeFromSuperview()
        ibo_editBar = nil
    
    }
    func edit_flip(){
        
        currentSticker.flipSticker()
    
    }
    func edit_copy(){
        let oldSticker = currentSticker
        let stickerPoint = oldSticker.center//OLD CENTER
        
        stickerDidFinishChoosing(currentSticker.image!)
        
        currentSticker.center = CGPointMake(stickerPoint.x + 10, stickerPoint.y + 10)
        currentSticker.transform = oldSticker.transform
        
    
    }
    func edit_layerUp(){
        
        if let stickerViews = ibo_canvas.ibo_stickerStage.subviews as? [StickyImageView] {
            
            //swift 2.0 change this ~ let indexOfA = arr.indexOf("a") // 0
            let stickerIndex = stickerViews.indexOf(currentSticker)
            ibo_canvas.ibo_stickerStage.exchangeSubviewAtIndex(stickerIndex!, withSubviewAtIndex: stickerIndex! + 1)
            
        }
        
    
    }
    func edit_layerDown(){
        
        if let stickerViews = ibo_canvas.ibo_stickerStage.subviews as? [StickyImageView] {
  
            //swift 2.0 change this ~ let indexOfA = arr.indexOf("a") // 0
            let stickerIndex = stickerViews.indexOf(currentSticker)
            ibo_canvas.ibo_stickerStage.exchangeSubviewAtIndex(stickerIndex!, withSubviewAtIndex: stickerIndex! - 1)
        
        }

    }
    

    
    func edit_reflect(){
        
        var oldSticker = currentSticker
        let stickerPoint = oldSticker.center//OLD CENTER
        
        //GET OLD ROTATION to DEGREE FROM RADIAN
        let zKeyPath = "layer.presentationLayer.transform.rotation.z"
        let imageRotation = (oldSticker.valueForKeyPath(zKeyPath) as? NSNumber)?.floatValue ?? 0.0
        let degreesRotated = radiansToDegrees(Double(imageRotation))

        //MAKE NEW STICKER
        stickerDidFinishChoosing(oldSticker.image!)
        
        // COPY TO OPOSITE X
        let newXPoint = ibo_canvas.ibo_stickerStage.frame.size.width - stickerPoint.x
        currentSticker.center = CGPointMake(newXPoint, stickerPoint.y)
        currentSticker.flipSticker()

        //REVERSE ROTATION
        var newRotation:CGFloat!
        if currentSticker.frame.origin.x <= ibo_canvas.ibo_stickerStage.frame.size.width {
            newRotation = degreesRotated * -2.0
        } else {
           newRotation = degreesRotated * 2.0
        }
        
        //APPLY TRANSFORMS
        currentSticker.transform = CGAffineTransformScale(oldSticker.transform, 1, 1)
        currentSticker.transform = CGAffineTransformRotate(currentSticker.transform, degreesToRadians(newRotation))
        
        oldSticker = nil
        

    }
    
    func edit_editImage() {
        
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("sb_CutOutPainter") as! CutOutPainter
        vc.delegate = self
        vc.paintedImage = self.currentSticker.image
        self.presentViewController(vc, animated: true, completion: nil)
        
        
        
    }
    
    func degreesToRadians (val:CGFloat) -> CGFloat {
        let rad = val * CGFloat((M_PI / 180.0))
        return CGFloat(rad)
    }
    
    func radiansToDegrees (value:Double) -> CGFloat {
        let rad = value * 180.0 / M_PI
         return CGFloat(rad)
    }
    
    /*
    TOOL EDITOR
    */
    
    
    /*
    COLOR DELEGATES
    */
    
    func showColorSelector(){
        
        ibo_vcColorSelect = CWColorSelectViewController()
        ibo_vcColorSelect = storyboard?.instantiateViewControllerWithIdentifier("sb_CWColorSelectViewController") as! CWColorSelectViewController
        ibo_vcColorSelect.delegate = self
        ibo_vcColorSelect.view.frame = self.view.frame
        self.view.addSubview(ibo_vcColorSelect.view)
        
    }
    
    func colorSelectChoseColor(color:UIColor){

        if newLabel != nil {
            
            newLabel.textColor = color
            
        } else if ibo_toolPainter != nil {
            
            ibo_drawingView.lineColor = color
            
        } else {
            
            self.ibo_canvas.view.backgroundColor = color
        
        }
        
        colorSelectDismiss()
        
    }
    
    func colorSelectDismiss(){
        
        ibo_vcColorSelect.view.removeFromSuperview()
        ibo_vcColorSelect.delegate = nil
        ibo_vcColorSelect = nil
        
        if newLabel != nil {
            newLabel.becomeFirstResponder()
        }
        
        
    }

    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    
}

//// MARK: - IMCollectionViewDelegate
//extension IMCreateArtmojiViewController: IMCollectionViewDelegate {
//    public func userDidSelectImoji(imoji: IMImojiObject, fromCollectionView collectionView: IMCollectionView) {
//        createArtmojiView.addImoji(imoji)
//    }
//}



class CanvasToolContViewController: UIViewController {
    
    //
}