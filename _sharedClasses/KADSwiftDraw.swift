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
    
    @objc var image = UIImage(named: "ui_cybrsmile")
    @objc var someImageView = UIImageView()
    
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
    
    @objc func clearView(){
        
        if (self.subviews.count == 0){
            return
        }
        
        for layer in self.subviews {
            layer.removeFromSuperview()
        }
    }
    
    @objc func setupImage(_ img:UIImage){
        
        image = img
    
    }
    
    @objc func setupView() {
        brushSize = 50
        backgroundColor = UIColor.clear
        isOpaque = false
    }
    
    
    override func touchesBegan(_ touches:  Set<UITouch>, with event: UIEvent?) {
        
        let touch = touches.first
        drawBrush(touch!.location(in: self))
        
    }
    
    override func touchesMoved(_ touches:  Set<UITouch>, with event: UIEvent?) {
        
        let touch = touches.first
        drawBrush(touch!.location(in: self))
    
    }
    
    override func touchesEnded(_ touches:  Set<UITouch>, with event: UIEvent?) {
        
        drawBitmap()
        
    }
    
    override func touchesCancelled(_ touches:  Set<UITouch>, with event: UIEvent?) {
        
        drawBitmap()
       
    }
    
    @objc func drawBrush(_ point:CGPoint){
        
        let imageView = UIImageView()
        imageView.frame = CGRect(x: 0, y: 0, width: brushSize, height: brushSize)
        imageView.contentMode = UIViewContentMode.scaleAspectFit
        imageView.image = image
        imageView.center = point
        
        self.addSubview(imageView)
        
    }
    
    @objc func drawBitmap() {
        
        print("DONE \(self.frame)")
        UIGraphicsBeginImageContextWithOptions(self.frame.size, false, 0.0)
        self.layer.render(in: UIGraphicsGetCurrentContext()!)
        let cache = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        
        for layer in self.subviews {
           layer.removeFromSuperview()
        }
        
            let someIMGV = UIImageView()
            someIMGV.contentMode = UIViewContentMode.scaleAspectFill
            someIMGV.frame = self.bounds
            someIMGV.image = cache
            self.addSubview(someIMGV)
        print("DONE \(someIMGV.frame)")
    }
    
    @objc func renderSticker() -> UIImage?{
        
        var i:UIImage!
        
        if self.subviews.count == 0 {
            return nil
        }
        
        for layer in self.subviews {
            if let imageView = layer as? UIImageView {
                i = imageView.image
            }
            
        }
        clearView()
        
        return i
        
        
    
    }
    

}

class SwiftDrawView: UIView {
    
    fileprivate var firstTimeCache = true
    fileprivate var path = UIBezierPath()
    fileprivate var cache = UIImage()
    
    fileprivate var pts = [CGPoint.zero, CGPoint.zero, CGPoint.zero, CGPoint.zero]
    fileprivate var ctr: Int!
    
    @objc var lineWidth: CGFloat = 1.0
    @objc var lineColor = UIColor.black
    @objc var eraserMode = false
    
    @objc var undoManage:UndoManager!
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        //fatalError("init(coder:) has not been implemented")
        super.init(coder: aDecoder)
        setupView()
    }
    
    @objc func setupView() {
        backgroundColor = UIColor.clear
        isOpaque = false
    }
    
    override func draw(_ rect: CGRect) {
        print("draw rect")
//        backgroundColor = UIColor.clearColor()
//        opaque = false
        cache.draw(in: rect)
        path.lineWidth = lineWidth
        path.lineCapStyle = CGLineCap.round
        if eraserMode {
            UIColor.white.setStroke()
            path.stroke(with: CGBlendMode.clear, alpha: 1.0)
        } else {
            lineColor.setStroke()
            path.stroke()
        }
    }
    

    override func touchesBegan(_ touches:  Set<UITouch>, with event: UIEvent?) {
        print("touch")
        ctr = 0
        let touch = touches.first
        pts[0] = touch!.location(in: self)
            
    }
    
    override func touchesMoved(_ touches:  Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        let p = touch!.location(in: self)
        ctr = ctr + 1
        pts[ctr] = p
        if  (ctr == 3) {
            pts[2] = CGPoint(x: (pts[1].x + pts[3].x)/2.0, y: (pts[1].y + pts[3].y)/2.0);
            path.move(to: pts[0])
            path.addQuadCurve(to: pts[2], controlPoint: pts[1])
            setNeedsDisplay()
            pts[0] = pts[2]
            pts[1] = pts[3]
            ctr = 1
        }
    }
    
    override func touchesEnded(_ touches:  Set<UITouch>, with event: UIEvent?) {
        if (ctr == 0)
        {
            //path.addArcWithCenter(pts[0], radius: 1, startAngle: 0, endAngle: CGFloat(M_PI) * 2, clockwise: true)
            let magicNumber = lineWidth / 6
            path = UIBezierPath(roundedRect: CGRect(x: pts[0].x, y: pts[0].y, width: magicNumber, height: magicNumber), cornerRadius: magicNumber / 2)
        }
        else if (ctr == 1)
        {
            path.move(to: pts[0])
            path.addLine(to: pts[1])
        }
        else if (ctr == 2)
        {
            path.move(to: pts[0])
            path.addQuadCurve(to: pts[2], controlPoint: pts[1])
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
    
    override func touchesCancelled(_ touches:  Set<UITouch>, with event: UIEvent?) {
        touchesEnded(touches, with: event)
        
        print("DREW")
    }
    
    @objc func drawBitmap() {
        
        print("Draw Bitmap")
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0.0)
        
        lineColor.setStroke()
        path.lineWidth = lineWidth
        path.lineCapStyle = CGLineCap.round
        if (firstTimeCache) {
            let rectPath = UIBezierPath(rect: bounds)
            UIColor.clear.setFill()
            rectPath.fill()
            firstTimeCache = false
        }
        
        cache.draw(at: CGPoint.zero)
        path.stroke()
        
        cache = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
    }
    
    @objc func eraseBitmap() {
        
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0.0)
        cache.draw(at: CGPoint.zero)
        path.stroke(with: CGBlendMode.clear, alpha: 1.0)
        cache = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
  
    }
    
    @objc func clearBitmap() {
        
        print("CLEAR BITMAP")
        
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0.0)

        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(UIColor.clear.cgColor)
        context?.fill(self.bounds)
        
        cache = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        
        self.setNeedsDisplay()
            
        
    }
    
    
    @objc func renderSticker() -> UIImage?{
        
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, 0.0)
        self.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
  
        clearBitmap()
        
        
      

        return image
        
        
        
    }
    
    
    
    
    
}

