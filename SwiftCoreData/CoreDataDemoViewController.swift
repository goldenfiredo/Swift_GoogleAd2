//
//  CoreDataDemoViewController.swift
//  SwiftCoreDataDemo
//
//  Created by Limin Du on 11/18/14.
//  Copyright (c) 2014 GoldenFire.Do. All rights reserved.
//

import Foundation
import UIKit
import GoogleMobileAds

class CoreDataDemoViewController : UITableViewController, GADInterstitialDelegate {
    
    var people = [PersonModal]()
    var dal:CoreDataDAL!
    
    var interstitial:GADInterstitial?
    
    override func viewDidLoad() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        interstitial = createAndLoadInterstitial()
        
        NotificationCenter.default.addObserver(self, selector: #selector(CoreDataDemoViewController.displayInterstitial), name: NSNotification.Name(rawValue: "kDisplayInterstitialNotification"), object: nil)
        
        dal = CoreDataDAL()
        
        NotificationCenter.default.addObserver(self, selector: #selector(CoreDataDemoViewController.applicationWillTerminate), name: NSNotification.Name.UIApplicationWillTerminate, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        people = dal.getAllPersons()
    
        self.tableView.reloadData()
    }
    
    @IBAction func backToMain(_ segue : UIStoryboardSegue) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addPerson() {
        print("in add Person")
        
        let alert = UIAlertController(title: "New Person", message: "Add a new Person", preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { (action: UIAlertAction) -> Void in
                let textField = alert.textFields![0] 
                self.saveName(textField.text!)
                self.tableView.reloadData()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel",
            style: .default) { (action: UIAlertAction) -> Void in
        }
        
        alert.addTextField {
            (textField: UITextField!) -> Void in
        }
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    func saveName(_ name: String) {
        if let person = dal.savePerson(name) {
            people.append(person)
            
            NotificationCenter.default.post(name: Notification.Name(rawValue: "kDisplayInterstitialNotification"), object: nil)
        }
    }
    
    func applicationWillTerminate() {
        print("in applicationWillTerminate", terminator: "")
        dal.saveContext()
    }
    
    //table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return people.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: nil)
        let person = people[(indexPath as NSIndexPath).row]
        cell.textLabel!.text = person.name
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        let person = people[(indexPath as NSIndexPath).row]
        if self.dal.deletePerson(person.name) {
            self.people.remove(at: (indexPath as NSIndexPath).row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    //Interstitial func
    func createAndLoadInterstitial()->GADInterstitial {
        let interstitial = GADInterstitial(adUnitID: "ca-app-pub-6938332798224330/6206234808")
        interstitial.delegate = self
        interstitial.load(GADRequest())
        
        return interstitial
    }
    
    //Interstitial delegate
    func interstitial(_ ad: GADInterstitial!, didFailToReceiveAdWithError error: GADRequestError!) {
        print("interstitialDidFailToReceiveAdWithError:\(error.localizedDescription)")
        interstitial = createAndLoadInterstitial()
    }
    
    func interstitialWillDismissScreen(_ ad: GADInterstitial!) {
        
    }
    
    func displayInterstitial() {
        if let _ = interstitial?.isReady {
            if interstitial?.hasBeenUsed != true {
                interstitial?.present(fromRootViewController: self)
            }
        }
    }
}
