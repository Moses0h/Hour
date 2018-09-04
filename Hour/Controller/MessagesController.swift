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
    static var controller: MessagesController?
    
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
        let user_uid_groups = Database.database().reference().child("users").child(uid).child("groups")
        user_uid_groups.observe(.childAdded) { (groupUid) in
            print(groupUid)
            let groups_uid = Database.database().reference().child("groups").child(groupUid.key)
            groups_uid.observe(.value, with: { (groupData) in
                if let dictionary = groupData.value as? [String: AnyObject] {
                    let group = Group(uid: groupData.key, groupName: dictionary["name"] as? String, lastMessage: dictionary["last message"] as? String, timestamp: dictionary["timestamp"] as? Double)
                    if(self.groupsUid.contains(group.uid!))
                    {
                        self.groups[self.groupsUid.index(of: group.uid!)!] = group
                    }
                    else
                    {
                        self.groups.append(group)
                        self.groupsUid.append(group.uid!)
                    }
                    self.tableView.reloadData()
                }
            })
        }
        user_uid_groups.observe(.childRemoved) { (groupUid) in
            self.groups.remove(at: self.groupsUid.index(of: groupUid.key)!)
            self.groupsUid.remove(at: self.groupsUid.index(of: groupUid.key)!)
            self.tableView.reloadData()
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
    
    func createChat(uid: String, name: String, key: String) {
        let groupsRef = Database.database().reference().child("groups")
        let groupsChildValues = ["name":name,"users": [uid: -1]] as [String : Any]
        groupsRef.updateChildValues([key : groupsChildValues])
        
        let userRef = Database.database().reference().child("users").child(uid).child("groups")
        userRef.updateChildValues([key : -1])
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
