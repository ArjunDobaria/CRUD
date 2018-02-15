//
//  RegisterViewController.swift
//  CRUD
//
//  Created by lanet on 13/02/18.
//  Copyright © 2018 lanet. All rights reserved.
//

import UIKit
import CoreData

class RegisterViewController: UIViewController {

    //MARK:- IBOutlet
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var mobile: UITextField!
    
    var url_string = "http://localhost:8552/"
    
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    //MARK:- Button Actions
    @IBAction func register(_ sender: UIButton) {
        //service call
//        RegisterUser()
        saveData()
//        _ = self.navigationController?.popViewController(animated: true)
    }
    @IBAction func backToLogin(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ViewController") as! ViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    //MARK:- Custome Function
    
    //CoreData
    func saveData(){
        let context = appDelegate?.persistentContainer.viewContext
        let userentity = NSEntityDescription.entity(forEntityName: "User", in: context!)
        let user = NSManagedObject(entity: (userentity)!, insertInto: context)
        
        user.setValue(email.text, forKey: "email")
        user.setValue(password.text, forKey: "password")
        user.setValue(username.text, forKey: "name")
        user.setValue(mobile.text, forKey: "mobilenumber")
//        user.setValue(NSData, forKey: "profilepic")
        
        do{
            try context?.save()
            GotoLogin()
        }catch let error as NSError{
            print("Could not insert data to CoreData due to this error : \(error)")
        }
    }
    
    //service call
    func RegisterUser(){
        let url : URL = URL(string: url_string + "register")!
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
                    if(((res as! NSDictionary)["msg"] as! NSDictionary)["email"] as? String != "")
                    {
                        DispatchQueue.main.async {
                            self.GotoLogin()
                        }
                        
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
    
    func GotoLogin(){
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ViewController") as! ViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
