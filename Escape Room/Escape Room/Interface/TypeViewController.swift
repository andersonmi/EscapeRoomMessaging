//
//  TypeViewController.swift
//  Escape Room
//
//  Created by Michael Anderson on 2/23/18.
//  Copyright © 2018 Michael Anderson. All rights reserved.
//

import UIKit

class TypeViewController: UIViewController {

    @IBAction func sepiaRoomSelected(_ sender: Any) {
        segueToRoomView(0)
    }
    
    @IBAction func platinumRoomSelected(_ sender: Any) {
        segueToRoomView(1)
    }
    
    @IBAction func crimsonRoomSelected(_ sender: Any) {
        segueToRoomView(2)
    }
    
    func segueToRoomView(_ roomNumber: Int) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let roomController = storyboard.instantiateViewController(withIdentifier: "Room")
        
        self.present(roomController, animated: true) {
            if let controller = roomController as? RoomViewController {
                controller.roomNumber = roomNumber
            }
        }
    }
    
}
