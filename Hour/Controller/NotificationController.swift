//
//  NotificationController.swift
//  Hour
//
//  Created by Moses Oh on 2/28/18.
//  Copyright © 2018 Moses Oh. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class NotificationController: UITableViewController {
    static var controller: NotificationController?
    
    let cellId = "cellId"
    var notifications = [Notification]()
    var userPosts = [String]()
    var refresher: UIRefreshControl!

    let refreshView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        print("MessagesController loaded")
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func updateNotification() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.tableView.reloadData()
            self.refresher.endRefreshing()

        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white
        
        refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(updateNotification), for: UIControl.Event.valueChanged)
        
        tableView.addSubview(refreshView)
        refreshView.frame = CGRect(x: 0, y: 0, width: 0, height: 100)
        refreshView.addSubview(refresher)
        
        tableView.register(NotificationCell.self, forCellReuseIdentifier: cellId)
        observeNotifications()
    }
    
  
    func observeNotifications() {
        let uid = Auth.auth().currentUser?.uid
        let user_post = Database.database().reference().child("users").child(uid!).child("posts")
        
        user_post.observe(.childChanged) { (posts) in
            print("hello")
            /* if current user has been accepted to a post */
            if(posts.value as? Int == 1)
            {
                let notification = Notification()
                notification.postUid = posts.key
                notification.state = -1
                self.notifications.append(notification)
                self.tableView.reloadData()
            }
        }
        user_post.observe(.childAdded) { (posts) in
            print("new ")
            /* if current user is owner of the post, observe the users in that post */
            if(posts.value as? Int == -1)
            {
                self.userPosts.append(posts.key)
                let post_usersUid = Database.database().reference().child("posts").child(posts.key).child("usersUid")
                post_usersUid.observe(.childAdded) {(user) in
                    if let dictionary = user.value as? [String: AnyObject]
                    {
                        if(dictionary["status"] as? Int == 0)
                        {
                            DispatchQueue.main.async {
                                let notification = Notification()
                                notification.userUid = user.key
                                notification.postUid = posts.key
                                notification.state = dictionary["status"] as? Int
                                self.notifications.append(notification)
                                self.tableView.reloadData()
                            }
                        }
                    }
                    
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! NotificationCell
        let notification = notifications[indexPath.row]
        cell.index = indexPath.row
        cell.notification = notification
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let group = notifications[indexPath.row]
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
