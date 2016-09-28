//
//  AddEntryViewController.swift
//  SwiftFMDBDemo
//
//  Created by Limin Du on 11/18/14.
//  Copyright (c) 2014 GoldenFire.Do. All rights reserved.
//

import Foundation
import UIKit

class AddEntryViewController : UITableViewController {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var descTextField: UITextField!
    
    override func viewDidLoad() {
        self.view.backgroundColor = UIColor.white
    }
    
    @IBAction func closeAddEntity(_ segue:UIStoryboardSegue) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveEntity(_ segue:UIStoryboardSegue) {
        let name = nameTextField!.text!
        let desc = descTextField!.text!
        print("in save entry. name:\(name), description:\(desc)")
        
        if !name.isEmpty {
            let dal = EntryDAL()
            let entry1 = Entry()
            entry1.name = name
            entry1.description = desc
            dal.insertEntry(entry1)
            
            self.dismiss(animated: true, completion: nil)
            
            NotificationCenter.default.post(name: Notification.Name(rawValue: "kDisplayInterstitialNotification"), object: nil)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath as NSIndexPath).section == 0 {
            nameTextField!.becomeFirstResponder()
        } else if (indexPath as NSIndexPath).section == 1 {
            descTextField!.becomeFirstResponder()
        }
    }
}
