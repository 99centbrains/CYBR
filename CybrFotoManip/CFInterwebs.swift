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
import SwiftInAppPurchase
import PKHUD

@objc protocol CFInterWebsViewControllerDelegate {
    optional func stickerDidFinishChoosing(img:UIImage)
}

class CFInterWebsViewController:UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet weak var ibo_search:UITextField!
    var delegate:CFInterWebsViewControllerDelegate!
    
    @IBOutlet weak var ibo_linksView:UITableView!
    
    @IBOutlet weak var ibo_lockedView:UIView!
    @IBOutlet weak var ibo_lockedBTN:UIButton!
    
    var tumblrKey = "com.99cb.cybrfm.tumblr"
    
    
    var hyperlinks = [String]()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let linksurl = "http://labz.99centbrains.com/cybrfm/cybr_links.plist"
        let links = NSArray(contentsOfURL: NSURL(string:linksurl)!)
        if links == nil {
            hyperlinks = ["cybrfm.99centbrains", "blog.99centbrains.com"]
        } else {
            hyperlinks = (links as? [String])!
        }
        
    }
    
    @IBAction func iba_purchaseTumblr(){
        
        PKHUD.sharedHUD.contentView = PKHUDProgressView()
        PKHUD.sharedHUD.show()
        
        let iap = SwiftInAppPurchase.sharedInstance
        iap.addPayment(tumblrKey, userIdentifier: nil) { (result) -> () in
            
            switch result{
            case .Purchased(let productId,let transaction,let paymentQueue):
                NSUserDefaults.standardUserDefaults().setBool(true, forKey: self.tumblrKey)
                PKHUD.sharedHUD.hide()
                self.ibo_lockedView.hidden = true
                self.ibo_lockedBTN.hidden = true
                paymentQueue.finishTransaction(transaction)
            case .Failed(let error):
                print(error)
                
                PKHUD.sharedHUD.contentView = PKHUDErrorView()
                PKHUD.sharedHUD.show()
                PKHUD.sharedHUD.hide()
                
            case .NothingToDo:
                self.showAlert("Purchase Cancelled")
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
    
    
    @IBAction func iba_go() {
        
        if ibo_search.text!.isEmpty {
            return
        }
    
        let url = ibo_search.text?.stringByAppendingString(".tumblr.com")
        self.showNextView(url!)
        
        view.endEditing(true)
    }
    

    @IBAction func hitmyTwitter(){
    
        let string = "@99centbrains please add my #Tumblr on the #cybrFM app!"
        
        let vc = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
        vc.setInitialText(string)
        
        presentViewController(vc, animated: true, completion: nil)
        
    }

    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return hyperlinks.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        
        let cell = tableView.dequeueReusableCellWithIdentifier("TableLinkCell", forIndexPath: indexPath) as! TableLinkCell
        
        cell.ibo_label.text = hyperlinks[indexPath.row]
        
        return cell
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! TableLinkCell
        
         self.showNextView(cell.ibo_label.text!)
    }
    

    
    func showNextView(str:String){
        
 
        view.endEditing(true)
        
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("sb_CFInterWebsGridViewController") as! CFInterWebsGridViewController
        print(str)
        vc.prop_url = str
        vc.loadGrid()
        vc.isLocked = NSUserDefaults.standardUserDefaults().boolForKey(self.tumblrKey)
        vc.delegate = self.delegate
        self.navigationController?.pushViewController(vc, animated: true)

        
    
    }
    
    
    override func prefersStatusBarHidden() -> Bool {
        return false
    }
    
    override func viewWillAppear(animated: Bool) {
      
        super.viewWillAppear(animated)
        
        let isLocked = NSUserDefaults.standardUserDefaults().boolForKey(self.tumblrKey)
        ibo_lockedView.hidden = isLocked
        ibo_lockedBTN.hidden = isLocked
    }
}

class TableLinkCell:UITableViewCell{
    @IBOutlet weak var ibo_label:UILabel!
}

class CFInterWebsGridViewController:UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var ibo_collectionView:UICollectionView!
    
    var prop_url:String!
    
    var prop_photos = [String]()
    
    var delegate:CFInterWebsViewControllerDelegate!
    
    var offset = 0
    
    var gettingNewData = false
    var isLocked:Bool!
    
    @IBOutlet weak var ibo_lockedView:UIView!

    
    override func viewDidLoad() {
        
        self.title = prop_url
    
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "ui_cropview_checkers")!)
        
        navigationItem.rightBarButtonItem =  UIBarButtonItem(title: "Done", style: .Plain, target: self, action: #selector(self.iba_done(_:)))

    
    }
    
    func iba_done(sender: UIBarButtonItem){
        dismissViewControllerAnimated(true, completion: { () -> Void in
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
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        ibo_lockedView.hidden = isLocked
        
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        
        
        print("load grid")
        
        if prop_url == nil {
            return
        }
        
        print("URL \(prop_url)")
        
        self.loadTumblrApi(offset)
        
    }
    
    @IBAction func visitTumblr(){
        
        if prop_url.containsString(".tumblr.com") {
        
        TMTumblrAppClient.viewBlog(prop_url.stringByReplacingOccurrencesOfString(".tumblr.com", withString: ""))
            
        } else {
            
            let safari = SFSafariViewController(URL: NSURL(string:"http://".stringByAppendingString(prop_url))!)
            self.presentViewController(safari, animated: true, completion: nil)
            
        }
    }
    
    func loadTumblrApi(i:Int) {
        
        gettingNewData = true
        
        TMAPIClient.sharedInstance().OAuthConsumerKey = "c5GyLE1sxb1h7DIcAQu3Dum6ALeZGMssHuaL2XWv0es5Ayhh6S"
        TMAPIClient.sharedInstance().posts(prop_url, type: "photo", parameters:
        ["limit" : 50, "offset" : i * 50, "filter" : "raw"]) { (result:AnyObject!, error:NSError!) -> Void in
            
            if (error == nil){
                
                
                let elements = self.parseJsonoject(result as! [String : AnyObject])
                self.addNewGifs(elements)
                return
            }
            
            let alert = UIAlertController(title: "Oops", message: "\(error)", preferredStyle: .Alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: .Default) { _ in
                self.navigationController?.popViewControllerAnimated(true)
                })
            
            self.presentViewController(alert, animated: true, completion: nil)
        }

        
    }
    
    func parseJsonoject(result:[String:AnyObject]) -> [String]{
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
    
    func addNewGifs(elements:[String]){
        
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
            self.prop_photos.appendContentsOf(elements)
            var indexPaths = [NSIndexPath]()
            
                for i in oldCount ..< self.prop_photos.count{
                    indexPaths.append(NSIndexPath(forRow: i, inSection: 0))
                }
            self.ibo_collectionView.insertItemsAtIndexPaths(indexPaths)
            
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
    
    func loadGrid(){
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSizeMake(self.view.frame.size.width/2 - 20, self.view.frame.size.width/2 - 20)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        self.ibo_collectionView.setCollectionViewLayout(layout, animated: false)
        
        gettingNewData = false
        
    }
    
    //SCROLLVIEW
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
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
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int{
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return prop_photos.count
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! CFInterWebCollectionCell
        cell.setupImage(prop_photos[indexPath.item])
        return cell
        
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! CFInterWebCollectionCell
        
        self.delegate.stickerDidFinishChoosing!(cell.ibo_image)
        self.dismissViewControllerAnimated(true, completion: nil)
    
    }
    
    
}

class CFInterWebCollectionCell:UICollectionViewCell {
    
    @IBOutlet weak var ibo_imageView:UIImageView!
    
    var ibo_image:UIImage!

    func setupImage(url:String){
        print(url)
        
        self.ibo_imageView.image = nil
       
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            // do some task
            let data = NSData(contentsOfURL: NSURL(string:url)!)
            if data == nil {
                return
            }
            let image = UIImage(data: data!)
            
            self.ibo_image = image

            dispatch_async(dispatch_get_main_queue()) {
                // update some UI
                  self.ibo_imageView.image = image
            }
        }
    
    }
}