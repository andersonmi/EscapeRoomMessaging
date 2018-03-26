//
//  MCHandler.swift
//  Escape Room
//
//  Created by Michael Anderson on 2/22/18.
//  Copyright © 2018 Michael Anderson. All rights reserved.
//

import UIKit
import MultipeerConnectivity

protocol MCHandlerDelegate {
    func receivedMessage(_ message: HintMessage)
}

class MCHandler: NSObject, MCNearbyServiceAdvertiserDelegate, MCSessionDelegate, MCNearbyServiceBrowserDelegate {

    var peers: [MCPeerID] = []
    var advertiser: MCNearbyServiceAdvertiser?
    var session: MCSession?
    var browser: MCNearbyServiceBrowser?
    var delegate: MCHandlerDelegate?
    
     let peerID = MCPeerID(displayName: UIDevice.current.name)
    
    func connectToPeers() {
        session = MCSession(peer: peerID,
                            securityIdentity: nil,
                            encryptionPreference: .none)
        session?.delegate = self
        
        advertiser = MCNearbyServiceAdvertiser(peer: peerID,
                                               discoveryInfo: nil,
                                               serviceType: serviceType)
        advertiser?.delegate = self
        advertiser?.startAdvertisingPeer()
        
        browser = MCNearbyServiceBrowser(peer: peerID, serviceType: serviceType)
        browser?.delegate = self
        browser?.startBrowsingForPeers()
    }
    
    func sendMessage(_ message: HintMessage) {
        do {
            let data = try JSONEncoder().encode(message)
            try session?.send(data, toPeers: peers, with: .reliable)
        } catch {
            print("[Error] \(error)")
        }
    }
    
    //MARK: MCNearbyServiceAdvertiserDelegate
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser,
                    didReceiveInvitationFromPeer peerID: MCPeerID,
                    withContext context: Data?,
                    invitationHandler: @escaping (Bool, MCSession?) -> Void)
    {
        print("Added \(peerID) to the session!")
        invitationHandler(true, self.session)
    }
    
    
    // MARK: MCSessionDelegate
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        print("\(peerID) changed to state: \(state)")
    }
    
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        
    }
    
    func session(_ session: MCSession, didReceiveCertificate certificate: [Any]?, fromPeer peerID: MCPeerID, certificateHandler: @escaping (Bool) -> Void) {
        certificateHandler(true)
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        if let object = try? JSONDecoder().decode(HintMessage.self, from: data) {
            print("\(object)")
            DispatchQueue.main.async {
                self.delegate?.receivedMessage(object)
            }
        }
    }
    
    // MARK: MCNearbyServiceBrowser
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        browser.invitePeer(peerID, to: session!, withContext: nil, timeout: 5)
        peers.append(peerID)
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        if let index = peers.index(of: peerID) {
            peers.remove(at: index)
        }
    }
}
