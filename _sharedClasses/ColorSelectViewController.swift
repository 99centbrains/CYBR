//
//  ColorSelectViewController.swift
//  OMGWTFSTFU
//
//  Created by Franky Aguilar on 9/18/15.
//  Copyright (c) 2015 99centbrains. All rights reserved.
//

import Foundation
import UIKit


protocol CWColorSelectViewControllerDelegate {
    
    func colorSelectChoseColor(color:UIColor)
    func colorSelectDismiss()
    
}


class CWColorSelectViewController:UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    var delegate:CWColorSelectViewControllerDelegate!
    
    var colorPallet = [String]()
    @IBOutlet var ibo_collectionView:UICollectionView!
    
    @IBAction func iba_dismiss(){
        self.delegate.colorSelectDismiss()
    }
    override func viewDidLoad() {
        
       // NSArray *colorArray = [[UIColor seafoamColor] hsbaArray];
        
        
        let assManager = AssetManager()
        let path = "/swatches/"
        let swatch = assManager.getAssetsForDir(path)
        for color in swatch {
            
            //colorPallet += [assManager.getFullAsset(color, dir: path)]
            print(assManager.getFullAsset(color, dir: path))
            colorPallet += [assManager.getFullAsset(color, dir: path)]

        }

        print(colorPallet)
        
        ibo_collectionView.layer.borderColor = UIColor.lightGrayColor().CGColor
        ibo_collectionView.layer.borderWidth = 6.0
        

        //
    }
    override func viewDidLayoutSubviews() {
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSizeMake(ibo_collectionView.frame.size.width/5 - 5, ibo_collectionView.frame.size.width/5 - 5)
        layout.minimumLineSpacing = 5
        layout.sectionInset = UIEdgeInsetsMake(20, 20, 20, 20)
        layout.scrollDirection = .Vertical
        
        ibo_collectionView.setCollectionViewLayout(layout, animated: false)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        //
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int{
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colorPallet.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        print("cell")
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! ColorCellView
        
        cell.setColor(colorPallet[indexPath.item])
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        //
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! ColorCellView
        delegate.colorSelectChoseColor(cell.backgroundColor!)
        
        
        
    }
 

   
}

class ColorCellView: UICollectionViewCell {
    
    func setColor(col:String){
        
        let imageData = NSData(contentsOfFile: col)
        let img = UIImage(data:imageData!)
        let swatchColor = UIColor(patternImage:img!)
        
        self.contentMode = .ScaleAspectFill
        self.backgroundColor = swatchColor
        self.layer.cornerRadius = self.frame.size.width/2
        self.layer.borderColor = UIColor.blackColor().CGColor
        self.layer.borderWidth = 2
    
    }
   
}


