//
//  StickerSelectViewController.swift
//  Catwang
//
//  Created by Franky Aguilar on 7/20/15.
//  Copyright (c) 2015 99centbrains. All rights reserved.
//

import Foundation
import UIKit
import PKHUD

@objc protocol StickerSelectDelegate {
    
    @objc optional func stickerDidFinishChoosing(_ img:UIImage)
    @objc optional func painterDidFinishChoosing(_ img:UIImage)

}

class StickerSectionViewController:UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, StickerSelectDelegate {
    
    @IBOutlet var ibo_collectionView:UICollectionView!
    
    @IBOutlet weak var ibo_lockBtn:UIButton!
    
    @objc var delegate:StickerSelectDelegate!
    
    @objc var assetArray = [[String]]()
    @objc var assetDIR = [String]()
    @objc var flowLayoutFull = UICollectionViewFlowLayout()
    
    @objc var isLocked = true
    @objc var currentPageID:String!
    @objc var currentPageIndex = 0
    
    @IBOutlet weak var ibo_scrollView: UIScrollView!
    
    
    override func viewDidLoad() {
        
        //print(DocumentManager().getSavedImages())
        
        var productIden = Set(assetDIR)
        productIden.insert("com.99cb.cybrfm.tumblr")

        //TODO: in app purchase needs to be fixed
//        let iap = SwiftInAppPurchase.sharedInstance

//        iap.requestProducts(productIden) { (products, invalidIdentifiers, error) -> () in
//            print(products)
//        }
//

        
        view.backgroundColor = UIColor(patternImage: UIImage(named: "ui_cropview_checkers")!)
        
        navigationController?.navigationBar.isTranslucent = false
        self.navigationItem.leftBarButtonItem =  UIBarButtonItem(title: "Restore", style: .plain, target: self, action:#selector(self.iba_restore(_:)))
        
        navigationItem.rightBarButtonItem =  UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(self.iba_done(_:)))
 
    }
    
    override func viewWillLayoutSubviews() {
        
        flowLayoutFull = UICollectionViewFlowLayout()
        flowLayoutFull.sectionInset = UIEdgeInsetsMake(20, 10, 20, 0)
        flowLayoutFull.itemSize = CGSize(width: self.view.frame.size.width/3 - 20, height: self.view.frame.size.width/3 - 20)
        flowLayoutFull.scrollDirection = .vertical
        flowLayoutFull.minimumLineSpacing = 0
        
        
        ibo_collectionView.setCollectionViewLayout(flowLayoutFull, animated: false)
        
        self.ibo_collectionView.setContentOffset(CGPoint.zero, animated: false)
        
    }
    
