//
//  TumblrFeedViewController.swift
//  CybrFotoManip
//
//  Created by Franky Aguilar on 12/3/15.
//  Copyright © 2015 99centbrains. All rights reserved.
//

import Foundation
import UIKit
import TMTumblrSDK

class TumblrFeedViewController:UIViewController {
    
    var array_posts = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        TMAPIClient.sharedInstance().post("cybrfm.99centbrains.com", type: "photo", parameters: ["limit" : 20, "offset" : 0, "filter" : "raw"]) { (result:Any?, error:Error?) in
            
            print(result)
            
        }
       
        
    }
    
    @IBAction func iba_dismiss(_ sender:UIButton){
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        //
    }


}
