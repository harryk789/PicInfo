//
//  ViewController.swift
//  ClickAndGetInfo
//
//  Created by Upkesh Thakur on 25/07/18.
//  Copyright © 2018 Upkesh Thakur. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var imageView: UIImageView!
    var imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        tableView.register(UINib(nibName: "PicInfoCell", bundle: nil), forCellReuseIdentifier: "PicInfoCell")
        imageView.contentMode = .scaleToFill;
       
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func action(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePicker.sourceType = .camera;
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func hitAPI(base64:String) {
        /* "{\"nacho\":[\"1\",\"2\",\"3\"]}"*/
        let jsonString = "{\"requests\":[{\"image\":{\"content\":\"\(base64)\"},\"features\":[{\"type\":\"WEB_DETECTION\",\"maxResults\":10}]}]}"
        let jsonData = jsonString.data(using: .utf8)
//        let dictionary = try? JSONSerialization.jsonObject(with: jsonData!, options: .mutableLeaves)
//        print(dictionary!)
        
        var request = URLRequest(url: URL(string: "https://vision.googleapis.com/v1/images:annotate?key=AIzaSyDr5Tj388_5DB94VegVzbc1KGqec5Q9d5A")!)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
//            print(response!)
            do {
                let json = try JSONSerialization.jsonObject(with: data!) as! Dictionary<String, AnyObject>
                let responses = json["responses"] as! NSArray
                let webDetection =  responses.value(forKey: "webDetection") as! NSArray
                let webDetection =  responses.value(forKey: "webDetection") as! NSArray
            } catch {
                print("error")
            }
        })
        
        task.resume()
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 100
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:PicInfoCell = tableView.dequeueReusableCell(withIdentifier: "PicInfoCell") as! PicInfoCell
        cell.lblPicInfo.text = "Value is \(indexPath.row)"
            return cell
    }
}

extension ViewController:  UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        NSLog("\(info)")
        let image = info[UIImagePickerControllerOriginalImage] as? UIImage
        
        print("img ht is \(image?.size.height, image?.scale)")
        
        let hasAlpha = false
        let scale: CGFloat = 0.0
        
        UIGraphicsBeginImageContextWithOptions(imageView.frame.size, !hasAlpha, scale)
        image?.draw(in: CGRect(origin: .zero, size: imageView.frame.size))
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let imageData = UIImagePNGRepresentation(scaledImage!)!
        let base64 = imageData.base64EncodedString(options: Data.Base64EncodingOptions.lineLength64Characters)
        hitAPI(base64: base64)
        imageView.image = scaledImage
        
        
        dismiss(animated: true, completion: nil)
    }
}


