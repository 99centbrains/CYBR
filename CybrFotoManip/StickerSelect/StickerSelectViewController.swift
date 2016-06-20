//
//  StickerSelectViewController.swift
//  Catwang
//
//  Created by Franky Aguilar on 7/20/15.
//  Copyright (c) 2015 99centbrains. All rights reserved.
//

import Foundation
import UIKit
import SwiftInAppPurchase
import PKHUD

@objc protocol StickerSelectDelegate {
    
    optional func stickerDidFinishChoosing(img:UIImage)
    optional func painterDidFinishChoosing(img:UIImage)

}

class StickerSectionViewController:UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, StickerSelectDelegate {
    
    @IBOutlet var ibo_collectionView:UICollectionView!
    
    @IBOutlet weak var ibo_lockBtn:UIButton!
    
    var delegate:StickerSelectDelegate!
    
    var assetArray = [[String]]()
    var assetDIR = [String]()
    var flowLayoutFull = UICollectionViewFlowLayout()
    
    var isLocked = true
    var currentPageID:String!
    var currentPageIndex = 0
    
    @IBOutlet weak var ibo_scrollView: UIScrollView!
    
    
    override func viewDidLoad() {
        
        //print(DocumentManager().getSavedImages())
        
        var productIden = Set(assetDIR)
        productIden.insert("com.99cb.cybrfm.tumblr")
        
        let iap = SwiftInAppPurchase.sharedInstance
        
        iap.requestProducts(productIden) { (products, invalidIdentifiers, error) -> () in
            print(products)
        }
        
       
        
        view.backgroundColor = UIColor(patternImage: UIImage(named: "ui_cropview_checkers")!)
        
        navigationController?.navigationBar.translucent = false
        self.navigationItem.leftBarButtonItem =  UIBarButtonItem(title: "Restore", style: .Plain, target: self, action:#selector(self.iba_restore(_:)))
        
        navigationItem.rightBarButtonItem =  UIBarButtonItem(title: "Done", style: .Plain, target: self, action: #selector(self.iba_done(_:)))
 
    }
    
    override func viewWillLayoutSubviews() {
        
        flowLayoutFull = UICollectionViewFlowLayout()
        flowLayoutFull.sectionInset = UIEdgeInsetsMake(20, 10, 20, 0)
        flowLayoutFull.itemSize = CGSizeMake(self.view.frame.size.width/3 - 20, self.view.frame.size.width/3 - 20)
        flowLayoutFull.scrollDirection = .Vertical
        flowLayoutFull.minimumLineSpacing = 0
        
        
        ibo_collectionView.setCollectionViewLayout(flowLayoutFull, animated: false)
        
        self.ibo_collectionView.setContentOffset(CGPointZero, animated: false)
        
    }
    
    func loadDirectorys(packDIR:[String]){
        
        assetDIR = cleanDir(packDIR)
        print(assetDIR)
        
        for str in packDIR {
            
            let assManager = AssetManager()
            let directory = assManager.getAssetsForDir(str)
                        //print("BLAH ----------------\(str)")
            
            var cake = [String]()
//            
            for sticker in directory {
                
                let stickerFull = assManager.getFullAsset(sticker, dir: str)
                //print(stickerFull)
                cake.append(stickerFull)
            }
            
            assetArray.append(cake)
   
        }
        
       
        
        
    }
    
    func setupTabBar(){
    
        for var i = 0; i < assetArray.count; i += 1 {
            
            print(assetArray[i][0])
            
            let scrollSize = ibo_scrollView.frame.size.height
            let btnSize = CGRectMake(CGFloat(i) * scrollSize, 0, scrollSize, scrollSize)
            let tabBtn = UIButton(frame: btnSize)
            tabBtn.contentEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5)
            tabBtn.addTarget(self, action: #selector(self.iba_toggleTab(_:)), forControlEvents: .TouchUpInside)
            tabBtn.tag = i
            tabBtn.contentScaleFactor = 0.5
            
            if i == 0 {
                tabBtn.backgroundColor = UIColor.whiteColor()
            }
            
            let cellImage = UIImage(contentsOfFile: assetArray[i][0])
            
            tabBtn.setImage(cellImage, forState: .Normal)
            
            self.ibo_scrollView.addSubview(tabBtn)
            
        }
        
        ibo_scrollView.contentSize = CGSizeMake(ibo_scrollView.frame.size.height * CGFloat(assetArray.count), ibo_scrollView.frame.size.height)
//        ibo_scrollView.layer.shadowOffset = CGSizeMake(0, 2)
//        ibo_scrollView.layer.shadowColor = UIColor.blackColor().CGColor
//        ibo_scrollView.layer.shadowOpacity = 0.5
//        ibo_scrollView.layer.shadowRadius = 2
    }
    
    func iba_toggleTab(sender:UIButton){
        
        for btn in ibo_scrollView.subviews{
            
            btn.backgroundColor = UIColor.clearColor()
        }
        
        sender.backgroundColor = UIColor.whiteColor()
        print(assetDIR[sender.tag])
        currentPageIndex = sender.tag
        ibo_collectionView.reloadData()
        
    
    }
    
    func cleanDir(ar:[String]) -> [String]{
        
        var strings = [String]()
        
        for dir in ar {
            var clean = dir.stringByReplacingOccurrencesOfString("/", withString: "")
            clean = clean.stringByReplacingOccurrencesOfString("stickers", withString: "")
            strings.append(clean)
        }
      
        return strings
    
    }
    
    override func viewWillAppear(animated: Bool) {
         ibo_collectionView.reloadData()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.setupTabBar()
    }
    
    @IBAction func iba_restore(sender:UIBarButtonItem){
        
        PKHUD.sharedHUD.contentView = PKHUDProgressView()
        PKHUD.sharedHUD.show()
        
        
        let iap = SwiftInAppPurchase.sharedInstance
        iap.restoreTransaction(nil) { (result) -> () in
            switch result{
            case .Restored(let productId,let transaction,let paymentQueue) :
                
                print(productId)
                NSUserDefaults.standardUserDefaults().setBool(true, forKey: productId)
                PKHUD.sharedHUD.hide()
                self.ibo_collectionView.reloadData()
                self.showAlert("Purchases Restored!")
                paymentQueue.finishTransaction(transaction)
            case .Failed(let error):
                print(error)
                PKHUD.sharedHUD.contentView = PKHUDErrorView()
                PKHUD.sharedHUD.hide()
                
            default:
                break
            }
        }

        
    }
    
    func iba_done(sender: UIBarButtonItem){
        dismissViewControllerAnimated(true, completion: { () -> Void in
        })
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int{
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assetArray[currentPageIndex].count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        
        currentPageID = assetDIR[currentPageIndex]
        if NSUserDefaults.standardUserDefaults().boolForKey(assetDIR[currentPageIndex]) == false {
            isLocked = true
            self.ibo_lockBtn.hidden = false
        } else {
            
            isLocked = false
            self.ibo_lockBtn.hidden = true
            
        }
        
    
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! StickerCollectionCell
        
        cell.ibo_imageViewer.image = nil
        cell.setupImage(assetArray[currentPageIndex][indexPath.item])
        return cell
        

    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {

        if isLocked == true {
            return
        }
        
        
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! StickerCollectionCell
        
        if let cellimage = cell.cellImage as UIImage? {
            
            self.delegate?.stickerDidFinishChoosing!(cellimage as UIImage)
            
        }
        
    }
    


    @IBAction func purchaseITEM(){
        
        PKHUD.sharedHUD.contentView = PKHUDProgressView()
        PKHUD.sharedHUD.show()
        
        print(currentPageID)
        
        let iap = SwiftInAppPurchase.sharedInstance
        iap.addPayment(currentPageID, userIdentifier: nil) { (result) -> () in
            
            switch result{
            case .Purchased(let productId,let transaction,let paymentQueue):
                NSUserDefaults.standardUserDefaults().setBool(true, forKey: productId)
                PKHUD.sharedHUD.hide()
                self.ibo_collectionView.reloadData()
                paymentQueue.finishTransaction(transaction)
            case .Failed(let error):
                print(error)
                PKHUD.sharedHUD.contentView = PKHUDErrorView()
                PKHUD.sharedHUD.show()
                PKHUD.sharedHUD.hide()
            default:
                break
            }            
        }
    
        
        
    }

    func showAlert(message:String){
        
        let alertController = UIAlertController(
            title: "Result",
            message: message,
            preferredStyle: .Alert
        )
        
        
        alertController.addAction(UIAlertAction(title: "Done", style: .Default) { _ in
            alertController.dismissViewControllerAnimated(true, completion: nil)
            })
        
        self.presentViewController(alertController, animated: true) { 
            //
        }
        
        
    }

    
    override func prefersStatusBarHidden() -> Bool {
        return false
    }

}







class StickerCollectionCell : UICollectionViewCell {
    
    @IBOutlet var ibo_imageViewer:UIImageView!
    
    var cellImage:UIImage!
    
    func setupImage(file:String){
        
        cellImage = UIImage(contentsOfFile: file)
        ibo_imageViewer.image = cellImage

       
    
    }
}



//EMOJIS
class StickerCategoryViewController:UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    var delegate:StickerSelectDelegate!
    
    @IBOutlet var ibo_collectionView:UICollectionView!
    var assetArray = [String]()
    
    override func viewDidLoad() {
        
        print("STICKER SELECT")
        super.viewDidLoad()
        
        navigationController?.setNavigationBarHidden(false, animated: false)
        
        title = "Select Sticker"
        navigationItem.rightBarButtonItem =  UIBarButtonItem(title: "Done", style: .Plain, target: self, action: #selector(StickerSectionViewController.iba_done(_:)))
        
        navigationItem.leftBarButtonItem =  UIBarButtonItem(title: "Restore", style: .Plain, target: self, action: #selector(StickerSectionViewController.iba_restore(_:)))
        
        navigationController?.navigationBar.tintColor = UIColor.magentaColor()
        navigationController?.navigationBar.backgroundColor = UIColor.yellowColor()
        self.title = "Stickers"
        
        let assManager = AssetManager()
        let path = "/stickers/emoji/"
        let sticker = assManager.getAssetsForDir(path)
        for s in sticker {
            
            assetArray += [assManager.getFullAsset(s, dir: path)]
        }
        
        ibo_collectionView.reloadData()
        //print(assetArray.count)
        
    }
    
    override func viewWillLayoutSubviews() {
        let flowLayoutFull = UICollectionViewFlowLayout()
        flowLayoutFull.sectionInset = UIEdgeInsetsMake(5, 0, 5, 0)
        flowLayoutFull.itemSize = CGSizeMake(self.view.frame.size.height/4, self.view.frame.size.height/4)
        flowLayoutFull.minimumInteritemSpacing = 0
        flowLayoutFull.minimumLineSpacing = 0
        flowLayoutFull.scrollDirection = .Horizontal
        ibo_collectionView.setCollectionViewLayout(flowLayoutFull, animated: false)
    }
    
    func iba_restore(sender: UIBarButtonItem){
  
    }
    
    func iba_done(sender: UIBarButtonItem){
        dismissViewControllerAnimated(true, completion: { () -> Void in
            //
        })
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int{
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assetArray.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        //print("cell")
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! StickerCollectionCell
        
        
        //println(imageData)
        cell.ibo_imageViewer.image = nil
        cell.setupImage(assetArray[indexPath.item])
        
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        //
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! StickerCollectionCell
        
        if let cellimage = cell.cellImage as UIImage? {
            
            self.delegate.stickerDidFinishChoosing?(cellimage as UIImage)
            
            dismissViewControllerAnimated(true, completion: { () -> Void in
                
            })
            
        }
    }
    
    
    
}
