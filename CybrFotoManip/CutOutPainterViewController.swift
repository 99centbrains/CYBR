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
    func cutOutDidFinish(_ img:UIImage, vc:CutOutPainter)
}

class CutOutPainter:UIViewController , UIScrollViewDelegate{
    
    @objc var ibo_drawingView = SwiftEraseView()
    var delegate:CutOutPainterDelegate!
    @IBOutlet weak var ibo_scrollview:UIScrollView!
    
    @IBOutlet weak var ibo_zoombtn:UIButton!
    @IBOutlet weak var ibo_erasebtn:UIButton!
    

    @objc var paintedImage:UIImage!

    override func viewDidLoad() {
        super.viewDidLoad()
        ibo_scrollview.minimumZoomScale = 0.5
        ibo_scrollview.maximumZoomScale = 3.0
        ibo_scrollview.delegate = self
        ibo_scrollview.isScrollEnabled = false
        
        ibo_drawingView.isUserInteractionEnabled = true
        ibo_erasebtn.alpha = 0.5
    }
    
    @IBAction func iba_undo(){
        
        ibo_drawingView.undoDraw()
    
    }
    
    @IBAction func iba_dmiss(){
    
        self.dismiss(animated: true, completion: nil)
        
    }
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        
        
    }
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
     
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
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
    
    @objc func paintSizeAnimate(_ size:CGFloat){
        
       
        
        let sampleView = UIImageView(frame: CGRect(x: 0, y: 0, width: size, height: size))
        sampleView.center = self.view.center
        
        sampleView.backgroundColor = ibo_drawingView.lineColor
        sampleView.layer.cornerRadius = size/2
        sampleView.layer.borderColor = UIColor.black.cgColor
        sampleView.layer.borderWidth = 2.0
        
        
        self.view.addSubview(sampleView)
        
        
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseOut, animations: {
            
            sampleView.alpha = 0
            
            }, completion: { finished in
                
                sampleView.removeFromSuperview()
                
        })
        
        
    }

    
    @IBAction func iba_toggleScrollBox(_ sender:UIButton){
        
        if sender.tag == 0 {
            
            ibo_zoombtn.alpha = 1
            ibo_erasebtn.alpha = 0.5
            
            ibo_scrollview.isScrollEnabled = false
            ibo_drawingView.isUserInteractionEnabled = true
        
        } else if sender.tag == 1{
            
            ibo_zoombtn.alpha = 0.5
            ibo_erasebtn.alpha = 1
            
            ibo_scrollview.isScrollEnabled = true
            ibo_drawingView.isUserInteractionEnabled = false
            
        }
        
      
        
    
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
         self.view.backgroundColor = UIColor(patternImage: UIImage(named: "ui_cropview_checkers")!)
        //ibo_imagePainted.image = paintedImage
        
        
        var imageSize:CGSize
        //portrait
        if paintedImage.size.width < paintedImage.size.height {
            
            imageSize = CGSize(
                width: paintedImage.size.width/paintedImage.size.height *
                                    self.ibo_scrollview.frame.size.height,
                                    height: self.ibo_scrollview.frame.size.height
            )
            
           
            
            
        } else {
            
            imageSize = CGSize(width: self.ibo_scrollview.frame.size.width,
                                   height: paintedImage.size.height/paintedImage.size.width * self.ibo_scrollview.frame.size.width)
        }
        
        print("IMAGE SIZE \(imageSize)")
        
       
        ibo_drawingView.lineWidth = 20.0
        ibo_drawingView.eraserMode = true
        ibo_drawingView.contentScaleFactor = 2.0
        ibo_drawingView.vc = self
        ibo_drawingView.isUserInteractionEnabled = true
        ibo_drawingView.frame = CGRect(x: 0, y: 0, width: imageSize.width - 20, height: imageSize.height - 20)
        ibo_drawingView.center = CGPoint(x: ibo_scrollview.frame.size.width / 2, y: ibo_scrollview.frame.size.height / 2)
        ibo_drawingView.fillBitmap(paintedImage)
        self.ibo_scrollview.addSubview(ibo_drawingView)
        ibo_scrollview.contentSize = imageSize
        
       // ibo_drawingView.backgroundColor = UIColor(patternImage: paintedImage)

    }
    
    @objc func drawingMask(_ cache:UIImage){
        
        
//self.ibo_imagePainted.image =
        //self.ibo_imagePainted.image = cache
    }
    
    @objc func maskImage(_ image:UIImage, mask:(UIImage))->UIImage{
        
        let imageReference = image.cgImage
        let maskReference = mask.cgImage
        let imageMask = CGImage(maskWidth: (maskReference?.width)!,
                                          height: (maskReference?.height)!,
                                          bitsPerComponent: (maskReference?.bitsPerComponent)!,
                                          bitsPerPixel: (maskReference?.bitsPerPixel)!,
                                          bytesPerRow: (maskReference?.bytesPerRow)!,
                                          provider: (maskReference?.dataProvider!)!, decode: nil, shouldInterpolate: true)
        
        let maskedReference = imageReference?.masking(imageMask!)
        let maskedImage = UIImage(cgImage:maskedReference!)
        return maskedImage
        
    }
    
    @IBAction func iba_done(){
        
        delegate.cutOutDidFinish(ibo_drawingView.cache, vc: self)
    }
    
}


