//
//  AdminViewController.swift
//  Escape Room
//
//  Created by Michael Anderson on 2/22/18.
//  Copyright © 2018 Michael Anderson. All rights reserved.
//

import UIKit

class AdminViewController: KUIViewController, UITableViewDelegate, UITableViewDataSource, MCHandlerDelegate {
    
    var premadeResponses = PremadeReplies().replies
    var connectionHandler = MCHandler()
    var userQuestions: [HintMessage] = []
    
    @IBOutlet weak var replyTextView: UITextView!
    @IBOutlet weak var userQuestionTextView: UITextView!
    @IBOutlet weak var roomTabControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        connectionHandler.connectToPeers()
        connectionHandler.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func changedRoomTab(_ sender: UISegmentedControl) {
        let roomNumber = sender.selectedSegmentIndex
        loadRoom(roomNumber)
    }
    
    func loadRoom(_ roomNumber: Int) {
        userQuestionTextView.text = ""
        
        for message in userQuestions {
            if roomNumber == message.roomNumber {
                userQuestionTextView.text = message.messageText
            }
        }
    }
    
    func receivedMessage(_ message: HintMessage) {
        userQuestions.append(message)
        loadRoom(roomTabControl.selectedSegmentIndex)
    }
    
    @IBAction func replyButtonPressed(_ sender: Any) {
        let message = HintMessage(roomNumber: -1, messageText: replyTextView.text)
        connectionHandler.sendMessage(message)
    }
    
    // MARK: - UITableViewDelegate

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return premadeResponses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "premadeReplies", for: indexPath)
        if let repliesCell = cell as? RepliesCell {
            repliesCell.label.text = premadeResponses[indexPath.row]
        }
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        replyTextView.text = premadeResponses[indexPath.row]
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
