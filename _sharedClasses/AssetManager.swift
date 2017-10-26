//
//  AssetManager.swift
//  OKJuxxxxx
//
//  Created by Franky Aguilar on 7/12/15.
//  Copyright (c) 2015 99centbrains. All rights reserved.
//

import Foundation
import UIKit
import Photos
import TAPromotee

class AssetManager:NSObject {
    
    func getAssetsForDir(_ dir:String) -> [String]{
        
        var fileListArray = [String]()
        
        let error:NSError?
        let resourcePath = Bundle.main.resourcePath
        let fileMGR = FileManager.default
                
        let fileList = (try! fileMGR.contentsOfDirectory(atPath: "\(resourcePath! + dir)")) 
        
        if ((error) != nil){
            print("\(error?.localizedDescription)")
        } else {
            fileListArray = fileList
        }
    
        return fileListArray
    }
    
    //Adds full path to asset in array
    func getFullAsset(_ file:String, dir:String) -> String{
        
        var fileListArray = [String]()
        
        let resourcePath = Bundle.main.resourcePath
        
        let newName = "\(resourcePath! + dir + file)"
        
        return newName
        
    
    }


    func saveLocalImage(_ image:UIImage){
        
        let fileName = self.generateName()
        
        print("save \(fileName)")
        
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let docDirectory = paths[0]
        
        let saveDIR = docDirectory + "/Save/"
        
        let fileManager = FileManager.default
        
        do {
            
            try fileManager.createDirectory(atPath: saveDIR, withIntermediateDirectories: true, attributes: nil)
            
            let filepath = saveDIR + fileName
            let pngdata = UIImagePNGRepresentation(image)
            
            try? pngdata?.write(to: URL(fileURLWithPath: filepath), options: [.atomic])
            
        } catch let error as NSError {
                print(error)
        }
        
        

    }
    
    func generateName() -> String {
    
        let date = "\(Date().timeIntervalSince1970 * 1000)"
        return date
        
    }
    
    func deleteSavedImage(_ fileName:String){
        
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let docDirectory = paths[0]
        
        let saveDIR = docDirectory + "/Save/"
        
        let fileManager = FileManager.default
        let filePath = saveDIR + fileName
        
        do {
            
            try fileManager.removeItem(atPath: filePath)
            
        } catch let error as NSError {
            print(error)
        
        }

    }
    
    
    func getSavedImages() -> [String]?{
        
        var images = [String]()
        
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let docDirectory = paths[0]
        let saveDIR = docDirectory + "/Save/"
        
        let fileManager = FileManager.default
    

        do {
            
            let files = try fileManager.contentsOfDirectory(atPath: saveDIR)
            print(saveDIR)
            
            for file in files {
                images.append(saveDIR + file)
            }
            
            return images
        
        } catch let error as NSError {
            
            
            do {
                
                try FileManager.default.createDirectory(atPath: saveDIR, withIntermediateDirectories: false, attributes: nil)
                print("Create DiR")
            
            } catch let error as NSError {
                print(error.localizedDescription);
            }
            
           
            print(error)
        }
        
        return nil
        
    }
    
    
    
    /*





- (NSString *) documentsPathForFileName:(NSString *)name {

NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
NSString *documentsDirectory = [paths objectAtIndex:0];
NSString *hotelDIR = [documentsDirectory stringByAppendingString:@"/MyHotel/"];

return [hotelDIR stringByAppendingPathComponent:name];
}

- (NSString *) hotelDIR {

NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
NSString *documentsDirectory = [paths objectAtIndex:0];
NSString *hotelDIR = [documentsDirectory stringByAppendingString:@"/MyHotel/"];

return hotelDIR;

}

- (NSString *) generateName {

NSString * timestamp = [NSString stringWithFormat:@"%0.f",[[NSDate date] timeIntervalSince1970] * 1000];

return timestamp;

}

*/


}


