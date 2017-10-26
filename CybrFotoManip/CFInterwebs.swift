//
//  CFInterwebs.swift
//  CybrFotoManip
//
//  Created by Franky Aguilar on 4/4/16.
//  Copyright © 2016 99centbrains. All rights reserved.
//

import Foundation
import UIKit
import TMTumblrSDK
import SwiftyJSON
import Social
import SafariServices
import PKHUD

@objc protocol CFInterWebsViewControllerDelegate {
    @objc optional func stickerDidFinishChoosing(_ img:UIImage)
}

class CFInterWebsViewController:UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet weak var ibo_search:UITextField!
    @objc var delegate:CFInterWebsViewControllerDelegate!
    
    @IBOutlet weak var ibo_linksView:UITableView!
    
    @IBOutlet weak var ibo_lockedView:UIView!
    @IBOutlet weak var ibo_lockedBTN:UIButton!
    
    @objc var tumblrKey = "com.99cb.cybrfm.tumblr"
    
    
    @objc var hyperlinks = [String]()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let linksurl = "http://labz.99centbrains.com/cyber/cyber_links.plist"
        let links = NSArray(contentsOf: URL(string:linksurl)!)
        if links == nil {
            hyperlinks = ["cybernetart.tumblr.com", "blog.99centbrains.com"]
        } else {
            hyperlinks = (links as? [String])!
        }
        
    }
    
    @IBAction func iba_purchaseTumblr(){
        
        PKHUD.sharedHUD.contentView = PKHUDProgressView()
        PKHUD.sharedHUD.show()

        //TODO: in app purchase needs to be fixed
//        let iap = SwiftInAppPurchase.sharedInstance
//        iap.addPayment(tumblrKey, userIdentifier: nil) { (result) -> () in
//
//            switch result{
//            case .purchased(let productId,let transaction,let paymentQueue):
//                UserDefaults.standard.set(true, forKey: self.tumblrKey)
//                PKHUD.sharedHUD.hide()
//                self.ibo_lockedView.isHidden = true
//                self.ibo_lockedBTN.isHidden = true
//                paymentQueue.finishTransaction(transaction)
//            case .failed(let error):
//                print(error)
//
//                PKHUD.sharedHUD.contentView = PKHUDErrorView()
//                PKHUD.sharedHUD.show()
//                PKHUD.sharedHUD.hide()
//
//            case .nothingToDo:
//                self.showAlert("Purchase Cancelled")
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
    
    
    @IBAction func iba_go() {
        
        if ibo_search.text!.isEmpty {
            return
        }
    
        let url = (ibo_search.text)! + ".tumblr.com"
        self.showNextView(url)
        
        view.endEditing(true)
    }
    

    @IBAction func hitmyTwitter(){
    
        let string = "@99centbrains please add my #Tumblr on the #cybernetart app!"
        
        let vc = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
        vc?.setInitialText(string)
        
        present(vc!, animated: true, completion: nil)
        
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return hyperlinks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableLinkCell", for: indexPath) as! TableLinkCell
        
        cell.ibo_label.text = hyperlinks[indexPath.row]
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! TableLinkCell
        
         self.showNextView(cell.ibo_label.text!)
    }
    

    
    @objc func showNextView(_ str:String){
        
 
        view.endEditing(true)
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "sb_CFInterWebsGridViewController") as! CFInterWebsGridViewController
        print(str)
        vc.prop_url = str
        vc.loadGrid()
        vc.isLocked = UserDefaults.standard.bool(forKey: self.tumblrKey)
        vc.delegate = self.delegate
        self.navigationController?.pushViewController(vc, animated: true)

        
    
    }
    
    
    override var prefersStatusBarHidden : Bool {
        return false
    }
    
    override func viewWillAppear(_ animated: Bool) {
      
        super.viewWillAppear(animated)
        
        let isLocked = UserDefaults.standard.bool(forKey: self.tumblrKey)
        ibo_lockedView.isHidden = isLocked
        ibo_lockedBTN.isHidden = isLocked
    }
}

class TableLinkCell:UITableViewCell{
    @IBOutlet weak var ibo_label:UILabel!
}

