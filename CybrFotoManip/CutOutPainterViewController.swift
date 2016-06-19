//
//  CutOutPainterViewController.swift
//  CybrFotoManip
//
//  Created by Franky Aguilar on 4/9/16.
//  Copyright © 2016 99centbrains. All rights reserved.
//

import Foundation
import UIKit

protocol CutOutPainterDelegate {
    func cutOutDidFinish(img:UIImage, vc:CutOutPainter)
}

class CutOutPainter:UIViewController , UIScrollViewDelegate{
    
    var ibo_drawingView = SwiftEraseView()
    var delegate:CutOutPainterDelegate!
    @IBOutlet weak var ibo_scrollview:UIScrollView!
    
    @IBOutlet weak var ibo_zoombtn:UIButton!
    @IBOutlet weak var ibo_erasebtn:UIButton!
    

    var paintedImage:UIImage!

    override func viewDidLoad() {
        super.viewDidLoad()
        ibo_scrollview.maximumZoomScale = 3.0
        ibo_scrollview.delegate = self
        ibo_scrollview.scrollEnabled = false
        
        ibo_drawingView.userInteractionEnabled = true
        ibo_erasebtn.alpha = 0.5
    }
    
    @IBAction func iba_undo(){
        
        ibo_drawingView.undoDraw()
    
    }
    
    @IBAction func iba_dmiss(){
    
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
    func scrollViewWillBeginZooming(scrollView: UIScrollView, withView view: UIView?) {
        
        
    }
    func scrollViewDidEndZooming(scrollView: UIScrollView, withView view: UIView?, atScale scale: CGFloat) {
     
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return ibo_drawingView
    }
    
    @IBAction func iba_increaseBrush(){
        ibo_drawingView.lineWidth += 10
        self.paintSizeAnimate(ibo_drawingView.lineWidth)
    }
    
    @IBAction func iba_decrease(){
        
        ibo_drawingView.lineWidth -= 10
        self.paintSizeAnimate(ibo_drawingView.lineWidth)
    
    }
    
    func paintSizeAnimate(size:CGFloat){
        
       
        
        let sampleView = UIImageView(frame: CGRectMake(0, 0, size, size))
        sampleView.center = self.view.center
        
        sampleView.backgroundColor = ibo_drawingView.lineColor
        sampleView.layer.cornerRadius = size/2
        sampleView.layer.borderColor = UIColor.blackColor().CGColor
        sampleView.layer.borderWidth = 2.0
        
        
        self.view.addSubview(sampleView)
        
        
        UIView.animateWithDuration(0.5, delay: 0.0, options: .CurveEaseOut, animations: {
            
            sampleView.alpha = 0
            
            }, completion: { finished in
                
                sampleView.removeFromSuperview()
                
        })
        
        
    }

    
    @IBAction func iba_toggleScrollBox(sender:UIButton){
        
        if sender.tag == 0 {
            
            ibo_zoombtn.alpha = 1
            ibo_erasebtn.alpha = 0.5
            
            ibo_scrollview.scrollEnabled = false
            ibo_drawingView.userInteractionEnabled = true
        
        } else if sender.tag == 1{
            
            ibo_zoombtn.alpha = 0.5
            ibo_erasebtn.alpha = 1
            
            ibo_scrollview.scrollEnabled = true
            ibo_drawingView.userInteractionEnabled = false
            
        }
        
      
        
    
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
         self.view.backgroundColor = UIColor(patternImage: UIImage(named: "ui_cropview_checkers")!)
        //ibo_imagePainted.image = paintedImage
        
        
        var imageSize:CGSize
        //portrait
        if paintedImage.size.width < paintedImage.size.height {
            
            imageSize = CGSizeMake(
                paintedImage.size.width/paintedImage.size.height *
                                    self.ibo_scrollview.frame.size.height,
                                    self.ibo_scrollview.frame.size.height
            )
            
           
            
            
        } else {
            
            imageSize = CGSizeMake(self.ibo_scrollview.frame.size.width,
                                   paintedImage.size.height/paintedImage.size.width * self.ibo_scrollview.frame.size.width)
        }
        
        print("IMAGE SIZE \(imageSize)")
        
       
        ibo_drawingView.lineWidth = 20.0
        ibo_drawingView.eraserMode = true
        ibo_drawingView.contentScaleFactor = 2.0
        ibo_drawingView.vc = self
        ibo_drawingView.userInteractionEnabled = true
        ibo_drawingView.frame = CGRectMake(0, 0, imageSize.width, imageSize.height)
        ibo_drawingView.center = CGPointMake(ibo_scrollview.frame.size.width / 2, ibo_scrollview.frame.size.height / 2)
        ibo_drawingView.fillBitmap(paintedImage)
        self.ibo_scrollview.addSubview(ibo_drawingView)
        ibo_scrollview.contentSize = imageSize
        
       // ibo_drawingView.backgroundColor = UIColor(patternImage: paintedImage)

    }
    
    func drawingMask(cache:UIImage){
        
        
//self.ibo_imagePainted.image =
        //self.ibo_imagePainted.image = cache
    }
    
    func maskImage(image:UIImage, mask:(UIImage))->UIImage{
        
        let imageReference = image.CGImage
        let maskReference = mask.CGImage
        let imageMask = CGImageMaskCreate(CGImageGetWidth(maskReference),
                                          CGImageGetHeight(maskReference),
                                          CGImageGetBitsPerComponent(maskReference),
                                          CGImageGetBitsPerPixel(maskReference),
                                          CGImageGetBytesPerRow(maskReference),
                                          CGImageGetDataProvider(maskReference), nil, true)
        
        let maskedReference = CGImageCreateWithMask(imageReference, imageMask)
        let maskedImage = UIImage(CGImage:maskedReference!)
        return maskedImage
        
    }
    
    @IBAction func iba_done(){
        
        delegate.cutOutDidFinish(ibo_drawingView.cache, vc: self)
    }
    
}


class SwiftEraseView: UIView {
    
