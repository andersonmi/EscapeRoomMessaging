//
//  LobbyHandler.swift
//  Nimbus
//
//  Created by Michael Anderson on 1/31/17.
//  Copyright © 2017 Michael Anderson. All rights reserved.
//


/*
 
 
    This doesn't work with HintMessage yet, so the target membership is not set and this does not build with the target.  Added Lobby class to the bottom of the function for reference
 
 
 */
import Foundation
import UIKit
import CloudKit

public let lobbyType = "Lobby"

class CloudHandler {
    
    let publicDB = CKContainer.default().publicCloudDatabase
    
    var cachedLobbies: [Lobby]? = nil
    var subscriptionIslocallyCached = false
    
    static let shared: CloudHandler = {
        return CloudHandler()
    }()
    
    func loginToICloud() {
        if (subscriptionIslocallyCached) {return}
        
        let sub = CKDatabaseSubscription(subscriptionID: "shared-changes")
        
        let info = CKNotificationInfo()
        info.shouldSendContentAvailable = true
        
        sub.notificationInfo = info
        
        let operation = CKModifySubscriptionsOperation(subscriptionsToSave: [sub], subscriptionIDsToDelete: [])
        operation.modifySubscriptionsCompletionBlock = { savedSubscriptions, deletedSubscriptionIDs, error in
            if error != nil {
                print (error ?? "Erorr!")
            } else {
                self.subscriptionIslocallyCached = true
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
        
        operation.qualityOfService = .utility
        publicDB.add(operation)
    }
    
    func isICloudContainerAvailable(completion: @escaping (_ signedIn: Bool) -> Void) {
        CKContainer.default().accountStatus { (accountStatus, error) in
            if (accountStatus == .available) {
                completion(true)
            }
            else {
                completion(false)
            }
        }
    }
    
    func createLobby(_ lobby: Lobby, completion: @escaping (_ record: CKRecord?, _ error: Error?) -> Void) {
        guard let record = lobby.record() else {
            //
            return
        }

        publicDB.save(record) { (savedRecord, error) in
            DispatchQueue.main.async {
                self.cachedLobbies?.append(lobby)
                completion(record, error)
            }
        }
    }
    
    func modifyLobby(_ lobby: Lobby, completion: @escaping (_ record: CKRecord?, _ error: Error?) -> Void) {
        guard let record = lobby.record() else {
            //
            return
        }
        
        let modifyOperation = CKModifyRecordsOperation(recordsToSave: [record], recordIDsToDelete: nil)
        modifyOperation.savePolicy = .allKeys
        modifyOperation.qualityOfService = .userInitiated
        modifyOperation.perRecordCompletionBlock = { record, error in
            DispatchQueue.main.async {
                completion(record, error)
            }
        }
        
        publicDB.add(modifyOperation)
    }
    
    func deleteLobby(_ lobby: Lobby, completion: @escaping (_ error: Error?) -> Void) {
        guard let record = lobby.record() else {
            return
        }
        
        publicDB.delete(withRecordID: record.recordID) { (recordID, error) in
            print("Deleted record ids \(recordID) with error \(error)")
            if let index = self.cachedLobbies?.index(of: lobby) {
                self.cachedLobbies?.remove(at: index)
            }
            if error != nil {
                
            }
            DispatchQueue.main.async {
                completion(error)
            }
        }
    }
    
    func fetchAllLobbies(_ completion: @escaping (_ records: [Lobby]?, _ error: Error?) -> Void) {
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: lobbyType, predicate: predicate)
        
        publicDB.perform(query, inZoneWith: nil) { (records, error) in
            self.cachedLobbies = records?.map(Lobby.init)
            
            DispatchQueue.main.async {
                completion(self.cachedLobbies, error)
            }
        }
    }
    
    static func checkLoginStatus(_ handler: @escaping (_ islogged: Bool) -> Void) {
        CKContainer.default().accountStatus{ accountStatus, error in
            if let error = error {
                print(error.localizedDescription)
            }
            switch accountStatus {
            case .available:
                handler(true)
            default:
                handler(false)
            }
        }
    }
}
//enum SkillLevel: Int {
//    case None = 0,
//    Beginner,
//    Intermediate,
//    Expert
//}
//
//enum GameType: Int {
//    case 川麻 = 0,
//    普通
//}
//
//private var playerListKey = "Players"
//private var creatorIDKey =  "Creator"
//private var wagerKey =      "WagerKey"
//private var smokingKey =    "SmokingKey"
//private var playerIDsKey =  "PlayerIDs"
//private var startTimeKey =  "StartTime"
//private var gameNameKey =   "GameName"
//private var gameTypeKey =   "GameType"
//
//class Lobby: NSObject {
//    //Properties
//    var identifier: CKRecordID?
//    var creatorID: String?
//    var gameName: String?
//    var playerList: [String] = []
//    var playerIDs: [String] = []
//    var startTime: Date = Date()
//
//    //Game Filters
//    var gameType: GameType = .川麻
//    var wager: Bool = false
//    var smoking: Bool = false
//    var skillLevel: SkillLevel = .None
//
//    override init() {
//        let userID = UserDefaultsHandler.uniqueID()
//
//        self.creatorID = userID
//        self.playerIDs = [UserDefaultsHandler.uniqueID()]
//
//        if let userNickname = UserDefaultsHandler.userNickname() {
//            self.playerList = [userNickname]
//        }
//    }
//
//    init(record: CKRecord) {
//        if let playerList = record.value(forKey: playerListKey) as? [String] {
//            self.playerList = playerList
//        }
//
//        if let playerIDs = record.value(forKey: playerIDsKey) as? [String] {
//            self.playerIDs = playerIDs
//        }
//
//        if let creatorID = record.value(forKey: creatorIDKey) as? String {
//            self.creatorID = creatorID
//        }
//
//        if let wager = record.value(forKey: wagerKey) as? Bool {
//            self.wager = wager
//        }
//
//        if let smoking = record.value(forKey: smokingKey) as? Bool {
//            self.smoking = smoking
//        }
//
//        if let startTime = record.value(forKey: startTimeKey) as? Date {
//            self.startTime = startTime
//        }
//
//        if let gameName = record.value(forKey: gameNameKey) as? String {
//            self.gameName = gameName
//        }
//
//        if let gameTypeValue = record.value(forKey: gameTypeKey) as? Int {
//            if let gameType = GameType(rawValue: gameTypeValue) {
//                self.gameType = gameType
//            }
//        }
//
//        self.identifier = record.recordID
//    }
//
//    func record() -> CKRecord? {
//        var record: CKRecord
//        if let id = identifier {
//            record = CKRecord(recordType: lobbyType, recordID: id)
//        } else {
//            record = CKRecord(recordType: lobbyType)
//        }
//
//        record.setValue(playerList, forKey:playerListKey)
//        record.setValue(startTime, forKey: startTimeKey)
//        record.setValue(creatorID, forKey: creatorIDKey)
//        record.setValue(playerIDs, forKey: playerIDsKey)
//        record.setValue(wager, forKey: wagerKey)
//        record.setValue(gameName, forKey: gameNameKey)
//        record.setValue(smoking, forKey: smokingKey)
//        record.setValue(gameType.rawValue, forKey: gameTypeKey)
//
//        return record
//    }
//
//    static func ==(first: Lobby, second: Lobby) -> Bool {
//        return first.identifier == second.identifier
//    }
//
//}