class CFInterWebsGridViewController:UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var ibo_collectionView:UICollectionView!
    
    @objc var prop_url:String!
    
    @objc var prop_photos = [String]()
    
    @objc var delegate:CFInterWebsViewControllerDelegate!
    
    @objc var offset = 0
    
    @objc var gettingNewData = false
    var isLocked:Bool!
    
    @IBOutlet weak var ibo_lockedView:UIView!

    
    override func viewDidLoad() {
        
        self.title = prop_url
    
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "ui_cropview_checkers")!)
        
        navigationItem.rightBarButtonItem =  UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(self.iba_done(_:)))

    
    }
    
    @objc func iba_done(_ sender: UIBarButtonItem){
        dismiss(animated: true, completion: { () -> Void in
        })
    }
    
    
    @IBAction func iba_offsetplus(){
        
        offset += 50
    
    }
    
    @IBAction func iba_offsetdown(){
        
        if offset <= 50 {
            offset = 0
        } else {
            offset -= 50
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        ibo_lockedView.isHidden = isLocked
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
        
        print("load grid")
        
        if prop_url == nil {
            return
        }
        
        print("URL \(prop_url)")
        
        self.loadTumblrApi(offset)
        
    }
    
    @IBAction func visitTumblr(){
        
        if prop_url.contains(".tumblr.com") {
        
            let blogName = prop_url.replacingOccurrences(of: ".tumblr.com", with: "")
        
        TMTumblrAppClient.viewBlog(blogName)
            
        } else {
            
            let safari = SFSafariViewController(url: URL(string:"http://" + prop_url!)!)
            self.present(safari, animated: true, completion: nil)
            
        }
    }
    
    @objc func loadTumblrApi(_ i:Int) {
        
        gettingNewData = true
        
        
        print(prop_url)
        
        
        TMAPIClient.sharedInstance().posts(prop_url!, type: "photo", parameters: ["limit" : 50, "offset" : i * 50, "filter" : "raw"]) { (result:Any?, error:Error?) in
   
            print(result)
            
            if (error == nil){
                
                
                let elements = self.parseJsonoject(result as! [String : AnyObject])
                self.addNewGifs(elements)
                return
            }
            
            let alert = UIAlertController(title: "Oops", message: "\(error!)", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                self.navigationController?.popViewController(animated: true)
            })
            
            self.present(alert, animated: true, completion: nil   )
        }

        
    }
    
    @objc func parseJsonoject(_ result:[String:AnyObject]) -> [String]{
        //print(result["posts"])
        
        var array_postPhotos = [String]()
        let postArray = result["posts"] as? [AnyObject]
        for p in postArray! {
            let photos = p["photos"] as! [AnyObject]
            let ph = photos[0]["original_size"] as! [String:AnyObject]
            //let original = photos!!["original_size"]
            //print(ph["url"])
            
            array_postPhotos.append(ph["url"] as! String)
            
            
        }
        
        return array_postPhotos
        

        
    }
    
    @objc func addNewGifs(_ elements:[String]){
        
        /*
         NSArray *newData = [[NSArray alloc] initWithObjects:@"otherData", nil];
         [self.myCollectionView performBatchUpdates:^{
         int resultsSize = [self.data count]; //data is the previous array of data
         [self.data addObjectsFromArray:newData];
         NSMutableArray *arrayWithIndexPaths = [NSMutableArray array];
         
         for (int i = resultsSize; i < resultsSize + newData.count; i++) {
         [arrayWithIndexPaths addObject:[NSIndexPath indexPathForRow:i
         inSection:0]];
         }
         [self.myCollectionView insertItemsAtIndexPaths:arrayWithIndexPaths];
         } completion:nil];
 */
        
        
        //let oldCount = self.prop_photos.count
        //self.prop_photos.appendContentsOf(elements)
        
        
        self.ibo_collectionView.performBatchUpdates({
            let oldCount = self.prop_photos.count
            self.prop_photos.append(contentsOf: elements)
            var indexPaths = [IndexPath]()
            
                for i in oldCount ..< self.prop_photos.count{
                    indexPaths.append(IndexPath(row: i, section: 0))
                }
            self.ibo_collectionView.insertItems(at: indexPaths)
            
            //
            }, completion: nil)
        
        //dispatchReload
//        let delay = 0.5 * Double(NSEC_PER_SEC)
//        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
//        dispatch_after(time, dispatch_get_main_queue()) {
//            self.ibo_collectionView.reloadData()
//        }
        gettingNewData = false

    }
    
    @objc func loadGrid(){
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: self.view.frame.size.width/2 - 20, height: self.view.frame.size.width/2 - 20)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        self.ibo_collectionView.setCollectionViewLayout(layout, animated: false)
        
        gettingNewData = false
        
    }
    
    //SCROLLVIEW
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if (gettingNewData){
            return
        }
        
        let y = scrollView.contentOffset.y + scrollView.bounds.size.height - scrollView.contentInset.bottom
        let h = scrollView.contentSize.height - 200
        
        
        print("\(y) ///// \(h)")
        
        if y > h {
            
            offset += 1
            self.loadTumblrApi(offset)
        }
        
        /* if (!gettingNewData){
         
         if(y > h + reload_distance) {
         gettingNewData = YES;
         feedoffset ++;
         [self action_getjson];
         }
         
         }*/
        
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int{
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return prop_photos.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CFInterWebCollectionCell
        cell.setupImage(prop_photos[indexPath.item])
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath) as! CFInterWebCollectionCell
        
        self.delegate.stickerDidFinishChoosing!(cell.ibo_image)
        self.dismiss(animated: true, completion: nil)
    
    }
    
    
}

class CFInterWebCollectionCell:UICollectionViewCell {
    
    @IBOutlet weak var ibo_imageView:UIImageView!
    
    @objc var ibo_image:UIImage!

    @objc func setupImage(_ url:String){
        print(url)
        
        self.ibo_imageView.image = nil
       
        let priority = DispatchQueue.GlobalQueuePriority.default
        DispatchQueue.global(priority: priority).async {
            // do some task
            let data = try? Data(contentsOf: URL(string:url)!)
            if data == nil {
                return
            }
            let image = UIImage(data: data!)
            
            self.ibo_image = image

            DispatchQueue.main.async {
                // update some UI
                  self.ibo_imageView.image = image
            }
        }
    
    }
}