//class StickerPackManager:NSObject {
//
//
//
//    //This manager is gonna build us some objects, and push them to parse.
//
//
//        func buildSection(json:JSON){
//
//
//            let package = json["bundles"].arrayValue
//            for collection in package {
//
//               // println(collection)
//                
//                
//                var bundle = StickerPackCollection()
//                
//                bundle.bundle_name = collection["bundle_name"].stringValue
//                bundle.bundle_live = collection["bundle_live"].boolValue
//                bundle.bundle_description = collection["description"].stringValue
//                bundle.bundle_id = collection["bundle_id"].stringValue
//                bundle.bundle_hero = collection["bundle_hero"].stringValue
//                
//                
//                //Adds or Updates Author Table
//                self.buildAuthor(bundle)
//                
//                //Builds or Updates Artwork Table
//                buildPacks(collection)
//                
//            }
// 
// 
//    }
//    
//    func buildAuthor(bundle:StickerPackCollection){
//        
//        //println("Add Author")
//        
//        let pClassName = "Collections"
//        
//        var query = PFQuery(className:pClassName)
//        query.whereKey("collectionID", equalTo:bundle.bundle_id!)
//        query.findObjectsInBackgroundWithBlock {
//        
//        (objects: [AnyObject]?, error: NSError?) -> Void in
//        
//            if error != nil{
//                println(error)
//                return
//            }
//            
//            if let objects = objects as? [PFObject] {
//                
//                
//                if (objects.count <= 0){
//                    
//                    //CREATE NEW OBJECT
//                    let obj = PFObject(className: pClassName)
//                    
//                    obj["isLive"] = bundle.bundle_live
//                    obj["name"] = bundle.bundle_name
//                    obj["collectionID"] = bundle.bundle_id
//                    obj["description"] = bundle.bundle_description
//                    
//                   // obj[""] = bundle.bundle_hero
//
//                    obj.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
//                        //println("Saved")
//                    }
//               
//                }
//                
//                for object in objects {
//                    
//                    var query = PFQuery(className:pClassName)
//                    query.getObjectInBackgroundWithId(object.objectId!) {
//                        (obj: PFObject?, error: NSError?) -> Void in
//                        if error != nil {
//                            println(error)
//                        } else if let obj = obj {
//                            
//                            obj["isLive"] = bundle.bundle_live
//                            obj["name"] = bundle.bundle_name
//                            obj["collectionID"] = bundle.bundle_id
//                            obj["description"] = bundle.bundle_description
//                            obj.saveInBackgroundWithBlock{ (success: Bool, error: NSError?) -> Void in
//                               // println("Updated")
//                            }
//                        }
//                    }
//                    
//                }
//            
//        }
//        }
//        
//        
//    }
//    
//    
//    func buildPacks(packs:JSON){
//        
//        //Parent Collection ID for the contained PACKS
//        let bndleID = packs["bundle_id"].stringValue
//
//        
//        var query = PFQuery(className:"Collections")
//        query.whereKey("collectionID", equalTo:bndleID)
//        
//        query.findObjectsInBackgroundWithBlock {
//            
//            (objects: [AnyObject]?, error: NSError?) -> Void in
//            
//            if error == nil {
//                
//                if let objects = objects as? [PFObject] {
//                    for object in objects {
//                        
//                       // println(objects.count)
//                        
//                        //Parent ID doesnt exists, you gonna break something...
//                        if objects.count <= 0 {
//                           // println("PARENT ENTRY DOES NOT EXIST FOR BUNDLE ID")
//                            return
//                        }
//                        
//                        
//                        for pack in packs["bundle_packs"].arrayValue{
//                            
//                            //BUILD PACK CLASS/ENTRIES
//                            var stckrPack = StickerPack()
//                            stckrPack.pack_name = pack["pack_name"].stringValue
//                            stckrPack.pack_artist = pack["pack_artist"].stringValue
//                            stckrPack.pack_description = pack["pack_description"].stringValue
//                            stckrPack.pack_id = pack["pack_id"].stringValue
//                            stckrPack.pack_dir = pack["pack_path"].stringValue
//                            stckrPack.pack_live = pack["pack_live"].boolValue
//                            stckrPack.pack_free = pack["pack_free"].boolValue
//                            
//                            stckrPack.pack_parent = object
//                            
//                            
//                            
//                            self.uploadStickersToParse(stckrPack)
//                        
//                        }
//                        
//                    }
//                    
//                }
//                
//            }
//            
//        }
//
//    }
//    
//
//    func uploadStickersToParse(pack:StickerPack) {
//        
//        var query = PFQuery(className:"Packs")
//        query.whereKey("pack_id", equalTo:pack.pack_id!)
//        
//        query.findObjectsInBackgroundWithBlock {
//            
//            (objects: [AnyObject]?, error: NSError?) -> Void in
//            
//            if let objects = objects as? [PFObject] {
//                //println(objects.count)
//                
//                //MAKE NEW ENTRY
//                if objects.count <= 0 {
//                    
//                    pack.pack_parent.fetchIfNeededInBackgroundWithBlock {
//                        
//                        (bundle: PFObject?, error: NSError?) -> Void in
//                        
//                        let obj = PFObject(className: "Packs")
//                        obj["name"] = pack.pack_name
//                        obj["artist"] = pack.pack_artist
//                        obj["pack_id"] = pack.pack_id
//                        obj["pack_live"] = pack.pack_live
//                        obj["pack_free"] = pack.pack_free
//                        obj["order"] = 0
//                        obj["pack_description"] = pack.pack_description
//                        obj["parent"] = PFObject(withoutDataWithClassName: "Collections", objectId: bundle!.objectId!)
//                        
//                        obj.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
//                            println("Added New Pack")
//                            
//                            let assets = AssetObject()
//                            assets.parent = obj
//                            assets.asset_dir = pack.pack_dir
//                            self.uploadAssets(assets)
//                            
//                            
//                        }
//                        
//                    }
//                
//
//                } else {
//                    
//                    //UPDATE THE ENTRY
//                    for object in objects {
//                        
//                        var query = PFQuery(className:"Packs")
//                        query.getObjectInBackgroundWithId(object.objectId!) {
//                            (obj: PFObject?, error: NSError?) -> Void in
//                            
//                            if error != nil {
//                                
//                                println(error)
//                                
//                            } else if let obj = obj {
//                                
//                                obj["name"] = pack.pack_name
//                                obj["artist"] = pack.pack_artist
//                                obj["pack_id"] = pack.pack_id
//                                obj["pack_live"] = pack.pack_live
//                                obj["pack_free"] = pack.pack_free
//                                obj["order"] = 0
//                                obj["pack_description"] = pack.pack_description
//                                obj.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
//                                    println("Pack Updated") }
//                            }
//                        }
//                        
//                    }//ENDFOR
//                    
//                    
//                } // END ELSE
//                
//                
//                
//            } // END IF OBJECTS
//            
//        }
//    
//    }
//    
//    func uploadAssets(asset:AssetObject) {
//
//        
//        asset.parent.fetchIfNeededInBackgroundWithBlock {
//            
//            (bundle: PFObject?, error: NSError?) -> Void in
//            
//            
//            let images = AssetManager().getAssetsForDir(asset.asset_dir!)
//            
//                for image in images {
//
//                    let imageData = UIImagePNGRepresentation(UIImage(named: AssetManager().getFullAsset(image, dir: asset.asset_dir!)))
//
//                    let image = PFFile(name: image, data: imageData)
//                    let obj = PFObject(className: "Assets")
//
//                    obj["image"] = image
//                    obj["tags"] = ["Stickers", "Transparent"]
//                    obj["parent"] = PFObject(withoutDataWithClassName: "Packs", objectId: asset.parent!.objectId!)
//                    
//                        obj.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
//                            println("Asset has been saved.")
//                        }
//                    
//                    }
//            
//        }
//        
//        
//
//    
//    }
//    
//}