@objc protocol PaintToolViewControllerDelegate {
    
    @objc optional func paint_toggleEraser(_ state:Bool)
    
    @objc optional func paint_setSizeUP(_ isPaint:Bool)
    @objc optional func paint_setSizeDown(_ isPaint:Bool)
    @objc optional func paint_setColor(_ color:UIColor)
    @objc optional func paint_setImage(_ img:UIImage)
    
    @objc optional func paint_undo()
    @objc optional func paint_clear()
    @objc optional func paint_dismiss()
    
    @objc optional func paintSelectColor()
    
    @objc optional func paint_popout()
    @objc optional func emoji_popOut()
    
    @objc optional func paintSelectImage()
    
    

}

class PaintToolViewController:UIViewController , CWColorSelectViewControllerDelegate, StickerSelectDelegate, CFInterWebsViewControllerDelegate{
    
    @objc var delegate:PaintToolViewControllerDelegate!
    @objc var eraser:Bool = false
    
    @objc var ibo_vcColorSelect:CWColorSelectViewController!
    
    @objc var ibo_imageSelector:StickerCategoryViewController!
    
    @IBOutlet var ibo_buttonPicker:UIButton!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.view.isUserInteractionEnabled = true
        
    }
    
    @IBAction func iba_popoutPainting(){
    
        delegate.paint_popout?()
        
    }
    
    @IBAction func iba_popOutEmoji(){
        delegate.emoji_popOut!()
    }
    
    @IBAction func iba_toggleEraser(){
        
        if eraser {
            eraser = false
        } else {
            eraser = true
        }
        delegate.paint_toggleEraser?(eraser)
    
    }
    
    @IBAction func iba_changeSizeUP(_ sender:UIButton){
        
        switch sender.tag{
        case 0:
            delegate.paint_setSizeUP?(true)
        case 1:
            delegate.paint_setSizeUP?(false)
        default: break
            //
        }
        
    }
    
    @IBAction func iba_changeSizeDown(_ sender:UIButton){
        
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
    
    @objc func colorSelectChoseColor(_ color:UIColor){
        colorSelectDismiss()
        delegate.paint_setColor?(color)
        
        ibo_buttonPicker.setImage(nil, for: UIControlState())

    
    }
    @objc func colorSelectDismiss(){
        
        ibo_vcColorSelect.view.removeFromSuperview()
        ibo_vcColorSelect.delegate = nil
        ibo_vcColorSelect = nil

    }


    
    @IBAction func tool_stickerSelect(){
        
        delegate.paintSelectImage!()
        
        
        return
        let stickerBored2 = UIStoryboard(name: "StickerSelectStoryboard", bundle: nil)
        ibo_imageSelector = stickerBored2.instantiateViewController(withIdentifier: "sb_StickerCategoryViewController") as! StickerCategoryViewController
        
        ibo_imageSelector.delegate = self
        ibo_imageSelector.view.frame = self.view.frame
        
        self.view.addSubview(ibo_imageSelector.view)
        
    }
    

   

    @IBAction func iba_dismiss(){
        
        delegate.paint_dismiss?()
        
    }
    
    

}
