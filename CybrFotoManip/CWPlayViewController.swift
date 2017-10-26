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
import iNotify
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func <= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l <= r
  default:
    return !(rhs < lhs)
  }
}



class CWPlayViewController:UIViewController, CWToolBarViewControllerDelegate, CWStickerEditVCDelgate, PaintToolViewControllerDelegate, StickerSelectDelegate, UIGestureRecognizerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate, FontToolViewControllerDelegate, CWColorSelectViewControllerDelegate, CFInterWebsViewControllerDelegate, CutOutPainterDelegate {
    //
    
    @objc var ibo_container:CanvasToolContViewController!
    @objc var ibo_toolBar:CWToolBarViewController!
    @objc var ibo_editBar:CWStickerEditViewController!
    @objc var ibo_canvas:CanvasViewController!
    @objc var userImage:UIImage!
    @objc var currentSticker:StickyImageView!
    
    
    @objc var ibo_vcColorSelect:CWColorSelectViewController!
    
    @objc var ibo_toolPainter:PaintToolViewController!
    @objc var ibo_emojiPainter:PaintToolViewController!
    
    @objc var ibo_drawingView:SwiftDrawView!
    @objc var ibo_emojiPaintView:EmojiDrawView!
    
    @objc var ibo_tool_fontEdit:FontToolViewController!
    
    @objc var ibo_shareVC:CWSharePopUpViewController!
    

    @objc var panGesture:UIPanGestureRecognizer!
    @objc var pinchGesture:UIPinchGestureRecognizer!
    @objc var rotateGesture:UIRotationGestureRecognizer!
    @objc var longTapGesture:UILongPressGestureRecognizer!
    
    @objc var newLabel:UITextView!
    