class StickerPackCollection:NSObject {
    
    var bundle_live:Bool?
    var bundle_name:String?
    var bundle_id:String?
    var bundle_source:String?
    var bundle_description:String?
    var bundle_hero:String?

}

class StickerPack:NSObject {
    
    var pack_live:Bool?
    var pack_free:Bool?
    var pack_type:String?
    var pack_dir:String?
    var pack_id:String?
    var pack_name:String?
    var pack_artist:String?
    //var pack_parent:PFObject!
    var pack_description:String?
    
}


class AssetObject:NSObject {
    
    //var parent:PFObject!
    
    var asset_dir:String?
    var asset_parentID:String?
    var asset_type:String?
    var asset_tags:String?
    
    }



struct kAlbum {
    
    static let albumName = "cybrfm ☹"
    
    static let kSettings = "Settings"
    static let kStickers = "Imports"
}


class PhotoSaver {
    
    
    func saveAssetToAlbum(_ img:UIImage, completion:@escaping ()->Void){
        
        //BLOCK TO MAKE ALBUM IF HASNT BEEN MADE
        self.checkAlbumMakeAlbum { () -> Void in
            
            PHPhotoLibrary.shared().performChanges({
                let collection = self.getCustomAlbum()
                
                let assetRequest = PHAssetChangeRequest.creationRequestForAsset(from: img)
                let placeholder = assetRequest.placeholderForCreatedAsset
                let video = PHAsset.fetchAssets(in: collection!, options: nil)
                let albumChangeRequest = PHAssetCollectionChangeRequest(for: self.getCustomAlbum()!, assets: video)
                albumChangeRequest!.addAssets([placeholder!])
                
                }, completionHandler: { success, error in
                    
                    print("added image to album")
                    print(error)
                    
                    completion()
                    
            })
            
        }
        
    }
    
