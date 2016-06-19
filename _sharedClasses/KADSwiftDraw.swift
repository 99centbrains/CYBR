//
//  File.swift
//  SwiftDrawing
//
//  Created by Kyle Adams on 09/09/14.
//  Copyright (c) 2014 Kyle Adams. All rights reserved.
//
import Foundation
import UIKit

class EmojiDrawView:UIView {
    
    var image = UIImage(named: "ui_cybrsmile")
    var someImageView = UIImageView()
    
    var brushSize:CGFloat!
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        //fatalError("init(coder:) has not been implemented")
        super.init(coder: aDecoder)
        setupView()
    }
    
    func clearView(){
        
        if (self.subviews.count == 0){
            return
        }
        
        for layer in self.subviews {
            layer.removeFromSuperview()
        }
    }
    
    func setupImage(img:UIImage){
        
        image = img
    
    }
    
    func setupView() {
        brushSize = 50
        backgroundColor = UIColor.clearColor()
        opaque = false
    }
    
    
    override func touchesBegan(touches:  Set<UITouch>, withEvent event: UIEvent?) {
        
        let touch = touches.first
        drawBrush(touch!.locationInView(self))
        
    }
    
    override func touchesMoved(touches:  Set<UITouch>, withEvent event: UIEvent?) {
        
        let touch = touches.first
        drawBrush(touch!.locationInView(self))
    
    }
    
    override func touchesEnded(touches:  Set<UITouch>, withEvent event: UIEvent?) {
        
        drawBitmap()
        
    }
    
    override func touchesCancelled(touches:  Set<UITouch>?, withEvent event: UIEvent?) {
        
        drawBitmap()
       
    }
    
    func drawBrush(point:CGPoint){
        
        let imageView = UIImageView()
        imageView.frame = CGRectMake(0, 0, brushSize, brushSize)
        imageView.contentMode = UIViewContentMode.ScaleAspectFit
        imageView.image = image
        imageView.center = point
        
        self.addSubview(imageView)
        
    }
    
    func drawBitmap() {
        
        print("DONE \(self.frame)")
        UIGraphicsBeginImageContextWithOptions(self.frame.size, false, 0.0)
        self.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let cache = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        
        for layer in self.subviews {
           layer.removeFromSuperview()
        }
        
            let someIMGV = UIImageView()
            someIMGV.contentMode = UIViewContentMode.ScaleAspectFill
            someIMGV.frame = self.bounds
            someIMGV.image = cache
            self.addSubview(someIMGV)
        print("DONE \(someIMGV.frame)")
    }
    
    func renderSticker() -> UIImage?{
        
        var image:UIImage!
        
        if self.subviews.count == 0 {
            return nil
        }
        
        for layer in self.subviews {
            if let imageView = layer as? UIImageView {
                image = imageView.image
            }
            
        }
        clearView()
        
        return image
        
        
    
    }
    

}

class SwiftDrawView: UIView {
    
    private var firstTimeCache = true
    private var path = UIBezierPath()
    private var cache = UIImage()
    
    private var pts = [CGPointZero, CGPointZero, CGPointZero, CGPointZero]
    private var ctr: Int!
    
    var lineWidth: CGFloat = 1.0
    var lineColor = UIColor.blackColor()
    var eraserMode = false
    
    var undoManage:NSUndoManager!
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        //fatalError("init(coder:) has not been implemented")
        super.init(coder: aDecoder)
        setupView()
    }
    
    func setupView() {
        backgroundColor = UIColor.clearColor()
        opaque = false
    }
    
    override func drawRect(rect: CGRect) {
        print("draw rect")
//        backgroundColor = UIColor.clearColor()
//        opaque = false
        cache.drawInRect(rect)
        path.lineWidth = lineWidth
        path.lineCapStyle = CGLineCap.Round
        if eraserMode {
            UIColor.whiteColor().setStroke()
            path.strokeWithBlendMode(CGBlendMode.Clear, alpha: 1.0)
        } else {
            lineColor.setStroke()
            path.stroke()
        }
    }
    

    override func touchesBegan(touches:  Set<UITouch>, withEvent event: UIEvent?) {
        print("touch")
        ctr = 0
        let touch = touches.first
        pts[0] = touch!.locationInView(self)
            
    }
    
    override func touchesMoved(touches:  Set<UITouch>, withEvent event: UIEvent?) {
        let touch = touches.first
        let p = touch!.locationInView(self)
        ctr = ctr + 1
        pts[ctr] = p
        if  (ctr == 3) {
            pts[2] = CGPointMake((pts[1].x + pts[3].x)/2.0, (pts[1].y + pts[3].y)/2.0);
            path.moveToPoint(pts[0])
            path.addQuadCurveToPoint(pts[2], controlPoint: pts[1])
            setNeedsDisplay()
            pts[0] = pts[2]
            pts[1] = pts[3]
            ctr = 1
        }
    }
    
    override func touchesEnded(touches:  Set<UITouch>, withEvent event: UIEvent?) {
        if (ctr == 0)
        {
            //path.addArcWithCenter(pts[0], radius: 1, startAngle: 0, endAngle: CGFloat(M_PI) * 2, clockwise: true)
            let magicNumber = lineWidth / 6
            path = UIBezierPath(roundedRect: CGRectMake(pts[0].x, pts[0].y, magicNumber, magicNumber), cornerRadius: magicNumber / 2)
        }
        else if (ctr == 1)
        {
            path.moveToPoint(pts[0])
            path.addLineToPoint(pts[1])
        }
        else if (ctr == 2)
        {
            path.moveToPoint(pts[0])
            path.addQuadCurveToPoint(pts[2], controlPoint: pts[1])
        }
        if !eraserMode {
            self.drawBitmap()
        } else {
            self.eraseBitmap()
        }
        setNeedsDisplay()
        path.removeAllPoints()
        ctr = 0;
        
       
        print("DREW")
    }
    
    override func touchesCancelled(touches:  Set<UITouch>?, withEvent event: UIEvent?) {
        touchesEnded(touches!, withEvent: event)
        
        print("DREW")
    }
    
    func drawBitmap() {
        
        print("Draw Bitmap")
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0.0)
        
        lineColor.setStroke()
        path.lineWidth = lineWidth
        path.lineCapStyle = CGLineCap.Round
        if (firstTimeCache) {
            let rectPath = UIBezierPath(rect: bounds)
            UIColor.clearColor().setFill()
            rectPath.fill()
            firstTimeCache = false
        }
        
        cache.drawAtPoint(CGPointZero)
        path.stroke()
        
        cache = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }
    
    func eraseBitmap() {
        
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0.0)
        cache.drawAtPoint(CGPointZero)
        path.strokeWithBlendMode(CGBlendMode.Clear, alpha: 1.0)
        cache = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
  
    }
    
    func clearBitmap() {
        
        print("CLEAR BITMAP")
        
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0.0)

        let context = UIGraphicsGetCurrentContext()
        CGContextSetFillColorWithColor(context, UIColor.clearColor().CGColor)
        CGContextFillRect(context, self.bounds)
        
        cache = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        
        self.setNeedsDisplay()
            
        
    }
    
    
    
    
    
}

