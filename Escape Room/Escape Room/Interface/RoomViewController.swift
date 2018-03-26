//
//  ViewController.swift
//  Escape Room
//
//  Created by Michael Anderson on 2/12/18.
//  Copyright © 2018 Michael Anderson. All rights reserved.
//

import UIKit
import MultipeerConnectivity

let serviceType = "esc-service"

class RoomViewController: UIViewController, MCHandlerDelegate {
    
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var hintTextView: UITextView!
    
    var roomNumber: Int = 0
    var connectionHandler = MCHandler()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        connectionHandler.connectToPeers()
        connectionHandler.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func sendMessage(_ sender: Any) {
        let message = HintMessage(roomNumber: roomNumber, messageText: messageTextView.text)
       connectionHandler.sendMessage(message)
    }
    
    func receivedMessage(_ message: HintMessage) {
        hintTextView.text = message.messageText
    }
    
}
