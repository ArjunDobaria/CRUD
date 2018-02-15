//
//  ViewController.swift
//  CRUD
//
//  Created by lanet on 13/02/18.
//  Copyright © 2018 lanet. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {

    //MARK:- IBOutlet
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    
    var dict : NSDictionary = NSDictionary()
    
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    
    var url_string = "http://localhost:8552/"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    //MARK:- Button Actions
    @IBAction func login(_ sender: UIButton) {
        //service call
//        LoginUser()
        selectData()
    }
    @IBAction func registerLinkbtn(_ sender: UIButton) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    //MARK:- Service call
    
    //call from CoreDate
    func selectData(){
        let context = appDelegate?.persistentContainer.viewContext
        
        let fetchUser = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        
        fetchUser.fetchLimit = 1
        fetchUser.predicate = NSPredicate(format: "email = %@", email.text!)
        fetchUser.sortDescriptors = [NSSortDescriptor.init(key: "email", ascending: true)]
        fetchUser.sortDescriptors = [NSSortDescriptor.init(key: "password", ascending: true)]
        
        let userData = try! context?.fetch(fetchUser)
        if((userData! as NSArray).count != 0){
            let currentUser : User = userData?.first as! User
            
            if(currentUser.email == email.text && currentUser.password == password.text){
                UserDefaults.standard.set(currentUser.email, forKey: "email")
                GotoProfile()
            }
            
            print("Email : " + currentUser.email!)
            print("Password : " + currentUser.password!)
        }else{
            print("You have to register first")
        }
    }
    
    //Call from node
    func LoginUser(){
        let url : URL = URL(string: url_string + "login")!
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
                    self.dict = (res as! NSDictionary)["msg"] as! NSDictionary
                    UserDefaults.standard.set(self.dict, forKey: "user")
                    if(self.dict["email"] as! String != "")
                    {
                        DispatchQueue.main.async {
                            self.GotoProfile()
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
    
    func GotoProfile(){
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

