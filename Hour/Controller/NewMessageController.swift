//
//  NewMessageController.swift
//  Hour
//
//  Created by Moses Oh on 3/19/18.
//  Copyright © 2018 Moses Oh. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class NewMessageController: UITableViewController {
    let cellId = "cellId"
    
    var users = [HUser]()
    var selectedUsers = [HUser]()
    
    var messagesController: MessagesController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
//        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Create", style: .plain, target: self, action: #selector(handleCreate))
        tableView.register(GroupCell.self, forCellReuseIdentifier: cellId)
        fetchUser()
    }
    
    func fetchUser() {
        Database.database().reference().child("users").observe(.childAdded) { (snapshot) in
            let user = HUser(snapshot: snapshot)
            self.users.append(user)
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    @objc func handleCancel() {
        dismiss(animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        let user = users[indexPath.row]
        
        
        cell.textLabel?.text = user.name
        cell.detailTextLabel?.text = user.email
        cell.selectionStyle = .none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        
        if cell?.backgroundColor == UIColor(red: 199/255, green:199/255, blue: 205/255, alpha: 1) {
            cell?.backgroundColor = UIColor.clear
            if let index = selectedUsers.index(of: self.users[indexPath.row]) {
                selectedUsers.remove(at: index)
            }
        } else {
            cell?.backgroundColor = UIColor(red: 199/255, green:199/255, blue: 205/255, alpha: 1)
            selectedUsers.append(self.users[indexPath.row])

        }
    }
    
  
}


