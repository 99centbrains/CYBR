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
    
    func colorSelectChoseColor(_ color:UIColor)
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
        
        ibo_collectionView.layer.borderColor = UIColor.lightGray.cgColor
        ibo_collectionView.layer.borderWidth = 6.0
        

        //
    }
    override func viewDidLayoutSubviews() {
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: ibo_collectionView.frame.size.width/5 - 5, height: ibo_collectionView.frame.size.width/5 - 5)
        layout.minimumLineSpacing = 5
        layout.sectionInset = UIEdgeInsetsMake(20, 20, 20, 20)
        layout.scrollDirection = .vertical
        
        ibo_collectionView.setCollectionViewLayout(layout, animated: false)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int{
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colorPallet.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        print("cell")
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ColorCellView
        
        cell.setColor(colorPallet[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //
        let cell = collectionView.cellForItem(at: indexPath) as! ColorCellView
        if indexPath.item == 0 {
            delegate.colorSelectChoseColor(UIColor.clear)
        } else {
            delegate.colorSelectChoseColor(cell.backgroundColor!)
        }
        
        
        
    }
 

   
}

class ColorCellView: UICollectionViewCell {
    
    func setColor(_ col:String){
        
        let imageData = try? Data(contentsOf: URL(fileURLWithPath: col))
        let img = UIImage(data:imageData!)
        let swatchColor = UIColor(patternImage:img!)
        
        self.contentMode = .scaleAspectFill
        self.backgroundColor = swatchColor
        self.layer.cornerRadius = self.frame.size.width/2
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.borderWidth = 2
    
    }
   
}