@objc protocol PaintToolViewControllerDelegate {
    
    optional func paint_toggleEraser(state:Bool)
    
    optional func paint_setSizeUP(isPaint:Bool)
    optional func paint_setSizeDown(isPaint:Bool)
    optional func paint_setColor(color:UIColor)
    optional func paint_setImage(img:UIImage)
    
    optional func paint_undo()
    optional func paint_clear()
    optional func paint_dismiss()
    
    optional func paintSelectColor()
    
    optional func paint_popout()
    
    optional func paintSelectImage()
    
    

}

class PaintToolViewController:UIViewController , CWColorSelectViewControllerDelegate, StickerSelectDelegate, CFInterWebsViewControllerDelegate{
    
    var delegate:PaintToolViewControllerDelegate!
    var eraser:Bool = false
    
    var ibo_vcColorSelect:CWColorSelectViewController!
    
    var ibo_imageSelector:StickerCategoryViewController!
    
    @IBOutlet var ibo_buttonPicker:UIButton!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.view.userInteractionEnabled = true
        
    }
    
    @IBAction func iba_popoutPainting(){
    
        delegate.paint_popout?()
        
    }
    
    @IBAction func iba_toggleEraser(){
        
        if eraser {
            eraser = false
        } else {
            eraser = true
        }
        delegate.paint_toggleEraser?(eraser)
    
    }
    
    @IBAction func iba_changeSizeUP(sender:UIButton){
        
        switch sender.tag{
        case 0:
            delegate.paint_setSizeUP?(true)
        case 1:
            delegate.paint_setSizeUP?(false)
        default: break
            //
        }
        
    }
    
    @IBAction func iba_changeSizeDown(sender:UIButton){
        
        switch sender.tag{
        case 0:
            delegate.paint_setSizeDown?(true)
        case 1:
            delegate.paint_setSizeDown?(false)
        default: break
            //
        }
        
    }
    
    @IBAction func iba_clear(){
        
        delegate.paint_clear?()
    
    }
    
    @IBAction func iba_undo(){
        
        delegate.paint_undo?()
        
    }
    
    @IBAction func iba_colorSelect(){
        
       delegate.paintSelectColor?()
        
        

    }
    
    func colorSelectChoseColor(color:UIColor){
        colorSelectDismiss()
        delegate.paint_setColor?(color)
        
        ibo_buttonPicker.setImage(nil, forState: .Normal)

    
    }
    func colorSelectDismiss(){
        
        ibo_vcColorSelect.view.removeFromSuperview()
        ibo_vcColorSelect.delegate = nil
        ibo_vcColorSelect = nil

    }


    
    @IBAction func tool_stickerSelect(){
        
        delegate.paintSelectImage!()
        
        
        return
        let stickerBored2 = UIStoryboard(name: "StickerSelectStoryboard", bundle: nil)
        ibo_imageSelector = stickerBored2.instantiateViewControllerWithIdentifier("sb_StickerCategoryViewController") as! StickerCategoryViewController
        
        ibo_imageSelector.delegate = self
        ibo_imageSelector.view.frame = self.view.frame
        
        self.view.addSubview(ibo_imageSelector.view)
        
    }
    

   

    @IBAction func iba_dismiss(){
        
        delegate.paint_dismiss?()
        
    }
    
    

}
