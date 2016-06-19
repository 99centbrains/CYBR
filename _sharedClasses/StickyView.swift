//
//  StickyView.swift
//  OMGWTFSTFU
//
//  Created by Franky Aguilar on 9/10/15.
//  Copyright (c) 2015 99centbrains. All rights reserved.
//

import Foundation
import UIKit

class StickyView:UIView {
    var view:UIView?
}

public enum StickyImageType : Int {
    
    case Image
    case Text
    
}

class StickyImageView: UIImageView {
    
    var typeText:String?
    var typeFont:UIFont?
    var typeColor:UIColor?
    var typeAlignment:NSTextAlignment?
    
    var stickyKind:StickyImageType!
    
    
    var tapCallback: ((sticker: StickyImageView) -> ())? = nil
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        self.userInteractionEnabled = true
      
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        
        
//        UITouch *touch = [touches anyObject];
//        if (touch.tapCount == 1) {
//            //if they tapped within the coin then place the single tap action to fire after a delay of 0.3
//            if (CGRectContainsPoint(coin.frame,[touch locationInView:self.view])){
//                //this is the single tap action being set on a delay
//                [self performSelector:@selector(onFlip) withObject:nil afterDelay:0.3];
//            }else{
//                //I change the background image here
//            }
//        } else if (touch.tapCount == 2) {
//            //this is the double tap action
//            [theCoin changeCoin:coin];
    //}
        
        NSNotificationCenter.defaultCenter().postNotificationName("StickerTap", object: self)
    }
    
    func flipSticker(){
    
        var flippedImage:UIImage!
        
        if self.image!.imageOrientation == .UpMirrored{
            
            flippedImage = UIImage(CGImage: self.image!.CGImage!, scale: self.image!.scale, orientation: UIImageOrientation.Up)
        
        } else {
            flippedImage = UIImage(CGImage: self.image!.CGImage!, scale: self.image!.scale, orientation: UIImageOrientation.UpMirrored)
        }
        
        self.image = flippedImage
        flippedImage = nil
        
    
    }
    
  
    
//    - (UIImage *)imageByTrimmingTransparentPixels
//    {
//    return [self imageByTrimmingTransparentPixelsRequiringFullOpacity:NO];
//    }
//    
//    /*
//    * Alternative method signature allowing for the use of cropping based on semi-transparency.
//    */
//    - (UIImage *)imageByTrimmingTransparentPixelsRequiringFullOpacity:(BOOL)fullyOpaque
//    {
//    if (self.size.height < 2 || self.size.width < 2) {
//    
//    return self;
//    
//    }
//    
//    CGRect rect = CGRectMake(0, 0, self.size.width * self.scale, self.size.height * self.scale);
//    UIEdgeInsets crop = [self transparencyInsetsRequiringFullOpacity:fullyOpaque];
//    
//    UIImage *img = self;
//    
//    if (crop.top == 0 && crop.bottom == 0 && crop.left == 0 && crop.right == 0) {
//    
//    // No cropping needed
//    
//    } else {
//    
//    // Calculate new crop bounds
//    rect.origin.x += crop.left;
//    rect.origin.y += crop.top;
//    rect.size.width -= crop.left + crop.right;
//    rect.size.height -= crop.top + crop.bottom;
//    
//    // Crop it
//    CGImageRef newImage = CGImageCreateWithImageInRect([self CGImage], rect);
//    
//    // Convert back to UIImage
//    img = [UIImage imageWithCGImage:newImage scale:self.scale orientation:self.imageOrientation];
//    
//    CGImageRelease(newImage);
//    }
//    
//    return img;
//    }
    

  
    

//    required init(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//    }
//
//    override init(image: UIImage!) {
//        super.init(image: image)
//    }
    
    
}

class StickyFontView: UITextView {
    
}