    @objc func loadDirectorys(_ packDIR:[String]){
        
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
    
    @objc func setupTabBar(){
        
        if self.ibo_scrollView.subviews.count > 0  {
            return
        }
         self.ibo_scrollView.alpha = 0
    
        for i in 0 ..< assetArray.count {
            
            print(assetArray[i][0])
            
            let scrollSize = ibo_scrollView.frame.size.height
            let btnSize = CGRect(x: CGFloat(i) * scrollSize, y: 0, width: scrollSize, height: scrollSize)
            let tabBtn = UIButton(frame: btnSize)
            tabBtn.contentEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5)
            tabBtn.contentMode = .scaleAspectFit
            tabBtn.addTarget(self, action: #selector(self.iba_toggleTab(_:)), for: .touchUpInside)
            tabBtn.tag = i
            tabBtn.contentScaleFactor = 0.5
            
            if i == 0 {
                tabBtn.backgroundColor = UIColor.white
            }
            
            let cellImage = UIImage(contentsOfFile: assetArray[i][0])
            
            tabBtn.setImage(cellImage, for: UIControlState())
            
            self.ibo_scrollView.addSubview(tabBtn)
            
        }
        
        ibo_scrollView.contentSize = CGSize(width: ibo_scrollView.frame.size.height * CGFloat(assetArray.count), height: ibo_scrollView.frame.size.height)
//        ibo_scrollView.layer.shadowOffset = CGSizeMake(0, 2)
//        ibo_scrollView.layer.shadowColor = UIColor.blackColor().CGColor
//        ibo_scrollView.layer.shadowOpacity = 0.5
//        ibo_scrollView.layer.shadowRadius = 2
        
        UIView.animate(withDuration: 0.5) { 
            self.ibo_scrollView.alpha = 1
        }
    }
    
    @objc func iba_toggleTab(_ sender:UIButton){
        
        for btn in ibo_scrollView.subviews{
            
            btn.backgroundColor = UIColor.clear
        }
        
        sender.backgroundColor = UIColor.white
        print(assetDIR[sender.tag])
        currentPageIndex = sender.tag
        ibo_collectionView.reloadData()
        
    
    }
    
    @objc func cleanDir(_ ar:[String]) -> [String]{
        
        var strings = [String]()
        
        for dir in ar {
            var clean = dir.replacingOccurrences(of: "/", with: "")
            clean = clean.replacingOccurrences(of: "stickers", with: "")
            strings.append(clean)
        }
      
        return strings
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
         ibo_collectionView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.setupTabBar()

    }
    
    @IBAction func iba_restore(_ sender:UIBarButtonItem){
        
        PKHUD.sharedHUD.contentView = PKHUDProgressView()
        PKHUD.sharedHUD.show()

        //TODO: in app purchase needs to be fixed
        
//        let iap = SwiftInAppPurchase.sharedInstance
//        iap.restoreTransaction(nil) { (result) -> () in
//            switch result{
//            case .restored(let productId,let transaction,let paymentQueue) :
//
//                print(productId)
//                UserDefaults.standard.set(true, forKey: productId)
//                PKHUD.sharedHUD.hide()
//                self.ibo_collectionView.reloadData()
//                self.showAlert("Purchases Restored!")
//                paymentQueue.finishTransaction(transaction)
//            case .failed(let error):
//                print(error)
//                PKHUD.sharedHUD.contentView = PKHUDErrorView()
//                PKHUD.sharedHUD.hide()
//
//            default:
//                break
//            }
//        }

        
    }
    
    @objc func iba_done(_ sender: UIBarButtonItem){
        dismiss(animated: true, completion: { () -> Void in
        })
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int{
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assetArray[currentPageIndex].count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        currentPageID = assetDIR[currentPageIndex]
        if UserDefaults.standard.bool(forKey: assetDIR[currentPageIndex]) == false {
            isLocked = true
            self.ibo_lockBtn.isHidden = false
        } else {
            
            isLocked = false
            self.ibo_lockBtn.isHidden = true
            
        }
        
//        isLocked = false
//        self.ibo_lockBtn.isHidden = true
        
    
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! StickerCollectionCell
        
        cell.ibo_imageViewer.image = nil
        cell.setupImage(assetArray[currentPageIndex][indexPath.item])
        return cell
        

    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        if isLocked == true {
            return
        }
        
        
        let cell = collectionView.cellForItem(at: indexPath) as! StickerCollectionCell
        
        if let cellimage = cell.cellImage as UIImage? {
            
            self.delegate?.stickerDidFinishChoosing!(cellimage as UIImage)
            
        }
        
    }
    


    @IBAction func purchaseITEM(){
        
        PKHUD.sharedHUD.contentView = PKHUDProgressView()
        PKHUD.sharedHUD.show()
        
        print(currentPageID)

        //TODO: in app purchase needs to be fixed
//        let iap = SwiftInAppPurchase.sharedInstance
//        iap.addPayment(currentPageID, userIdentifier: nil) { (result) -> () in
//
//            switch result{
//            case .purchased(let productId,let transaction,let paymentQueue):
//                UserDefaults.standard.set(true, forKey: productId)
//                PKHUD.sharedHUD.hide()
//                self.ibo_collectionView.reloadData()
//                paymentQueue.finishTransaction(transaction)
//            case .failed(let error):
//                print(error)
//                PKHUD.sharedHUD.contentView = PKHUDErrorView()
//                PKHUD.sharedHUD.show()
//                PKHUD.sharedHUD.hide()
//            default:
//                break
//            }
//        }

        
        
    }

    @objc func showAlert(_ message:String){
        
        let alertController = UIAlertController(
            title: "Result",
            message: message,
            preferredStyle: .alert
        )
        
        
        alertController.addAction(UIAlertAction(title: "Done", style: .default) { _ in
            alertController.dismiss(animated: true, completion: nil)
            })
        
        self.present(alertController, animated: true) { 
            //
        }
        
        
    }

    
    override var prefersStatusBarHidden : Bool {
        return false
    }

}







class StickerCollectionCell : UICollectionViewCell {
    
    @IBOutlet var ibo_imageViewer:UIImageView!
    
    @objc var cellImage:UIImage!
    
    @objc func setupImage(_ file:String){
        
        cellImage = UIImage(contentsOfFile: file)
        ibo_imageViewer.image = cellImage

       
    
    }
}



//EMOJIS
class StickerCategoryViewController:UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @objc var delegate:StickerSelectDelegate!
    
    @IBOutlet var ibo_collectionView:UICollectionView!
    @objc var assetArray = [String]()
    
    override func viewDidLoad() {
        
        print("STICKER SELECT")
        super.viewDidLoad()
        
        navigationController?.setNavigationBarHidden(false, animated: false)
        
        title = "Select Sticker"
        navigationItem.rightBarButtonItem =  UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(StickerSectionViewController.iba_done(_:)))
        
        navigationItem.leftBarButtonItem =  UIBarButtonItem(title: "Restore", style: .plain, target: self, action: #selector(StickerSectionViewController.iba_restore(_:)))
        
        navigationController?.navigationBar.tintColor = UIColor.magenta
        navigationController?.navigationBar.backgroundColor = UIColor.yellow
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
        flowLayoutFull.itemSize = CGSize(width: self.view.frame.size.height/4, height: self.view.frame.size.height/4)
        flowLayoutFull.minimumInteritemSpacing = 0
        flowLayoutFull.minimumLineSpacing = 0
        flowLayoutFull.scrollDirection = .horizontal
        ibo_collectionView.setCollectionViewLayout(flowLayoutFull, animated: false)
    }
    
    @objc func iba_restore(_ sender: UIBarButtonItem){
  
    }
    
    @objc func iba_done(_ sender: UIBarButtonItem){
        dismiss(animated: true, completion: { () -> Void in
            //
        })
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int{
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assetArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        //print("cell")
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! StickerCollectionCell
        
        
        //println(imageData)
        cell.ibo_imageViewer.image = nil
        cell.setupImage(assetArray[indexPath.item])
        
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //
        let cell = collectionView.cellForItem(at: indexPath) as! StickerCollectionCell
        
        if let cellimage = cell.cellImage as UIImage? {
            
            self.delegate.stickerDidFinishChoosing?(cellimage as UIImage)
            
            dismiss(animated: true, completion: { () -> Void in
                
            })
            
        }
    }
    
    
    
}
