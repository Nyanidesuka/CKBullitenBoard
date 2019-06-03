//
//  MessageController.swift
//  CKBullitenBoard
//
//  Created by Haley Jones on 6/3/19.
//  Copyright © 2019 HaleyJones. All rights reserved.
//

import Foundation
import CloudKit

class MessageController{
    
    static let shared = MessageController()
    
    //SoT
    var messages: [Message] = []
    
    //database
    let privateDB = CKContainer.default().privateCloudDatabase
    
    //CRUD
    func createMessage(with text: String, timestamp: Date){
        let message = Message(text: text, timestamp: timestamp)
        self.saveMessage(message: message) { (_) in
            //bad error handling
        }
    }
    
    func removeMessage(message: Message, completion: @escaping (Bool) -> ()) {
        //remove locally
        guard let index = MessageController.shared.messages.index(of: message) else {return}
        //remove cloudally
        MessageController.shared.messages.remove(at: index)
        privateDB.delete(withRecordID: message.ckRecordID) { (_, error) in
            if let error = error{
                print("There was an error removing the message from the cloud. \(error.localizedDescription)")
            }
        }
    }
    
    //save and load
    func saveMessage(message: Message, completion: @escaping (Bool) -> ()){
        let messageRecord = CKRecord(message: message)
        privateDB.save(messageRecord) { (record, error) in
            if let error = error{
                print("⚠️oh no! Bad code!⚠️ \(error.localizedDescription)")
                completion(false)
                return
            }
            guard let unwrappedRecord = record, let message = Message(ckRecord: unwrappedRecord) else {completion(false); return}
            self.messages.append(message)
            completion(true)
        }
    }
    
    func loadMessages(completion: @escaping (Bool) -> ()){
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: Constants.recordKey, predicate: predicate)
        privateDB.perform(query, inZoneWith: nil) { (records, error) in
            if let error = error{
                print("⚠️More bad code!⚠️ \(error.localizedDescription)")
                completion(false)
                return
            }
            guard let records = records else {completion(false); return}
            let messages = records.compactMap({Message(ckRecord: $0)})
            self.messages = messages
            completion(true)
        }
    }
}