    @objc var boolBackgroundImage = false
    
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
            preferredStyle: .alert
        )
        
        
        alertController.addAction(UIAlertAction(title: "Yes", style: .default) { _ in
            self.navigationController?.popViewController(animated: true)
            iNotify.sharedInstance().checkForNotifications()

            })
        

        
        alertController.addAction(UIAlertAction(title: "Never Mind", style: .cancel) { _ in
            alertController.dismiss(animated: true, completion: { () -> Void in
                //
            })
            })
        
        self.present(alertController, animated: true, completion: nil)
        
        
        
        
    
    }
    
    @objc func setUpNavbar () {
        

        NotificationCenter.default.addObserver(self, selector: #selector(self.changeCurrentSticker(_:)), name:NSNotification.Name(rawValue: "StickerTap"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        

    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        setUpNavbar()

        
        
        ibo_canvas.ibo_stickerStage.backgroundColor = UIColor.clear
        if ibo_drawingView == nil {
            setupPainter()
        }
        
        if userImage != nil {
            ibo_canvas.iba_userImage.image = userImage
        }
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
       
        NotificationCenter.default.removeObserver(self)

        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        ibo_drawingView.frame = ibo_canvas.ibo_stickerStage.frame
        ibo_emojiPaintView.frame = ibo_canvas.ibo_stickerStage.frame
        ibo_toolBar.view.frame = ibo_container.view.frame
        
        print(ibo_toolBar.view.frame)
        print(ibo_container.view.frame)
    }
    
    override func viewDidLayoutSubviews() {
    
      
    }
    
    @objc func iba_newDesign(_ sender:UIBarButtonItem){
        
        let alertController = UIAlertController(
            title: "Create New",
            message: "This will clear your current design. Are you sure you want to continue?",
            preferredStyle: .alert
        )
        
        alertController.addAction(UIAlertAction(title: "Create New", style: .default) { _ in
                self.navigationController?.popViewController(animated: true)
        })
        
        alertController.addAction(UIAlertAction(title: "No Thanks", style: .cancel ) { _ in
            alertController.dismiss(animated: true, completion: { () -> Void in
                //
            })
        })
        
        
        present(alertController, animated: true, completion: nil)

        
        
    }

    @objc func foto_save(){
        NotificationCenter.default.removeObserver(self)
        
        
        if ibo_vcColorSelect != nil {
            return
        }
        
        edit_stickerDone()
        setBorderOFF()
        iba_dismissEdit()

        renderImage { (image:UIImage) -> () in
            

            //AssetManager().saveLocalImage(image)
            if self.ibo_shareVC == nil {
                self.ibo_shareVC = self.storyboard?.instantiateViewController(withIdentifier: "sb_CWSharePopUpViewController") as! CWSharePopUpViewController
            }
            self.ibo_shareVC.userImage = UIImage(data: UIImagePNGRepresentation(image)!)
            self.ibo_shareVC.vcparent = self
            self.ibo_shareVC.view.frame = self.view.frame
            self.view.addSubview(self.ibo_shareVC.view)
            
            
    
        }

    }
    
    
        
        
    @objc func renderImage(_ callback: @escaping (UIImage) -> ()) {
      
        let delayTime = DispatchTime.now() + Double(Int64(0.2 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: delayTime) {
            
            UIGraphicsBeginImageContextWithOptions(self.ibo_canvas.view.frame.size, false, 0.0)
            self.ibo_canvas.view.layer.render(in: UIGraphicsGetCurrentContext()!)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            callback(image!)
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        print("This Segue \(segue.identifier)")
        
        if segue.identifier == "sb_CanvasViewController"{
            ibo_canvas = segue.destination as! CanvasViewController
        }
        
        if segue.identifier == "sb_CanvasToolContViewController" {
            
            ibo_container = segue.destination as! CanvasToolContViewController
            
            
            ibo_toolBar = storyboard?.instantiateViewController(withIdentifier: "sb_CWToolBarViewController") as! CWToolBarViewController
            ibo_container.view.addSubview(ibo_toolBar.view)
            
            ibo_toolBar.view.frame = CGRect(x: 0, y: 0, width: ibo_container.view.frame.width, height: ibo_container.view.frame.height)
            ibo_toolBar.delegate = self

        }
        
    }
    

    @IBAction func iba_importWeb(){
        
       
    
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "sb_CFInterWebsViewController") as! CFInterWebsViewController
        let nav = UINavigationController(rootViewController: vc)
        vc.delegate = self
        self.present(nav, animated: true, completion: nil)
    }
    
    /*
    TOOL EDITOR
    */
    
    @objc func foto_import(){
        
        boolBackgroundImage = false
        
        let alertController = UIAlertController(
            title: "Choose Image",
            message: nil,
            preferredStyle: .actionSheet
        )
        
        let imagePicker = UIImagePickerController()
        
        imagePicker.allowsEditing = false
        imagePicker.delegate = self
        
        alertController.addAction(UIAlertAction(title: "Camera", style: .default) { _ in
            imagePicker.sourceType = .camera
            self.present(imagePicker, animated: true, completion: nil)
            })
        
        alertController.addAction(UIAlertAction(title: "Photo Library", style: .default) { _ in
            imagePicker.sourceType = .photoLibrary
            self.present(imagePicker, animated: true, completion: nil)
            })
        
        alertController.addAction(UIAlertAction(title: "Never Mind", style: .cancel) { _ in
            alertController.dismiss(animated: true, completion: { () -> Void in
                //
            })
            })
//        
//        if let popoverController = alertController.popoverPresentationController {
//            popoverController.sourceView = sender
//            popoverController.sourceRect = sender.bounds
//        }
        
        
        present(alertController, animated: true) { () -> Void in
            //
        }
        
    }
    
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        dismiss(animated: true, completion: { () -> Void in
            
            
            
            
                print("Dismiss")
                if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
                    
                    if self.boolBackgroundImage == false {
                        
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "sb_CutOutPainter") as! CutOutPainter
                        vc.delegate = self
                        vc.paintedImage = pickedImage
                        self.present(vc, animated: true, completion: nil)
                        
                    } else {
                        
                        self.ibo_canvas.iba_userImage.image = pickedImage
                        
                    }
                    
                    
                    
                    
                }
            
            
        })
        
        
    }
    
    @objc func cutOutDidFinish(_ img:UIImage, vc:CutOutPainter){
        
        if currentSticker != nil {
            currentSticker.image = img
            vc.dismiss(animated: true, completion: nil)

            return
        }
        
        self.stickerDidFinishChoosing(img)
        vc.dismiss(animated: true, completion: nil)
    
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController){
        
        dismiss(animated: true, completion: nil)
        
    }
    

    @objc func letUserCreateSticker(_ img:UIImage!){
        
        self.stickerDidFinishChoosing(img)
        return
        
    }
    
   
    
    
    @objc func tool_clearAll(){
        ibo_canvas.view.backgroundColor = UIColor.clear
        
        for v in ibo_canvas.ibo_stickerStage.subviews {
            v.removeFromSuperview()
        }
        
        ibo_drawingView.clearBitmap()
        ibo_emojiPaintView.clearView()
        
    }

    @objc func tool_background(){
        
        showColorSelector()
        return
    }
    
    @objc func tool_backgroundPhoto(){
        
        boolBackgroundImage = true
        
        let alertController = UIAlertController(
            title: "Background Image",
            message: nil,
            preferredStyle: .actionSheet
        )
        
        let imagePicker = UIImagePickerController()
        
        imagePicker.allowsEditing = false
        imagePicker.delegate = self
        
        alertController.addAction(UIAlertAction(title: "Camera", style: .default) { _ in
            imagePicker.sourceType = .camera
            self.present(imagePicker, animated: true, completion: nil)
            })
        
        alertController.addAction(UIAlertAction(title: "Photo Library", style: .default) { _ in
            imagePicker.sourceType = .photoLibrary
            self.present(imagePicker, animated: true, completion: nil)
            })
        
        if self.ibo_canvas.iba_userImage.image != nil {
            alertController.addAction(UIAlertAction(title: "Clear Image", style: .default) { _ in
                imagePicker.sourceType = .photoLibrary
                    self.ibo_canvas.iba_userImage.image = nil
                })
        }
        
        alertController.addAction(UIAlertAction(title: "Never Mind", style: .cancel) { _ in
            alertController.dismiss(animated: true, completion: { () -> Void in
                //
            })
            })
        
        
        present(alertController, animated: true) { () -> Void in
            //
        }
        
        
        
    }
    
    /*
    STICKER SELECT EDIT
    */
    @objc func tool_stickerSelect(){
        
        let stickerBored = UIStoryboard(name: "StickerSelectStoryboard", bundle: nil)
        
        let stickerNC = stickerBored.instantiateInitialViewController() as! UINavigationController
        
        let viewStickers = stickerBored.instantiateViewController(withIdentifier: "sb_StickerSectionViewController") as! StickerSectionViewController
        viewStickers.delegate = self
        viewStickers.title = "Stickers"
        let stickerdir = [
            "/stickers/com.99centbrains.cybrfm.free00/",
            "/stickers/com.99centbrains.cybrfm.free01/",
            "/stickers/com.99centbrains.weouthere/",
            "/stickers/com.99centbrains.stickervibe/",
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
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "sb_CFInterWebsViewController") as! CFInterWebsViewController
        
        vc.delegate = self
        let tabbar_tumblr = UITabBarItem(title: "Tumblr", image: UIImage(named:"ui_tabbar_web"), tag: 3)
        vc.tabBarItem = tabbar_tumblr
        vc.title = vc.tabBarItem.title
        
        let webNav = UINavigationController(rootViewController: vc)
        
        ////////
        let tabbar = UITabBarController()
        tabbar.setViewControllers([stickerNC, webNav], animated: true)
                tabbar.tabBar.tintColor = UIColor.darkGray
        tabbar.tabBar.barTintColor = UIColor.white
        
        present(tabbar, animated: true) { () -> Void in
 
        }
 
    }
    
    func stickerDidFinishChoosing(_ img:UIImage){
        
        print("dif finish")
        self.dismiss(animated: true) { () -> Void in }
        
        
        if ibo_emojiPainter != nil {
            self.ibo_emojiPaintView.image = img
            ibo_emojiPainter.ibo_buttonPicker.setImage(img, for: UIControlState())
            return
        }
        
        //DocumentManager().saveImage(img, directory: kAlbum.kStickers)
        
        
        if currentSticker != nil {
            setBorderOFF()
            currentSticker = nil
        }
        
        let stickerImage = img.trimmingTransparentPixels()

        
        var imageSize:CGSize
        if stickerImage?.size.width < stickerImage?.size.height {
            
            imageSize = CGSize(width: (stickerImage?.size.width)!/(stickerImage?.size.height)! * 300, height: 300)
            
        } else {
            
            imageSize = CGSize(width: 300, height: (stickerImage?.size.height)!/(stickerImage?.size.width)! * 300)
            
        }
        
        
        let stickyImage = StickyImageView(frame: CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height))
        stickyImage.stickyKind = StickyImageType.image
        stickyImage.image = stickerImage
        stickyImage.center = ibo_canvas.ibo_stickerStage.center
        stickyImage.clipsToBounds = true
        stickyImage.contentMode = UIViewContentMode.scaleAspectFit
        
        currentSticker = stickyImage
        stickyImage.tag = ibo_canvas.ibo_stickerStage.subviews.count + 1
        ibo_canvas.ibo_stickerStage.addSubview(currentSticker)
        
        setBorderON()
    }
    
    @objc func changeCurrentSticker(_ notification: Notification){
        
        setBorderOFF()
        if let tappedObject = notification.object as? StickyImageView {
            currentSticker = tappedObject
            print(tappedObject.tag)
        }
        setBorderON()
        
    }
    
    @objc func setBorderON(){
    
        currentSticker.layer.borderColor = UIColor.magenta.cgColor
        currentSticker.layer.borderWidth = 2
        currentSticker.layer.backgroundColor = UIColor(white: 1.0, alpha: 0.5).cgColor
        
        if ibo_editBar == nil {
            
            ibo_editBar = storyboard?.instantiateViewController(withIdentifier: "sb_CWStickerEditViewController") as! CWStickerEditViewController
            ibo_container.view.addSubview(ibo_editBar.view)
            ibo_canvas.ibo_stickerStage.isUserInteractionEnabled = true
            ibo_editBar.view.frame = CGRect(x: 0, y: 0, width: ibo_container.view.frame.size.width, height: ibo_container.view.frame.size.height)
            ibo_editBar.delegate = self
            
        }
        
    }
    
    @objc func setBorderOFF(){
        
        if  currentSticker != nil {
            currentSticker.layer.borderColor = nil
            currentSticker.layer.borderWidth = 0
            currentSticker.layer.backgroundColor = nil
            
            currentSticker = nil
        }
    }
    
    @objc func createGestures() {
        
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
        
        ibo_canvas.view.isUserInteractionEnabled = true
        
    }
    
    @objc func removeGestures(){
        
        self.view.removeGestureRecognizer(panGesture)
        self.view.removeGestureRecognizer(pinchGesture)
        self.view.removeGestureRecognizer(rotateGesture)
        self.view.removeGestureRecognizer(longTapGesture)
    
    }
    
    //MARK: - Gesture Handlers
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    @objc var lastPinchScale: CGFloat = 1.0
    @objc var currentlyScaling = false
    
    @objc func stickyPinch(_ recognizer: UIPinchGestureRecognizer) {
        if let sticker = currentSticker {
            if recognizer.state == .ended {
                currentlyScaling = false
                lastPinchScale = 1.0
                return
            }
            
            
            currentlyScaling = true
            
            let newScale = 1.0 - (lastPinchScale - recognizer.scale)
            
            let currentTransform:CGAffineTransform = currentSticker.transform
            let newTransform = currentTransform.scaledBy(x: newScale, y: newScale)
            
            sticker.transform = newTransform
            
            lastPinchScale = recognizer.scale

        }
    
    }
    
    @objc var currentlyRotating:Bool = false
    @objc var lastRotation: CGFloat = 0
    @objc func stickyRotate(_ recognizer: UIRotationGestureRecognizer) {
        if let sticker = currentSticker {
            
            
            if recognizer.state == .ended {
                
                currentlyRotating = false
                lastRotation = 0.0
                return
            }
            
            currentlyRotating = true
            
            let newRotation = 0.0 - (lastRotation - recognizer.rotation)
            
            let currentTransform:CGAffineTransform = currentSticker.transform
            let newTransform = currentTransform.rotated(by: newRotation)
            
            sticker.transform = newTransform
            lastRotation = recognizer.rotation
            
            }
    }
    
    @objc var lastMoveCenter = CGPoint(x: 0, y: 0)
    @objc func stickyMove(_ recognizer: UIPanGestureRecognizer) {
        
        if let sticker = currentSticker {
            
            ibo_canvas.ibo_stickerStage.bringSubview(toFront: sticker)
            
            var newCenter = recognizer.translation(in: self.view)

            if recognizer.state == .began {
                
                lastMoveCenter = CGPoint(x: currentSticker.center.x, y: currentSticker.center.y)
            
            }
            
            newCenter = CGPoint(x: lastMoveCenter.x + newCenter.x, y: lastMoveCenter.y + newCenter.y)
            sticker.center = newCenter

        }
    }
    
    @objc func stickyLongTap(_ recognizer: UIPanGestureRecognizer) {
       //return
        
        if let sticker = currentSticker {
            sticker.superview?.bringSubview(toFront: sticker)
        }
        
    }



    /*
    FONT TOOL
    */
    @objc func tool_fontTyper(){
        
        if newLabel != nil {
            return
        }
        
        setBorderOFF()
        
        newLabel = UITextView(frame: CGRect(x: 0, y: 64, width: ibo_canvas.view.frame.size.width, height: ibo_canvas.view.frame.size.width/3 * 2))
        newLabel.backgroundColor = UIColor.clear
        newLabel.text = "Type to Edit"
        newLabel.font = UIFont(name: "ArialRoundedMTBold", size: 64)
        newLabel.textAlignment = .center
        newLabel.clearsOnInsertion = true
        newLabel.autocorrectionType = .no
        newLabel.delegate = self
        newLabel.becomeFirstResponder()

        newLabel.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
        
        self.view.addSubview(newLabel)
        
        ibo_canvas.view.alpha = 0.20
        

    }
    
    @objc func keyboardWillShow(_ sender: Notification) {
        
        print("Keybaord Up")
        
        if let userInfo = sender.userInfo {
            if let keyboardSize = (userInfo[UIKeyboardFrameBeginUserInfoKey] as AnyObject).cgRectValue {
    
                if ibo_tool_fontEdit == nil {
                    ibo_tool_fontEdit = storyboard?.instantiateViewController(withIdentifier: "seg_FontToolViewController") as! FontToolViewController
                    ibo_tool_fontEdit.delegate = self
                    let height = self.view.frame.size.height - keyboardSize.size.height - 50
                    ibo_tool_fontEdit.view.frame = CGRect(x: 0, y: height, width: self.view.frame.size.width, height: 50)
                    self.view.addSubview(ibo_tool_fontEdit.view)
                }
                
            }
        }
    }
    @objc func font_done(){
        self.iba_dismissEdit()
    }
    
    @objc func iba_dismissEdit() {
        
        if ibo_tool_fontEdit != nil {
            
            ibo_canvas.view.alpha = 1.0
            
            ibo_tool_fontEdit.view.removeFromSuperview()
            ibo_tool_fontEdit.delegate = nil
            ibo_tool_fontEdit = nil
            
            newLabel.resignFirstResponder()
            
            newLabel.backgroundColor = UIColor.clear
            newLabel.frame = CGRect(x: 0, y: 0, width: newLabel.contentSize.width, height: newLabel.contentSize.height)
            
            
            UIGraphicsBeginImageContextWithOptions(newLabel.textInputView.frame.size, false, 4)
            newLabel.layer.render(in: UIGraphicsGetCurrentContext()!)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            self.textTyperDidFinishPicking(image!)
            
            //Clean Up
            newLabel.removeFromSuperview()
            newLabel.delegate = nil
            newLabel.isUserInteractionEnabled = false
            newLabel = nil
            
            
            
            setUpNavbar()
        }

    }
    
    @objc func font_changeColor(){
        
        newLabel.resignFirstResponder()
        showColorSelector()
    
    }
    
    @objc func font_toggleAlignment(){
        
        let currentAlign:NSTextAlignment = newLabel.textAlignment
        
        switch currentAlign {
            
        case NSTextAlignment.left:
            newLabel.textAlignment = NSTextAlignment.right
            
        case NSTextAlignment.center:
            newLabel.textAlignment = NSTextAlignment.left
            
        case NSTextAlignment.right:
            newLabel.textAlignment = NSTextAlignment.center
            //
        
        default: break
           //
        }
    
    }
    
    @objc func font_sizeUp(){
        
        newLabel.font = UIFont(name: newLabel.font!.fontName, size: newLabel.font!.pointSize + 10)
    
    }
    @objc func font_sizeDown(){
        
        newLabel.font = UIFont(name: newLabel.font!.fontName, size: newLabel.font!.pointSize - 10)
    
    }
    @objc func font_chooseFont(_ font:UIFont){
        
        newLabel.font = UIFont(name: font.fontName, size: newLabel.font!.pointSize)

    }
    
    @objc func font_changeSaying(_ string:String){
        newLabel.text = string
    }
    
    @objc func textTyperDidFinishPicking(_ img:UIImage){
       
        
        if ibo_vcColorSelect != nil {
            return
        }
        
        if currentSticker != nil {
            setBorderOFF()
            currentSticker = nil
        }
        
        let textImage = img.trimmingTransparentPixels()
        
        var imageSize:CGSize
        if textImage?.size.width < textImage?.size.height {
            
            imageSize = CGSize(width: (textImage?.size.width)!/(textImage?.size.height)! * 300, height: 300)
        
        } else {
            
            imageSize = CGSize(width: 300, height: (textImage?.size.height)!/(textImage?.size.width)! * 300)
            
        }
        
        let stickyImage = StickyImageView(frame: CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height))
        stickyImage.stickyKind = StickyImageType.text
        stickyImage.image = textImage
        stickyImage.center = ibo_canvas.ibo_stickerStage.center
        stickyImage.clipsToBounds = true
        stickyImage.contentMode = UIViewContentMode.scaleAspectFit

        stickyImage.layer.shadowColor = UIColor.cyan.cgColor
        stickyImage.layer.shadowRadius = 0
        stickyImage.layer.shadowOffset = CGSize(width: 3, height: 3)
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
    
    @objc func tool_paintSelect(){
        
        ibo_toolPainter = storyboard?.instantiateViewController(withIdentifier: "seg_PaintToolViewController") as! PaintToolViewController
        ibo_container.view.addSubview(ibo_toolPainter.view)
        ibo_canvas.ibo_stickerStage.isUserInteractionEnabled = false
        ibo_drawingView.isUserInteractionEnabled = true
        ibo_toolPainter.view.frame = CGRect(x: 0, y: 0, width: ibo_container.view.frame.size.width, height: ibo_container.view.frame.size.height)
        ibo_toolPainter.delegate = self

        removeGestures()
        
    
    }
    
    @objc func tool_paintMoji(){
               
        ibo_emojiPainter = storyboard?.instantiateViewController(withIdentifier: "seg_EmojiToolViewController") as! PaintToolViewController
        ibo_container.view.addSubview(ibo_emojiPainter.view)
        ibo_canvas.ibo_stickerStage.isUserInteractionEnabled = false
        ibo_emojiPaintView.isUserInteractionEnabled = true
        ibo_emojiPainter.view.frame = CGRect(x: 0, y: 0, width: ibo_container.view.frame.size.width, height: ibo_container.view.frame.size.height)
        ibo_emojiPainter.delegate = self
        
        ibo_emojiPainter.ibo_buttonPicker.setImage(ibo_emojiPaintView.image, for: UIControlState())
        
        removeGestures()
    
    }
    
    func paintSelectImage() {
        print("paint Select Image")
        
       tool_stickerSelect ()
        
    }
    
    @objc var paintSize:CGFloat = 25.0
    
    @objc func paintSizeAnimate(_ size:CGFloat, isPainter:Bool){
        
        print("paintSizeAnimate")
        
        let sampleView = UIImageView(frame: CGRect(x: 0, y: 0, width: size, height: size))
        sampleView.center = ibo_canvas.view.center
        
        if isPainter {
            
            sampleView.backgroundColor = ibo_drawingView.lineColor
            sampleView.layer.cornerRadius = size/2
            sampleView.layer.borderColor = UIColor.black.cgColor
            sampleView.layer.borderWidth = 2.0
            
        } else {
            
            sampleView.image = ibo_emojiPaintView.image
            
        }
        
        
        ibo_canvas.view.addSubview(sampleView)
        
        
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseOut, animations: {
           
            sampleView.alpha = 0
        
            }, completion: { finished in

                sampleView.removeFromSuperview()
                
            })
        
        paint_setSize(size)
    
    }
    
    
    
    @objc func setupPainter(){
        
        ibo_drawingView = SwiftDrawView(frame: CGRect(x: 0, y: 0, width: ibo_canvas.view.frame.width, height: ibo_canvas.view.frame.height))
        ibo_canvas.view.insertSubview(ibo_drawingView, belowSubview: ibo_canvas.ibo_stickerStage)
        ibo_drawingView.lineWidth = paintSize
        ibo_drawingView.isUserInteractionEnabled = false
        
//        ibo_drawingView.layer.shadowColor = UIColor.cyanColor().CGColor
//        ibo_drawingView.layer.shadowOffset = CGSizeMake(0, 0)
//        ibo_drawingView.layer.shadowRadius = 10
//        ibo_drawingView.layer.shadowOpacity = 1.0
        
        ibo_emojiPaintView = EmojiDrawView(frame: CGRect(x: 0, y: 0, width: ibo_canvas.view.frame.width, height: ibo_canvas.view.frame.height))
        ibo_canvas.view.insertSubview(ibo_emojiPaintView, belowSubview: ibo_canvas.ibo_stickerStage)
        ibo_emojiPaintView.brushSize = paintSize
        ibo_emojiPaintView.isUserInteractionEnabled = false
        
        print(ibo_canvas.view.frame)
        print(ibo_drawingView.frame)
        
    }
    
    func paint_setSizeUP(_ isPaint:Bool){
        
        var currentsize = ibo_emojiPaintView.brushSize
        
        if currentsize > 150 {
            currentsize = 0
        }
        
        currentsize = currentsize! + 25.0
        
        paintSizeAnimate(currentsize!, isPainter: isPaint)
    
    }
    func paint_setSizeDown(_ isPaint:Bool){
        
        var currentsize = ibo_emojiPaintView.brushSize
        currentsize = currentsize! - 25.0
        
        if currentsize <= 0 {
            currentsize = 25
        }
        
        paintSizeAnimate(currentsize!, isPainter: isPaint)
    
    }
    
    @objc func paint_setSize(_ size:CGFloat){
        
        ibo_emojiPaintView.brushSize = size
        ibo_drawingView.lineWidth = size

    }
    
    func paint_toggleEraser(_ state:Bool){
        
        if ibo_drawingView.eraserMode {
            ibo_drawingView.eraserMode = false
        } else {
            ibo_drawingView.eraserMode = true
        }
        
    }
    
    func paintSelectColor(){
       showColorSelector()
    }
    
    func paint_setImage(_ img:UIImage){
        
        
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
        
        ibo_drawingView.isUserInteractionEnabled = false
        ibo_emojiPaintView.isUserInteractionEnabled = false
        ibo_canvas.ibo_stickerStage.isUserInteractionEnabled = true
        
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
    
    @objc func edit_stickerDone() {
        
        setBorderOFF()
        
        if ibo_editBar != nil {
        
            ibo_editBar.delegate = nil
            ibo_editBar.view.removeFromSuperview()
            ibo_editBar = nil
            
        }
        
        
    }
    
    @objc func edit_stickerTrash(){
        
        currentSticker.removeFromSuperview()
        setBorderOFF()
        
        ibo_editBar.delegate = nil
        ibo_editBar.view.removeFromSuperview()
        ibo_editBar = nil
    
    }
    @objc func edit_flip(){
        
        currentSticker.flipSticker()
    
    }
    @objc func edit_copy(){
        let oldSticker = currentSticker
        let stickerPoint = oldSticker?.center//OLD CENTER
        
        stickerDidFinishChoosing(currentSticker.image!)
        
        currentSticker.center = CGPoint(x: (stickerPoint?.x)! + 10, y: (stickerPoint?.y)! + 10)
        currentSticker.transform = (oldSticker?.transform)!
        
    
    }
    @objc func edit_layerUp(){
        
        if let stickerViews = ibo_canvas.ibo_stickerStage.subviews as? [StickyImageView] {
            
            //swift 2.0 change this ~ let indexOfA = arr.indexOf("a") // 0
            let stickerIndex = stickerViews.index(of: currentSticker)
            ibo_canvas.ibo_stickerStage.exchangeSubview(at: stickerIndex!, withSubviewAt: stickerIndex! + 1)
            
        }
        
    
    }
    @objc func edit_layerDown(){
        
        if let stickerViews = ibo_canvas.ibo_stickerStage.subviews as? [StickyImageView] {
  
            //swift 2.0 change this ~ let indexOfA = arr.indexOf("a") // 0
            let stickerIndex = stickerViews.index(of: currentSticker)
            ibo_canvas.ibo_stickerStage.exchangeSubview(at: stickerIndex!, withSubviewAt: stickerIndex! - 1)
        
        }

    }
    

    
    @objc func edit_reflect(){
        
        var oldSticker = currentSticker
        let stickerPoint = oldSticker?.center//OLD CENTER
        
        //GET OLD ROTATION to DEGREE FROM RADIAN
        let zKeyPath = "layer.presentationLayer.transform.rotation.z"
        let imageRotation = (oldSticker?.value(forKeyPath: zKeyPath) as? NSNumber)?.floatValue ?? 0.0
        let degreesRotated = radiansToDegrees(Double(imageRotation))

        //MAKE NEW STICKER
        stickerDidFinishChoosing((oldSticker?.image!)!)
        
        // COPY TO OPOSITE X
        let newXPoint = ibo_canvas.ibo_stickerStage.frame.size.width - (stickerPoint?.x)!
        currentSticker.center = CGPoint(x: newXPoint, y: (stickerPoint?.y)!)
        currentSticker.flipSticker()

        //REVERSE ROTATION
        var newRotation:CGFloat!
        if currentSticker.frame.origin.x <= ibo_canvas.ibo_stickerStage.frame.size.width {
            newRotation = degreesRotated * -2.0
        } else {
           newRotation = degreesRotated * 2.0
        }
        
        //APPLY TRANSFORMS
        currentSticker.transform = (oldSticker?.transform.scaledBy(x: 1, y: 1))!
        currentSticker.transform = currentSticker.transform.rotated(by: degreesToRadians(newRotation))
        
        oldSticker = nil
        

    }
    
    @objc func edit_editImage() {
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "sb_CutOutPainter") as! CutOutPainter
        vc.delegate = self
        vc.paintedImage = self.currentSticker.image
        self.present(vc, animated: true, completion: nil)
        
        
        
    }
    
    @objc func degreesToRadians (_ val:CGFloat) -> CGFloat {
        let rad = val * CGFloat((M_PI / 180.0))
        return CGFloat(rad)
    }
    
    @objc func radiansToDegrees (_ value:Double) -> CGFloat {
        let rad = value * 180.0 / M_PI
         return CGFloat(rad)
    }
    
    /*
    TOOL EDITOR
    */
    
    
    /*
    COLOR DELEGATES
    */
    
    @objc func showColorSelector(){
        
        ibo_vcColorSelect = CWColorSelectViewController()
        ibo_vcColorSelect = storyboard?.instantiateViewController(withIdentifier: "sb_CWColorSelectViewController") as! CWColorSelectViewController
        ibo_vcColorSelect.delegate = self
        ibo_vcColorSelect.view.frame = self.view.frame
        self.view.addSubview(ibo_vcColorSelect.view)
        
    }
    
    @objc func colorSelectChoseColor(_ color:UIColor){

        if newLabel != nil {
            
            newLabel.textColor = color
            
        } else if ibo_toolPainter != nil {
            
            ibo_drawingView.lineColor = color
            
        } else {
            
            self.ibo_canvas.view.backgroundColor = color
        
        }
        
        colorSelectDismiss()
        
    }
    
    @objc func colorSelectDismiss(){
        
        ibo_vcColorSelect.view.removeFromSuperview()
        ibo_vcColorSelect.delegate = nil
        ibo_vcColorSelect = nil
        
        if newLabel != nil {
            newLabel.becomeFirstResponder()
        }
        
        
    }

    
    override var prefersStatusBarHidden : Bool {
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
