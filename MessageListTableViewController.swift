//
//  MessageListTableViewController.swift
//  CKBullitenBoard
//
//  Created by Haley Jones on 6/3/19.
//  Copyright © 2019 HaleyJones. All rights reserved.
//

import UIKit

class MessageListTableViewController: UITableViewController {

    @IBOutlet weak var messageTextField: UITextField!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        MessageController.shared.loadMessages { (success) in
            if success{
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return MessageController.shared.messages.count
    }
    
    @IBAction func postButtonPressed(_ sender: Any) {
        guard let messageText = messageTextField.text else {return}
        MessageController.shared.createMessage(with: messageText, timestamp: Date())
    }
    

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "messageCell", for: indexPath)

        let message = MessageController.shared.messages[indexPath.row]
        cell.textLabel?.text = message.text
        cell.detailTextLabel?.text = DateFormatter.localizedString(from: message.timestamp, dateStyle: .medium, timeStyle: .short)

        return cell
    }


    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            let message = MessageController.shared.messages[indexPath.row]
            MessageController.shared.removeMessage(message: message) { (didItWork) in
                if didItWork{
                    DispatchQueue.main.async {
                        tableView.deleteRows(at: [indexPath], with: .fade)
                    }
                }
            }
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