    private var firstTimeCache = true
    private var path = UIBezierPath()
    private var cache = UIImage()
    
    private var pts = [CGPointZero, CGPointZero, CGPointZero, CGPointZero]
    private var ctr: Int!
    
    var lineWidth: CGFloat = 2.0
    var lineColor = UIColor.blackColor()
    var eraserMode = false
    
    var states = [UIImage]()
    
    var vc:CutOutPainter!
    
    var undoManage:NSUndoManager!
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        //fatalError("init(coder:) has not been implemented")
        super.init(coder: aDecoder)
    }
    
    func setupView() {
        backgroundColor = UIColor.clearColor()
        opaque = false
    }
    
    
    func fillBitmap(img:UIImage){
        
        
        print("Draw Bitmap")
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0)
        
        
        if (firstTimeCache) {
            let fixedImage = img
            fixedImage.drawInRect(CGRectMake(0, 0, bounds.width, bounds.height))
            firstTimeCache = false
        }
        
        
        cache = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        print("ADD IMAGE")
        
        states.append(cache)
        
        
        
    }
    
    override func drawRect(rect: CGRect) {
        
       
        print("draw rect")
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
        
        if self.userInteractionEnabled == false {
            return
        }
        
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
    
    
    func imageFixBoundingBox(image:UIImage) -> UIImage{
        
        var height:CGFloat
        var width:CGFloat
        
        
        
        height = image.size.height
        width = image.size.width
        
        let rect = CGRectMake(0, 0, self.bounds.size.width,  self.bounds.size.width)
        
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
        
        let context = UIGraphicsGetCurrentContext()
        CGContextTranslateCTM(context, 0, rect.size.height)
        CGContextScaleCTM(context, 1.0, -1.0)
        
        
        let lowerImage = CGRectMake((rect.size.width - width) / 2.0, (rect.size.height - height) / 2.0,
                                    width,
                                    height)
        
        CGContextSetBlendMode(context, .Normal);
        CGContextDrawImage(context, lowerImage, image.CGImage);
        
        
        let final:UIImage = UIGraphicsGetImageFromCurrentImageContext();
        
        return final
        
    }
    
    func drawBitmap() {
        
        print("Draw Bitmap")
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0.0)
        
        path.lineWidth = lineWidth
        path.lineCapStyle = CGLineCap.Round
        
        
    
        if (firstTimeCache) {
            let rectPath = UIBezierPath(rect: bounds)
            UIColor.clearColor().setFill()
            rectPath.fill()
            firstTimeCache = false
        }
        
        cache.drawAtPoint(CGPointZero)
        path.strokeWithBlendMode(CGBlendMode.Normal, alpha: 1.0)
        
        cache = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        

    }
    
    func eraseBitmap() {
        
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0)
        cache.drawAtPoint(CGPointZero)
        path.strokeWithBlendMode(CGBlendMode.Clear, alpha: 1.0)
        cache = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        states.append(cache)
        
    }
    
    func undoDraw(){
        
        
    
        
        states.removeLast()
        let index = states.count
        if index == 0 {
            return
        }
        cache = states[index - 1]
        
        
        print("Draw Bitmap")
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0)
        
        
        cache.drawInRect(CGRectMake(0, 0, bounds.width, bounds.height))
        cache = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        self.setNeedsDisplay()

        
        //cache.drawAtPoint(CGPointZero)
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