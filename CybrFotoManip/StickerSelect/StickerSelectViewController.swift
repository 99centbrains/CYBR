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
    
    var assetArray = [[[String]]]()
    var assetDIR = [String]()
    var flowLayoutFull = UICollectionViewFlowLayout()
    
    var lockedPage = true
    var currentPageID:String!
    
    @IBOutlet var ibo_iboPageControl:UIPageControl!
    
    var currentPage:Int!
    
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
        
        flowLayoutFull.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0)
        flowLayoutFull.itemSize = ibo_collectionView.frame.size
        flowLayoutFull.minimumLineSpacing = 0
        flowLayoutFull.scrollDirection = .Horizontal
        
        ibo_collectionView.setCollectionViewLayout(flowLayoutFull, animated: false)
    }
    
    func loadDirectorys(packDIR:[String]){
        
        assetDIR = cleanDir(packDIR)
        print(assetDIR)
        
        for str in packDIR {
            
            let assManager = AssetManager()
            let directory = assManager.getAssetsForDir(str)
            //print("BLAH ----------------\(str)")
            
            var cake = [String]()
            
            for section in directory {
                
                let stickerFull = assManager.getFullAsset(section, dir: str)
                //print(stickerFull)
                cake.append(stickerFull)
                
            }
            
            assetArray.append([cake])
            
        }
        
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
        
        ibo_iboPageControl.numberOfPages = assetArray.count
        
//        currentPage =  NSUserDefaults.standardUserDefaults().integerForKey("lastPage")
//        
//        let indexPath = NSIndexPath(forItem: currentPage, inSection: 1)
//        ibo_collectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: .Left, animated: false)
//        
        
        
            ibo_collectionView.reloadData()
        
        
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
        
       
        
//        SwiftyStoreKit.restorePurchases() { result in
//            
//            if result.restoreFailedProducts.count > 0 {
//
//            }
//            else if result.restoredProductIds.count > 0 {
//                print("Restore Success: \(result.restoredProductIds)")

//            }
//            else {
//                print("Nothing to Restore")
//                self.showAlert("Nothing to Restore")
//                PKHUD.sharedHUD.hide()
//            }
//            
//            
//        }
        
    }
    
    func iba_done(sender: UIBarButtonItem){
        dismissViewControllerAnimated(true, completion: { () -> Void in
        })
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int{
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assetArray.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        ibo_iboPageControl.currentPage = indexPath.item
        
        currentPageID = assetDIR[indexPath.item]
        if NSUserDefaults.standardUserDefaults().boolForKey(assetDIR[indexPath.item]) == false {
            lockedPage = true
            self.ibo_lockBtn.hidden = false
        } else {
            
            lockedPage = false
            self.ibo_lockBtn.hidden = true
            
        }
        
        NSUserDefaults.standardUserDefaults().setInteger(indexPath.item, forKey: "lastPage")
    
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("page", forIndexPath: indexPath) as! StickerPageCollectionView
        
        cell.delegate = self.delegate
        cell.isLocked = lockedPage
        cell.setupDir(self.assetArray[indexPath.item], rect: self.ibo_collectionView.frame.size)
        
        return cell

    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {

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

class StickerPageCollectionView: UICollectionViewCell, UICollectionViewDataSource, UICollectionViewDelegate{
    
    var assetPage = [[String]]()
    
    @IBOutlet var ibo_collectionView:UICollectionView!
    var delegate:StickerSelectDelegate?
    var isLocked:Bool = true
    
    func setupDir(pack:[[String]], rect:CGSize ){
        
        print(rect)
        
        let flowLayoutFull = UICollectionViewFlowLayout()
        flowLayoutFull.sectionInset = UIEdgeInsetsMake(20, 10, 20, 0)
        flowLayoutFull.itemSize = CGSizeMake(rect.width/3 - 20, rect.width/3 - 20)
        flowLayoutFull.scrollDirection = .Vertical
        flowLayoutFull.minimumLineSpacing = 0
        
        ibo_collectionView.setCollectionViewLayout(flowLayoutFull, animated: false)

        self.assetPage = pack
        self.ibo_collectionView.setContentOffset(CGPointZero, animated: false)
        
        self.ibo_collectionView.reloadData()
        
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int{
        return assetPage.count
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assetPage[section].count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
      
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! StickerCollectionCell
        
        cell.ibo_imageViewer.image = nil
        cell.setupImage(assetPage[indexPath.section][indexPath.item])
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


    
    
  

}


import iAd

class CollectionFooter :UICollectionReusableView , ADBannerViewDelegate{
    
    @IBOutlet var adBanner:ADBannerView?
    
    func setupCell(){
        
            print("cell")
            self.backgroundColor = UIColor.yellowColor()
            
            if adBanner?.bannerLoaded != nil {
                adBanner?.hidden = false
            } else {
                adBanner?.hidden = true
                print("didnt load")
            }
 
    }
    
    func bannerView(banner: ADBannerView!, didFailToReceiveAdWithError error: NSError!){
        
        print("FAILED")
        adBanner?.hidden = true
        adBanner?.removeFromSuperview()
    }
    
    func bannerViewDidLoadAd(banner: ADBannerView!) {
        
        adBanner?.hidden = false
        
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
        navigationItem.rightBarButtonItem =  UIBarButtonItem(title: "Done", style: .Plain, target: self, action: "iba_done:")
        
        navigationItem.leftBarButtonItem =  UIBarButtonItem(title: "Restore", style: .Plain, target: self, action: "iba_restore:")
        
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