    func checkAlbumMakeAlbum(_ complete:@escaping () -> Void){
        
        if self.getCustomAlbum() == nil {
            
            PHPhotoLibrary.shared().performChanges({ () -> Void in
                
                PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: kAlbum.albumName)
                
            }) { (done:Bool, err:NSError?) -> Void in
                
                complete()
            } as! (Bool, Error?) -> Void as! (Bool, Error?) -> Void as! (Bool, Error?) -> Void as! (Bool, Error?) -> Void as! (Bool, Error?) -> Void as! (Bool, Error?) -> Void as! (Bool, Error?) -> Void
            
        } else {
            complete()
        }
        
    }
    
    func getCustomAlbum() -> PHAssetCollection?{
        
        let assetCollections = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .albumRegular, options: nil)
        for i in 0  ..< assetCollections.count  {
            
            let assetCollection = assetCollections[i] as? PHAssetCollection
            if assetCollection?.localizedTitle == kAlbum.albumName {
                return assetCollection!
            }
            
        }
        
        return nil
        
        
    }
    
}

class DocumentManager {
    
    
    func clearDirectory(_ dir:String){
        
        let fileManager = FileManager.default
        let fullDiretory = self.getDocumentsDirectory(dir)
        
        do {
            
            let files = try fileManager.contentsOfDirectory(atPath: fullDiretory as String)
            
            for f in files {
                let fullasset = self.getFullAssetName(dir, file: f)
                print(fullasset)
                do {
                    try fileManager.removeItem(atPath: fullasset)
                }
            }
  
        } catch {
            
        }
        
    }
    
    func saveImage(_ image:UIImage, directory:String){
        
        checkDocFolder(directory)
        
        if let data = UIImagePNGRepresentation(image) {
            
            let filename = getDocumentsDirectory(directory).appendingPathComponent("\(generateName()).png")
            try? data.write(to: URL(fileURLWithPath: filename), options: [.atomic])
            
            print("saved")
            
        }
    }
    
    
    func getDocumentsDirectory(_ dir:String) -> NSString {
        
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0] + "/\(dir)"
        return documentsDirectory as NSString
        
    }
    
    func checkDocFolder(_ dir:String){
        
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        let documentsDirectory: AnyObject = paths[0] as AnyObject
        let dataPath = documentsDirectory.appendingPathComponent(dir)
        
        print(dataPath)
        do {
            try FileManager.default.createDirectory(atPath: dataPath, withIntermediateDirectories: false, attributes: nil)
        } catch let error as NSError {
            print(error.localizedDescription);
        }
        
    }
    
    func generateName() -> String{
         return  "\(Date().timeIntervalSince1970 * 1000)"
    }
    
    
    func getFullAssetName(_ dir:String, file:String) -> String {
        
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0] + "/\(dir)"
        return documentsDirectory + "/\(file)"
    }
    
    func getSavedImages(_ dir:String) -> [String]{
        
        self.checkDocFolder(dir)
        
        let fileManager = FileManager.default
        
        do {
            
            let files = try fileManager.contentsOfDirectory(atPath: self.getDocumentsDirectory(dir) as String)
            
            return files
   
        } catch {
            
        }
        
        return [""]
        
    }
    
}


class CrossPromoManager {
    
    
    
    func retrievePromoIDS(_ vc:UIViewController){
        
        
        let formatter = DateFormatter()
        formatter.dateStyle = DateFormatter.Style.short
        formatter.timeStyle = .none
        
        let dateString = formatter.string(from: Date())
        print(dateString)
        
        let linksurl = "http://labz.99centbrains.com/cybrfm/cybr_popups.plist"
        let links = NSArray(contentsOf: URL(string:linksurl)!)
        
        
        
        for link in links!  {
            let promoID = link["id"] as! String
            let message = link["message"] as! String
            let date = link["date"] as! String
            
           
            let daysBetweenNowAndPromoDate = Date().timeIntervalSince(formatter.date(from: date)!) / -86400.0
            
            if (daysBetweenNowAndPromoDate < 0){
                return
            }
            
          
            
//            let l = link as! [AnyObject:AnyObject]
            
            //print(l)
            
            if UserDefaults.standard.bool(forKey: "\(promoID)\(date)") == false {
    
    
                self.showPromoId(date, id:Int(promoID)!, message: message, inVC: vc)
    
            }
            
            
            
            
        }
        

    
    }
    
    func showPromoId(_ date:String, id:Int, message:String, inVC:UIViewController){
        
        
        
            TAPromotee.show(from: inVC, appId: id, caption: message) { (action:TAPromoteeUserAction) in
                
                print(action)
                
                if action == TAPromoteeUserAction.didClose {
                    print("DID CLOSE")
                    
                } else if action == TAPromoteeUserAction.didInstall {
                    
                    print("DID INSTALL")
                    UserDefaults.standard.set(true, forKey: "\(id)\(date)")
                    
                }
            }
            
        
        //
        
    }

}


