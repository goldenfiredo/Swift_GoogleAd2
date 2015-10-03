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
        self.view.backgroundColor = UIColor.whiteColor()
    }
    
    @IBAction func closeAddEntity(segue:UIStoryboardSegue) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func saveEntity(segue:UIStoryboardSegue) {
        let name = nameTextField!.text!
        let desc = descTextField!.text!
        print("in save entry. name:\(name), description:\(desc)")
        
        if !name.isEmpty {
            let dal = EntryDAL()
            let entry1 = Entry()
            entry1.name = name
            entry1.description = desc
            dal.insertEntry(entry1)
            
            self.dismissViewControllerAnimated(true, completion: nil)
            
            NSNotificationCenter.defaultCenter().postNotificationName("kDisplayInterstitialNotification", object: nil)
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            nameTextField!.becomeFirstResponder()
        } else if indexPath.section == 1 {
            descTextField!.becomeFirstResponder()
        }
    }
}