//
//  MessageController.swift
//  Hour
//
//  Created by Moses Oh on 2/28/18.
//  Copyright © 2018 Moses Oh. All rights reserved.
//

import UIKit
import Firebase

class MessagesController: UITableViewController {
    
    var messages = [Message]()
    var messagesDictionary = [String: Message]()
    var groups = [Group]()
    var groupsUid = [String]()
    
    let cellId = "cellId"
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        print("MessagesController loaded")
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
//        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "New", style: .plain, target: self, action: #selector(handleNewMessage))
//        navigationItem.rightBarButtonItem?.tintColor = UIColor.white
        
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
        observeUserMessages()
    }
    var timer: Timer?
    
    func observeUserMessages(){
        groups.removeAll()
        groupsUid.removeAll()
        guard let uid = Auth.auth().currentUser?.uid else{
            return
        }
        
        let reff = Database.database().reference().child("users").child(uid).child("groups")
        reff.observe(.value) { (snap) in
            let total = Int(snap.childrenCount)
            reff.observe(.childAdded) { (snapshot) in
                let groupRef = Database.database().reference().child("groups").child(snapshot.key)
                groupRef.observeSingleEvent(of: .value) { (_snapshot) in
                    if let dictionary = _snapshot.value as? [String: AnyObject] {
                        self.groups.append(Group(uid: snapshot.key, groupName: dictionary["name"] as? String, lastMessage: dictionary["last message"] as? String, timestamp: dictionary["timestamp"] as? Double))
                        self.groupsUid.append(snapshot.key)
                        if(self.groups.count == total)
                        {
                            self.attemptReloadOfTable()
                            for group in self.groups {
                                let groupRef = Database.database().reference().child("groups").child(group.uid!)
                                groupRef.observe(.childChanged, with: { (_snapshot) in
                                    print("ChildChanged")
                                    
                                    if let dictionary = _snapshot.value as? [String: AnyObject] {
                                        let index : Int = self.groupsUid.index(of: _snapshot.key)!
                                        self.groups[index].groupName = dictionary["name"] as? String
                                        self.groups[index].lastMessage = dictionary["last message"] as? String
                                        self.groups[index].timestamp = dictionary["timestamp"] as? Double
                                        self.tableView.reloadData()
                                    }
                                })
                            }
                        }
                    }
                }
            }
        }
        
        
    }
    
    private func attemptReloadOfTable() {
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target:self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
    }

    @objc func handleReloadTable() {
        self.tableView.reloadData()
    }
    
    @objc func handleNewMessage() {
        let newMessageController = NewMessageController()
        newMessageController.messagesController = self
        let navController = UINavigationController(rootViewController: newMessageController)
        present(navController, animated: true, completion: nil)
    }
    
    func createChat(_ users: [HUser], name: String) {
        print("creating chat")
        let chatLogController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        
        chatLogController.hidesBottomBarWhenPushed = true
        
        let groupsRef = Database.database().reference().child("groups")
        let groupKey = groupsRef.childByAutoId()
        var groupUsers = [String: Any]()
        for user in users {
            groupUsers[user.uid!] = true
        }
        let groupsChildValues = ["name":name,"users": groupUsers] as [String : Any]
        groupsRef.updateChildValues([groupKey.key : groupsChildValues])
        
    Database.database().reference().child("users").child((Auth.auth().currentUser?.uid)!).child("groups").updateChildValues([groupKey.key : true])
        for user in users {
            let userRef = Database.database().reference().child("users").child(user.uid!).child("groups")
            userRef.updateChildValues([groupKey.key : true])
        }
        chatLogController.groupKey = groupKey.key
        chatLogController.users = users
        
        navigationController?.pushViewController(chatLogController, animated: true)
        
    }
    
    func showChatControllerForUser(_ group: Group) {
        let chatLogController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        chatLogController.groupKey = group.uid
        chatLogController.group = group
        chatLogController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(chatLogController, animated: true)
    }
   
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groups.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserCell
        let group = groups[indexPath.row]
        cell.group = group
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let group = groups[indexPath.row]
        showChatControllerForUser(group)
//        guard let chatPartnerId = message.chatPartnerId() else {
//            return
//        }
        
//        let ref = Database.database().reference().child("users").child(chatPartnerId)
//        ref.observeSingleEvent(of: .value) { (snapshot) in
//            let user = HUser(snapshot: snapshot)
//            user.uid = chatPartnerId
//            self.showChatControllerForUser(users)
//        }
//        showChatControllerForUser(user: User)
    }
}
extension MessagesController {
    
    func presentDetail(_ viewControllerToPresent: UIViewController) {
        let transition = CATransition()
        transition.duration = 0
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        self.view.window!.layer.add(transition, forKey: kCATransition)
        
        present(viewControllerToPresent, animated: false)
    }
    
    func dismissDetail() {
        let transition = CATransition()
        transition.duration = 0.25
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromLeft
        self.view.window!.layer.add(transition, forKey: kCATransition)
        
        dismiss(animated: false)
    }
}
