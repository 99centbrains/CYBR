//
//  File.swift
//  OMGWTFSTFU
//
//  Created by Franky Aguilar on 9/16/15.
//  Copyright (c) 2015 99centbrains. All rights reserved.
//

import Foundation
import UIKit

protocol CWToolBarViewControllerDelegate {
    
    func tool_stickerSelect()
    func tool_fontTyper()
    func tool_paintSelect()
    func tool_paintMoji()
    func foto_import()
    func foto_save()
    func tool_background()
    func tool_backgroundPhoto()
    
    func tool_clearAll()
}

class CWToolBarViewController:UIViewController {
    
    var delegate:CWToolBarViewControllerDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    @IBAction func iba_fotoImport(){
    
        delegate.foto_import()
    }
    @IBAction func iba_saveCanvas(){
        delegate.foto_save()
    
    }
    
    @IBAction func iba_stickerSelect(){
        delegate.tool_stickerSelect()
    }
    
    @IBAction func iba_clearAll(){
        delegate.tool_clearAll()
    }
    
    @IBAction func iba_paintSelect(){
        
        delegate.tool_paintSelect()
    }
    
    @IBAction func iba_paintMoji(){
        
        delegate.tool_paintMoji()
    }
    
    @IBAction func iba_backgroundTool(){
        
        delegate.tool_background()
    }
    
    @IBAction func iba_backgroundImage(){
        delegate.tool_backgroundPhoto()
    }
    
    @IBAction func iba_fontTool(){
        
        delegate.tool_fontTyper()
        
    }
    
}

protocol CWStickerEditVCDelgate {
    
    func edit_stickerDone()
    func edit_stickerTrash()
    func edit_flip()
    func edit_copy()
    func edit_layerUp()
    func edit_layerDown()
    func edit_reflect()
    
    func edit_editImage()
    
}

class CWStickerEditViewController:UIViewController {
    
    var delegate:CWStickerEditVCDelgate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func edit_stickerDone(){
        
        delegate.edit_stickerDone()
        
    }
    
    @IBAction func edit_stickerTrash(){
        
        delegate.edit_stickerTrash()
        
    }
    
    @IBAction func edit_flip(){
        
        delegate.edit_flip()
        
    }
    
    @IBAction func edit_copy(){
        
        delegate.edit_copy()
        
    }
    
    @IBAction func edit_layerUp(){
        
        delegate.edit_layerUp()
        
    }
    
    @IBAction func edit_layerDown(){
        
        delegate.edit_layerDown()
        
    }
    
    @IBAction func edit_reflect(){
        
        delegate.edit_reflect()
        
    }
    
    @IBAction func edit_editSticker(){
    
        delegate.edit_editImage()
    }
    
   
    
}


//FONT TOOLS
protocol FontToolViewControllerDelegate {
    
    func font_changeColor()
    func font_toggleAlignment()
    func font_sizeUp()
    func font_sizeDown()
    func font_chooseFont(_ font:UIFont)
    func font_done()
    func font_changeSaying(_ string:String)
}


class FontToolViewController:UIViewController {
    
    var delegate:FontToolViewControllerDelegate!
    
    var fontIndex = 0
    
    let fontNames = ["ArialMT", "BasicSharpie", "WithMyWoes", "MarkerTwins", "Noteworthy-Bold", "EnglishTowne-Medium", "katakanatfb", "Courier", "ROCKYAOE","Rune", "AcehDarusalam",   "Symbol", "Greek Mythology", "IllustrateIT"]
    
    var blurbs = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let blurbsURL = "http://labz.99centbrains.com/cybrfm/cybr_blurbs.plist"
        let blurbsArray = NSArray(contentsOf: URL(string:blurbsURL)!)
        if blurbsArray == nil {
            blurbs = ["404", "Internet not Available", "This app Sucks!", "Download Cybrfm.com", "Stay Wavy", "Investigate 311"]
        } else {
            blurbs = (blurbsArray as? [String])!
        }

        
    }
    
    @IBAction func fontDone(){
        self.delegate.font_done()
    
    }
    @IBAction func font_changeColor(){
        
        delegate.font_changeColor()
    
    }
    @IBAction func font_toggleAlignment(){
        delegate.font_toggleAlignment()
    
    }
    @IBAction func font_sizeUp(){
        
        delegate.font_sizeUp()
    
    }
    @IBAction func font_sizeDown(){
        
        delegate.font_sizeDown()
    
    }
    @IBAction func font_chooseFont(){
        
        fontIndex += 1
        
        if fontIndex > fontNames.count - 1{
            fontIndex = 0
        }
        
        let fontName = fontNames[fontIndex]
        
        delegate.font_chooseFont(UIFont(name: fontName, size: 72)!)
    
    }
    
    @IBAction func font_toggleBlurb(){
        
        
        let randomIndex = Int(arc4random_uniform(UInt32(blurbs.count)))
        delegate.font_changeSaying(blurbs[randomIndex])
            
    
    
        
    }
    
    
    
}