class SwiftEraseView: UIView {
    
    fileprivate var firstTimeCache = true
    fileprivate var path = UIBezierPath()
    fileprivate var cache = UIImage()
    
    fileprivate var pts = [CGPoint.zero, CGPoint.zero, CGPoint.zero, CGPoint.zero]
    fileprivate var ctr: Int!
    
    @objc var lineWidth: CGFloat = 2.0
    @objc var lineColor = UIColor.black
    @objc var eraserMode = false
    
    @objc var states = [UIImage]()
    
    @objc var vc:CutOutPainter!
    
    @objc var undoManage:UndoManager!
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        //fatalError("init(coder:) has not been implemented")
        super.init(coder: aDecoder)
    }
    
    @objc func setupView() {
        backgroundColor = UIColor.clear
        isOpaque = false
    }
    
    
    @objc func fillBitmap(_ img:UIImage){
        
        
        print("Draw Bitmap")
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0)
        
        
        if (firstTimeCache) {
            let fixedImage = img
            fixedImage.draw(in: CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height))
            firstTimeCache = false
        }
        
        
        cache = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        print("ADD IMAGE")
        
        states.append(cache)
        
        
        
    }
    
    override func draw(_ rect: CGRect) {
        
       
        print("draw rect")
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
        
        if self.isUserInteractionEnabled == false {
            return
        }
        
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
    
    
    @objc func imageFixBoundingBox(_ image:UIImage) -> UIImage{
        
        var height:CGFloat
        var width:CGFloat
        
        
        
        height = image.size.height
        width = image.size.width
        
        let rect = CGRect(x: 0, y: 0, width: self.bounds.size.width,  height: self.bounds.size.width)
        
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
        
        let context = UIGraphicsGetCurrentContext()
        context?.translateBy(x: 0, y: rect.size.height)
        context?.scaleBy(x: 1.0, y: -1.0)
        
        
        let lowerImage = CGRect(x: (rect.size.width - width) / 2.0, y: (rect.size.height - height) / 2.0,
                                    width: width,
                                    height: height)
        
        context?.setBlendMode(.normal);
        context?.draw(image.cgImage!, in: lowerImage);
        
        
        let final:UIImage = UIGraphicsGetImageFromCurrentImageContext()!;
        
        return final
        
    }
    
    @objc func drawBitmap() {
        
        print("Draw Bitmap")
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0.0)
        
        path.lineWidth = lineWidth
        path.lineCapStyle = CGLineCap.round
        
        
    
        if (firstTimeCache) {
            let rectPath = UIBezierPath(rect: bounds)
            UIColor.clear.setFill()
            rectPath.fill()
            firstTimeCache = false
        }
        
        cache.draw(at: CGPoint.zero)
        path.stroke(with: CGBlendMode.normal, alpha: 1.0)
        
        cache = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        

    }
    
    @objc func eraseBitmap() {
        
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0)
        cache.draw(at: CGPoint.zero)
        path.stroke(with: CGBlendMode.clear, alpha: 1.0)
        cache = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        states.append(cache)
        
    }
    
    @objc func undoDraw(){
        
        
    
        
        states.removeLast()
        let index = states.count
        if index == 0 {
            return
        }
        cache = states[index - 1]
        
        
        print("Draw Bitmap")
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0)
        
        
        cache.draw(in: CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height))
        cache = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        self.setNeedsDisplay()

        
        //cache.drawAtPoint(CGPointZero)
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
    
    
    
    
    
}
