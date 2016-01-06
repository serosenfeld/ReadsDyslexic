//
//  ViewController.swift
//  Hackathon 8
//
//  Created by Jay Bisa and Steve and Mansi Sheth and Ryan Davis on 2/6/15.
//  Copyright (c) 2015 Veracode. All rights reserved.
//

import UIKit
import CoreData
import MobileCoreServices

class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    @IBOutlet weak var cameraView: UIImageView!
    @IBOutlet weak var outputDisplay: UIImageView!
    @IBOutlet weak var takePhotoButton: UIButton!
    @IBOutlet weak var uploadingLabel: UILabel!
    
    override func viewDidLoad() {
        sleep(2)
        super.viewDidLoad()
        self.outputDisplay.hidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func takePhoto(sender: AnyObject) {
        if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)) {
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = UIImagePickerControllerSourceType.Camera
            let mediaTypes: [String] = [kUTTypeImage as String]
            picker.mediaTypes = mediaTypes
            picker.allowsEditing = false
            self.presentViewController(picker, animated: true, completion: nil)
        } else {
            NSLog("No Camera.")
            self.sendImage( UIImage(named:"IMG_0355.JPG")! )
        }
    }
    
    @IBAction func selectPhoto(sender: AnyObject) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = false
        picker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        self.presentViewController(picker, animated: true, completion: nil)
    }
    
//    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        
        self.dismissViewControllerAnimated(true, completion: nil)
        picker.dismissViewControllerAnimated(true, completion: nil)

        NSLog("Did Finish Picking")

        if (picker.sourceType == UIImagePickerControllerSourceType.Camera)
        {
            let takenImage: UIImage = info[UIImagePickerControllerOriginalImage] as! UIImage

//            self.dismissViewControllerAnimated(true, completion: nil)
            self.sendImage( takenImage )
        

                
                

//                self.sendImageAlert()

            
//            UIImageWriteToSavedPhotosAlbum(takenImage, nil, nil, nil)
            
//            self.savedImageAlert()


        } else if (picker.sourceType == UIImagePickerControllerSourceType.PhotoLibrary) {
            let selectedImage: UIImage = info[UIImagePickerControllerOriginalImage] as! UIImage
            
            self.sendImage( selectedImage )
            
            self.selectedImageAlert()
            
            self.dismissViewControllerAnimated(true, completion: nil)
        }

    }
    
    func sendImageAlert() {
        let alert:UIAlertView = UIAlertView()
        alert.title = "Image Delivered!"
        alert.message = "Your picture was delivered to the server."
        alert.delegate = self
        alert.addButtonWithTitle("Ok")
        alert.show()
    }
    
    func selectedImageAlert() {
        let alert:UIAlertView = UIAlertView()
        alert.title = "Image Selected"
        alert.message = "Are you sure you want to use this image?"
        alert.delegate = self
        alert.addButtonWithTitle("Yes")
        alert.addButtonWithTitle("No")
        alert.show()
    }
    
    func savedImageAlert() {
        let alert:UIAlertView = UIAlertView()
        alert.title = "Saved!"
        alert.message = "Your picture was saved to Camera Roll."
        alert.delegate = self
        alert.addButtonWithTitle("Ok")
        alert.show()
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    
    
    

    func sendImage( image:UIImage )
    {
        self.takePhotoButton.hidden = true
        
        let imageData = UIImageJPEGRepresentation(image, 100.0)
        if( imageData!.isEqual(nil) )  { return; }
        
        let request = NSMutableURLRequest(URL: NSURL(string:"http://ec2-52-33-247-208.us-west-2.compute.amazonaws.com:5000/save")!)
        var session = NSURLSession.sharedSession()
        
        let boundary = generateBoundaryString()
        
        request.HTTPMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        request.HTTPBody = createBodyWithParameters("file", imageDataKey: imageData!, boundary: boundary, parameters: nil)
        
        var response: NSURLResponse? = nil
        var error: NSError? = nil
        var returnData: NSData?
        do {
            returnData = try NSURLConnection.sendSynchronousRequest(request, returningResponse: &response)
        } catch let error1 as NSError {
            error = error1
            returnData = nil
        }
        
        let returnString = NSString(data: returnData!, encoding: NSUTF8StringEncoding)
        
        print("returnString \(returnString)")
        print(returnData!.length, terminator: "")
        
        self.outputDisplay.image = UIImage(data: returnData!)
        self.outputDisplay.hidden = false
    }
    
    
    func createBodyWithParameters(filePathKey: String?, imageDataKey: NSData, boundary: String, parameters: [String: String]? ) -> NSData
    {
        let body = NSMutableData();
        
        if parameters != nil {
            for (key, value) in parameters! {
                body.appendString("--\(boundary)\r\n")
                body.appendString("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
                body.appendString("\(value)\r\n")
            }
        }
        
        let filename = "upload.jpg"
        let mimetype = "image/jpg"
        
        body.appendString("--\(boundary)\r\n")
        body.appendString("Content-Disposition: form-data; name=\"\(filePathKey!)\"; filename=\"\(filename)\"\r\n")
        body.appendString("Content-Type: \(mimetype)\r\n\r\n")
        body.appendData(imageDataKey)
        body.appendString("\r\n")
        
        body.appendString("--\(boundary)--\r\n")
        
        return body
    }
    
    func generateBoundaryString() -> String {
        return "Boundary-\(NSUUID().UUIDString)"
    }
}


extension NSMutableData {
    
    func appendString(string: String) {
        let data = string.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        appendData(data!)
    }
    
    

}



