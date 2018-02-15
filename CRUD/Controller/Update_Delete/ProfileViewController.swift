//
//  ProfileViewController.swift
//  CRUD
//
//  Created by lanet on 13/02/18.
//  Copyright © 2018 lanet. All rights reserved.
//

import UIKit
import CoreData

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate,  UINavigationControllerDelegate {

    //MARK:- IBOutlet
    @IBOutlet weak var profilrPicView: UIImageView!
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var mobile: UITextField!
    @IBOutlet weak var photopicbtn: UIButton!
    
    @IBOutlet weak var containerView: UIView!
    
    var url_string = "http://localhost:8552/"
    var dict : NSDictionary = NSDictionary()
    var imagePicker = UIImagePickerController()
    var pickedImage : UIImage = UIImage()
    
    var imgData = NSData()
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userProfile()
        
//        dict = UserDefaults.standard.object(forKey: "user") as! NSDictionary
//        email.text = dict["email"] as? String
//        password.text = dict["password"] as? String
//        username.text = dict["name"] as? String
//        mobile.text = dict["mobilenumber"] as? String
//        
//        if let url = URL(string: url_string + (dict["profilepic"] as! String)) {
//            profilrPicView.contentMode = .scaleToFill
//            downloadImage(url: url)
//        }
//        
//        
//        profilrPicView.image = UIImage(named: (dict["profilepic"] as? String)!)
        photopicbtn.isUserInteractionEnabled = false
        //Assign value to textboxes
        
        imagePicker.delegate = self
        containerView.isUserInteractionEnabled = false
        email.isUserInteractionEnabled = false
    }

    //MARK:- Button Actions
    @IBAction func editProfile(_ sender: UIButton) {
        editProfile()
    }
    @IBAction func deleteProfile(_ sender: UIButton) {
//        deleteProfile()
        delete()
    }
    @IBAction func selectPhoto(_ sender: UIButton) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        
        present(imagePicker, animated: true, completion: nil)
    }
    @IBAction func backToRoot(_ sender: UIButton) {
       let vc = self.storyboard?.instantiateViewController(withIdentifier: "SearchViewController") as! SearchViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func savePhoto(_ sender: UIButton) {
//        changeProfile()
//        upload()
        saveProfile()
        containerView.isUserInteractionEnabled = false
        photopicbtn.isUserInteractionEnabled = false
    }
    
    //MARK:- ImagePicker Delegate
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }	
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        pickedImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        profilrPicView.contentMode = .scaleToFill
        profilrPicView.image = pickedImage
        imgData = (UIImagePNGRepresentation(profilrPicView.image!)! as NSData)
        dismiss(animated: true, completion: nil)
    }
    
    func editProfile(){
        containerView.isUserInteractionEnabled = true
        photopicbtn.isUserInteractionEnabled = true
    }
    
    //MARK:- Service Calling
    
    //call from CoreData
    func delete(){
        let context = appDelegate.persistentContainer.viewContext
        
        let userFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        
        userFetch.fetchLimit = 1
        userFetch.predicate = NSPredicate.init(format: "email = %@", email.text!)
        let userdata = try! context.fetch(userFetch)
        let data = userdata as! [User]
        
        
//        context.delete(userdata)
        for data1 in data{
            context.delete(data1)
        }
        
        do {
            try context.save()
        }catch let error as NSError
        {
            print("Error \(error)")
        }
    }
    
    func saveProfile(){
        let context = appDelegate.persistentContainer.viewContext
        
        let userFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        
        userFetch.fetchLimit = 1
        userFetch.predicate = NSPredicate.init(format: "email = %@", email.text!)
        userFetch.sortDescriptors = [NSSortDescriptor.init(key: "password", ascending: true)]
        userFetch.sortDescriptors = [NSSortDescriptor.init(key: "name", ascending: true)]
        userFetch.sortDescriptors = [NSSortDescriptor.init(key: "mobilenumber", ascending: true)]
        userFetch.sortDescriptors = [NSSortDescriptor.init(key: "profilepic", ascending: true)]
        
        let userdata = try! context.fetch(userFetch)
        
        let userP : User = userdata.first as! User
        
        userP.password = password.text
        userP.name = username.text
        userP.mobilenumber = mobile.text
        userP.profilepic = imgData as Data
        
        do {
            try context.save()
        }catch let error as NSError
        {
            print("Error \(error)")
        }
    }
    
    func userProfile(){
        let context = appDelegate.persistentContainer.viewContext
        
        let userFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        
        userFetch.fetchLimit = 1
        userFetch.predicate = NSPredicate.init(format: "email = %@", UserDefaults.standard.object(forKey: "email") as! String)
        userFetch.sortDescriptors = [NSSortDescriptor.init(key: "email", ascending: true)]
        userFetch.sortDescriptors = [NSSortDescriptor.init(key: "password", ascending: true)]
        userFetch.sortDescriptors = [NSSortDescriptor.init(key: "name", ascending: true)]
        userFetch.sortDescriptors = [NSSortDescriptor.init(key: "mobilenumber", ascending: true)]
        userFetch.sortDescriptors = [NSSortDescriptor.init(key: "profilepic", ascending: true)]
        
        let userdata = try! context.fetch(userFetch)
        
        let userP : User = userdata.first as! User
        
        email.text = userP.email
        password.text = userP.password
        username.text = userP.name
        mobile.text = userP.mobilenumber
        if(userP.profilepic != nil){
            profilrPicView.image = UIImage(data: (userP.profilepic! as NSData) as Data)
        }
        
    }
    
    //Call from node
    func changeProfile(){
        let url : URL = URL(string: url_string + "update")!
        let session = URLSession.shared
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let params : [String : Any] = ["email" : email.text!,
                                       "password" : password.text!,
                                       "name" : username.text!,
                                       "mobilenumber" : mobile.text!,
                                       "profilepic" : ""
        ]
        do{request.httpBody = try JSONSerialization.data(withJSONObject: params, options: [])}catch let error as NSError{print(error)}
        let task = session.dataTask(with: request){ (data, response, error) in
            if(error == nil)
            {
                let res = try? JSONSerialization.jsonObject(with: data!, options: [])
                if ((res as! NSDictionary)["msg"] != nil)
                {
                    print((res as! NSDictionary)["msg"] as! NSDictionary)
                    DispatchQueue.main.async {
                        self.upload()
                    }
                }
                else{
                    print((res as! NSDictionary)["error"] as! String)
                }
            }
            else
            {
                print(error ?? "Error")
            }
        }
        task.resume()
    }
    
    func deleteProfile(){
        let url : URL = URL(string: url_string + "delete")!
        let session = URLSession.shared
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let params : [String : Any] = ["email" : email.text!,
                                       "password" : password.text!
        ]
        do{request.httpBody = try JSONSerialization.data(withJSONObject: params, options: [])}catch let error as NSError{print(error)}
        let task = session.dataTask(with: request){ (data, response, error) in
            if(error == nil)
            {
                let res = try? JSONSerialization.jsonObject(with: data!, options: [])
                if ((res as! NSDictionary)["msg"] != nil)
                {
                    print((res as! NSDictionary)["msg"] as! NSDictionary)
                    DispatchQueue.main.async {
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "RegisterViewController") as! RegisterViewController
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                }
                else{
                    print((res as! NSDictionary)["error"] as! String)
                }
            }
            else
            {
                print(error ?? "Error")
            }
        }
        task.resume()
    }
    
    func upload() {
        if let image = self.profilrPicView.image {
            let imageData = UIImageJPEGRepresentation(image, 1.0)
            
            let urlString = "http://localhost:8552/api/photo"
            let session = URLSession(configuration: URLSessionConfiguration.default)
            
            let mutableURLRequest = NSMutableURLRequest(url: URL(string: urlString)!)
            
            mutableURLRequest.httpMethod = "POST"
            
            let boundaryConstant = "----------------12345";
            let contentType = "multipart/form-data;boundary=" + boundaryConstant
            mutableURLRequest.setValue(contentType, forHTTPHeaderField: "Content-Type")
            
            // create upload data to send
            let uploadData = NSMutableData()
            
            // add image
            uploadData.append("\r\n--\(boundaryConstant)\r\n".data(using: String.Encoding.utf8)!)
            uploadData.append("Content-Disposition: form-data; name=\"userPhoto\"; filename=\"FromiOS\"\r\n".data(using: String.Encoding.utf8)!)
            uploadData.append("Content-Type: image/png\r\n\r\n".data(using: String.Encoding.utf8)!)
            uploadData.append(imageData!)
            uploadData.append("\r\n--\(boundaryConstant)--\r\n".data(using: String.Encoding.utf8)!)
            
            mutableURLRequest.httpBody = uploadData as Data
            
            
            let task = session.dataTask(with: mutableURLRequest as URLRequest, completionHandler: { (data, response, error) -> Void in
                if error == nil {
                    // Image uploaded
                    let res = try? JSONSerialization.jsonObject(with: data!, options: [])
                    if ((res as! NSDictionary)["msg"] != nil)
                    {
                        print((res as! NSDictionary)["msg"] as! NSDictionary)
                    }
                    else{
                        print((res as! NSDictionary)["error"] as! String)
                    }
                }
            })
            
            task.resume()
            
        }
    }
    
    func getDataFromUrl(url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            completion(data, response, error)
            }.resume()
    }
    
    func downloadImage(url: URL) {
        print("Download Started")
        getDataFromUrl(url: url) { data, response, error in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? url.lastPathComponent)
            print("Download Finished")
            DispatchQueue.main.async() {
                self.profilrPicView.image = UIImage(data: data)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
