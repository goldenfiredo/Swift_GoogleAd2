//
//  DetailEntryController.swift
//  GoogleAd
//
//  Created by Du Limin on 4/19/15.
//  Copyright (c) 2015 GoldenFire.Do. All rights reserved.
//

import WatchKit
import Foundation


class DetailEntryController: WKInterfaceController {
    
    @IBOutlet weak var nameLabel: WKInterfaceLabel!
    @IBOutlet weak var descLabel: WKInterfaceLabel!
    @IBOutlet weak var selectedSwitch: WKInterfaceSwitch!
    
    let defaults = UserDefaults.standard
    let selectedEntryKey = "selectedEntry"
    var data:Entry?
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
        data = context as? Entry
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        nameLabel.setText(data?.name)
        descLabel.setText(data?.description)
        
        if let selectedEntry = defaults.string(forKey: selectedEntryKey) {
            selectedSwitch.setOn(selectedEntry == data?.name)
        }
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

    @IBAction func back() {
        pop()
    }
    
    @IBAction func delete() {
        if data != nil {
            let dal = EntryDAL()
            dal.deleteEntry(data!)
            
            let userInfo = ["command" : "Refresh"]
            WKInterfaceController.openParentApplication(userInfo, reply: { (replyInfo, error) in
                if let error = error {
                    print(error)
                }
                //if let data = data {
                if let data = replyInfo["response"] {
                    print("response:\(data)")
                }
            })
        }
        
        pop()
    }
    
    @IBAction func selectedSwitchValueChanged(_ value: Bool) {
        if let data = data {
            defaults.removeObject(forKey: selectedEntryKey)

            if value {
                defaults.set(data.name, forKey: selectedEntryKey)
            }

            defaults.synchronize()
        }
    }
}
