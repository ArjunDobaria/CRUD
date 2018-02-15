//
//  SearchViewController.swift
//  CRUD
//
//  Created by lanet on 15/02/18.
//  Copyright © 2018 lanet. All rights reserved.
//

import UIKit
import CoreData

class SearchViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var searchbar: UISearchBar!
    @IBOutlet weak var tblView: UITableView!
    
    var arrayUser : NSMutableArray = NSMutableArray()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var email = ""
    
    var url_string = "http://localhost:8552/"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchbar.delegate = self
        tblView.delegate = self
        tblView.dataSource = self
    }
    
    //MARK:- Search Delegate
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //Search button tap event
        getData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//        getData()
        searchCall()
        tblView.reloadData()
    }
    
    //MARK:- TableView deelegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayUser.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : UITableViewCell = UITableViewCell()
        cell.textLabel?.text = arrayUser[indexPath.row] as? String
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //touch up inside of table view row
    }

    //MARK:- Service call
    
    //CoreData Call
    func getData(){
        arrayUser = []
        let contex = appDelegate.persistentContainer.viewContext
        
        let userEntity = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        
        userEntity.fetchLimit = 5
        userEntity.predicate = NSPredicate.init(format: "email CONTAINS[c] %@", searchbar.text!)
        userEntity.sortDescriptors = [NSSortDescriptor.init(key: "email", ascending: true)]
        
        let user = try! contex.fetch(userEntity)
        
        if((user as NSArray).count != 0){
            for userObj in user{
                let data : User = userObj as! User
                arrayUser.add(data.email!)
            }
            DispatchQueue.main.async {
                self.tblView.reloadData()
            }
        }else{
            print("No data found")
        }
    }
    
    //Node search Call
    func searchCall(){
        arrayUser = []
        let url : URL = URL(string: url_string + "search")!
        let session = URLSession.shared
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let params : [String : Any] = ["email" : searchbar.text!]
        do{request.httpBody = try JSONSerialization.data(withJSONObject: params, options: [])}catch let error as NSError{print(error)}
        let task = session.dataTask(with: request){ (data, response, error) in
            if(error == nil)
            {
                let res = try? JSONSerialization.jsonObject(with: data!, options: [])
                if ((res as! NSDictionary)["msg"] != nil)
                {
                    if(((res as! NSDictionary)["msg"] as! NSArray).count != 0)
                    {
                        for data in ((res as! NSDictionary)["msg"] as! NSArray){
                            self.arrayUser.add((data as! NSDictionary)["email"] as! String)
                        }
                        DispatchQueue.main.async {
                            self.tblView.reloadData()
                        }
                    }
                    else
                    {
                        print("No data found")
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
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print("Memory leaked")
    }
}
