//
//  ChatController.swift
//  Hour
//
//  Created by Moses Oh on 3/3/18.
//  Copyright © 2018 Moses Oh. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class ChatLogController: UICollectionViewController, UITextFieldDelegate, UICollectionViewDelegateFlowLayout{
    
    let cellId = "cellId"
    var refresher: UIRefreshControl!
    
    var messagesLimit = 5
//    var userMessagesRef: DatabaseReference?
    
    var lastValue = ""
    
    var users: [HUser]? {
        didSet {
            var title: String = ""
            for user in users! {
                title += user.name! + " "
            }
            navigationItem.title = title
            initialObserveMessages()
        }
    }
    
    var group: Group? {
        didSet {
            navigationItem.title = group?.groupName
            initialObserveMessages()
        }
    }
    
    var groupKey: String?
    
    var messages = [Message]()
    
    lazy var inputTextField: UITextField = {
        let itf = UITextField()
        itf.placeholder = "Enter message..."
        itf.translatesAutoresizingMaskIntoConstraints = false
        itf.backgroundColor = UIColor.white
        itf.delegate = self
        return itf
    }()
    
    var canRefresh = true
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if scrollView.contentOffset.y < -100 { //change 100 to whatever you want
            
            if canRefresh && !self.refresher.isRefreshing {
                
                self.canRefresh = false
                self.refresher.beginRefreshing()
                
                observeMessages() // your viewController refresh function
            }
        }else if scrollView.contentOffset.y >= 0 {
            
            self.canRefresh = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refresher = UIRefreshControl()
//        refresher.addTarget(self, action: #selector(endRefresh), for: UIControl.Event.valueChanged)
        collectionView?.addSubview(refresher)
        
        collectionView?.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)

        collectionView?.alwaysBounceVertical = true
        collectionView?.backgroundColor = UIColor.white
        collectionView?.register(ChatMessageCell.self, forCellWithReuseIdentifier: cellId)
        navigationController?.navigationBar.tintColor = UIColor.white
        collectionView?.keyboardDismissMode = .interactive
    }
    
    @objc func endRefresh() {
        
    }
    
    lazy var inputContainerView: UIView = {
        let containerView = UIView()
        
        containerView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50)
        containerView.backgroundColor = UIColor.white
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        let sendButton = UIButton(type: .system)
        sendButton.setTitle("Send", for: .normal)
        sendButton.titleLabel?.font = UIFont.init(name: "Helvetica Neue", size: 18)!
        sendButton.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(sendButton)
        
        sendButton.rightAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.rightAnchor).isActive = true
        sendButton.centerYAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.centerYAnchor).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        sendButton.heightAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.heightAnchor).isActive = true
        
        containerView.addSubview(self.inputTextField)
        self.inputTextField.leftAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.leftAnchor, constant: 8).isActive = true
        self.inputTextField.centerYAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.centerYAnchor).isActive = true
        self.inputTextField.rightAnchor.constraint(equalTo: sendButton.safeAreaLayoutGuide.leftAnchor).isActive = true
        self.inputTextField.heightAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.heightAnchor).isActive = true
        
        let seperatorLineView = UIView()
        seperatorLineView.backgroundColor = UIColor(r: 220, g:220, b:220)
        seperatorLineView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(seperatorLineView)
        
        seperatorLineView.leftAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.leftAnchor).isActive = true
        seperatorLineView.topAnchor.constraint(equalTo: inputTextField.safeAreaLayoutGuide.topAnchor, constant: -10).isActive = true
        seperatorLineView.widthAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.widthAnchor).isActive = true
        seperatorLineView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        return containerView
    }()
    
    var containerView: UIView!
    
    override var inputAccessoryView: UIView? {
        
        if containerView == nil {
            
            containerView = SendMessageView()
            
            containerView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 70)
            containerView.backgroundColor = UIColor.white
            containerView.translatesAutoresizingMaskIntoConstraints = false
            
            let sendButton = UIButton(type: .system)
            sendButton.setTitle("Send", for: .normal)
            sendButton.backgroundColor = UIColor.white
            sendButton.titleLabel?.font = UIFont.init(name: "Helvetica Neue", size: 18)!
            sendButton.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
            sendButton.translatesAutoresizingMaskIntoConstraints = false
            containerView.addSubview(sendButton)
            
            sendButton.rightAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.rightAnchor).isActive = true
            sendButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
            
            containerView.addSubview(self.inputTextField)
            self.inputTextField.leftAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.leftAnchor, constant: 8).isActive = true
            self.inputTextField.bottomAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.bottomAnchor, constant: -10).isActive = true
            self.inputTextField.rightAnchor.constraint(equalTo: sendButton.safeAreaLayoutGuide.leftAnchor).isActive = true
            self.inputTextField.heightAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.heightAnchor).isActive = true
            sendButton.centerYAnchor.constraint(equalTo: self.inputTextField.safeAreaLayoutGuide.centerYAnchor).isActive = true
            
            sendButton.heightAnchor.constraint(equalTo: self.inputTextField.safeAreaLayoutGuide.heightAnchor).isActive = true


            let seperatorLineView = UIView()
            seperatorLineView.backgroundColor = UIColor(r: 220, g:220, b:220)
            seperatorLineView.translatesAutoresizingMaskIntoConstraints = false
            containerView.addSubview(seperatorLineView)
            
            seperatorLineView.leftAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.leftAnchor).isActive = true
            seperatorLineView.topAnchor.constraint(equalTo: inputTextField.safeAreaLayoutGuide.topAnchor).isActive = true
            seperatorLineView.widthAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.widthAnchor).isActive = true
            seperatorLineView.heightAnchor.constraint(equalToConstant: 1).isActive = true
            
            return containerView
        }
     
        return containerView
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        NotificationCenter.default.removeObserver(self)
        
    }
    
    @objc func handleKeyboardWillShow(notification: NSNotification) {
        let keyboardDuration = (notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as! NSNumber)
        UIView.animate(withDuration: TimeInterval(truncating: keyboardDuration)) {
            self.view.layoutIfNeeded()
            let item = self.collectionView(self.collectionView!, numberOfItemsInSection: 0) - 1
            let lastItemIndex = IndexPath(item: item, section: 0)
            self.collectionView?.scrollToItem(at: lastItemIndex, at: UICollectionView.ScrollPosition.top, animated: true)
        }


    }
    
    @objc func handleKeyboardWillHide(notification: NSNotification) {
        let keyboardDuration = (notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue

        UIView.animate(withDuration: keyboardDuration) {
            self.view.layoutIfNeeded()
            self.collectionView?.scrollToItem(at: IndexPath(item:self.messages.count-1, section: 0), at: .bottom, animated: true)

        }
    }
    func initialObserveMessages() {
        let messagesRef = Database.database().reference().child("group-messages").child(groupKey!).queryLimited(toLast: 20)
        
        messagesRef.observeSingleEvent(of: .value) { (snap) in
            let count = snap.childrenCount
            messagesRef.observe(.childAdded) { (snapshot) in
                self.messages.append(Message(snapshot: snapshot))
                if(count == self.messages.count)
                {
                    self.collectionView?.reloadData()
                    self.collectionView?.scrollToItem(at: IndexPath(item: self.messages.count-1, section: 0), at: UICollectionView.ScrollPosition.top, animated: false)
                    
                }
                else if(self.messages.count > count)
                {
                    DispatchQueue.main.async {
                        self.collectionView?.reloadData()
                        self.collectionView?.scrollToItem(at: IndexPath(item: self.messages.count-1, section: 0), at: UICollectionView.ScrollPosition.top, animated: true)
                    }
                }
            }
        }
    }
    
    func observeMessages() {
        
        var tempArray : [Message] = [Message]()
        let messagesRef = Database.database().reference().child("group-messages").child(groupKey!).queryOrdered(byChild: "timestamp").queryEnding(atValue: messages.first?.timestamp).queryLimited(toLast: 20)
        

        messagesRef.observeSingleEvent(of: .value) { (snap) in
            let count = snap.childrenCount
            messagesRef.observe(.childAdded) { (snapshot) in
                tempArray.append(Message(snapshot: snapshot))
                if(count == tempArray.count)
                {
                    tempArray.remove(at: tempArray.count-1)
                    self.messages = tempArray + self.messages
                    self.collectionView?.reloadData()
                    self.refresher.endRefreshing()
                }
                else if(tempArray.count > count)
                {
                    DispatchQueue.main.async {
                        tempArray.remove(at: tempArray.count-1)
                        self.messages = tempArray + self.messages
                        self.collectionView?.reloadData()
                        self.refresher.endRefreshing()
                    }
                }
            }
        }
        
    }
    
    @objc func handleSend() {
        if(inputTextField.text! != "")
        {
            let messagesRef = Database.database().reference().child("group-messages").child(groupKey!).childByAutoId()
            let timestamp: Double = NSDate().timeIntervalSince1970
            let messageValue = ["fromId" : Auth.auth().currentUser?.uid as Any ,"message": inputTextField.text!, "timestamp": timestamp] as [String: Any]
            
            messagesRef.updateChildValues(messageValue)
            
            // update last message
            Database.database().reference().child("groups").child(groupKey!).updateChildValues(["last message" : messagesRef.key, "timestamp" : timestamp])
            
            self.inputTextField.text = nil
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSend()
        return true
    }
    
    private func setupCell(cell: ChatMessageCell, message: Message) {
//        if let profileImageUrl = self.user?.profileImageUrl {
//            cell.profileImageView.loadImageUsingCacheWithUrlString(profileImageUrl)
//        }
        if message.fromId == Auth.auth().currentUser?.uid {
            cell.bubbleView.backgroundColor = ChatMessageCell.blueColor
            cell.textView.textColor = UIColor.white
            cell.profileImageView.isHidden = true
            
            cell.bubbleViewRightAnchor?.isActive = true
            cell.bubbleViewLeftAnchor?.isActive = false
        } else {
            cell.bubbleView.backgroundColor = UIColor(r: 240, g: 240, b: 240)
            cell.textView.textColor = UIColor.black
            cell.profileImageView.isHidden = false
            
            cell.bubbleViewRightAnchor?.isActive = false
            cell.bubbleViewLeftAnchor?.isActive = true
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }

    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ChatMessageCell
        let message = messages[indexPath.item]
        cell.textView.text = message.message
        setupCell(cell: cell, message: message)
        
        cell.bubbleWidthAnchor?.constant = estimateFrameForText(text: message.message!).width + 28
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var height: CGFloat = 80
        
        if let text = messages[indexPath.item].message {
            height = estimateFrameForText(text: text).height + 20
        }
        
        let width = UIScreen.main.bounds.width
        return CGSize(width: width, height: height)
    }
    
    private func estimateFrameForText(text: String) -> CGRect {
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16)], context: nil)
    }
    
}

class SendMessageView: UIView {
    
    // this is needed so that the inputAccesoryView is properly sized from the auto layout constraints
    // actual value is not important
    
    override var intrinsicContentSize: CGSize {
        return CGSize.zero
    }
}
