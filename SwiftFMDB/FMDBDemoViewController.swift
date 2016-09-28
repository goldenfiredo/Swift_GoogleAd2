//
//  FMDBDemoViewController.swift
//  SwiftFMDBDemo
//
//  Created by Limin Du on 11/18/14.
//  Copyright (c) 2014 GoldenFire.Do. All rights reserved.
//

import Foundation
import UIKit
import GoogleMobileAds

class FMDBDemoViewController : UITableViewController,  GADInterstitialDelegate {
    let dal = EntryDAL()
    var data=[Entry]()
    
    var interstitial:GADInterstitial?
    
    override func viewDidLoad() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        interstitial = createAndLoadInterstitial()
        
        NotificationCenter.default.addObserver(self, selector: #selector(FMDBDemoViewController.displayInterstitial), name: NSNotification.Name(rawValue: "kDisplayInterstitialNotification"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(FMDBDemoViewController.refresh), name: NSNotification.Name(rawValue: "kRefreshFMDBNotification"), object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        data = dal.getAllEntries()
    
        self.tableView.reloadData()
    }
    
    @IBAction func backToMain(_ segue : UIStoryboardSegue) {
        dismiss(animated: true, completion: nil)
    }
    
    //table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let index = (indexPath as NSIndexPath).row
        let cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: nil)
        cell.textLabel?.text = data[index].name
        cell.detailTextLabel?.text = data[index].description
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        let e = data[(indexPath as NSIndexPath).row]
        if dal.deleteEntry(e) {
            data.remove(at: (indexPath as NSIndexPath).row)
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
        interstitial = createAndLoadInterstitial()
    }
    
    /*func interstitialDidDismissScreen(ad: GADInterstitial!) {
        println("interstitialDidDismissScreen")
    }
    
    func interstitialWillLeaveApplication(ad: GADInterstitial!) {
        println("interstitialWillLeaveApplication")
    }
    
    func interstitialWillPresentScreen(ad: GADInterstitial!) {
        println("interstitialWillPresentScreen")
    }*/
    
    func displayInterstitial() {
        if let _ = interstitial?.isReady {
            interstitial?.present(fromRootViewController: self)
        }
    }
    
    func refresh() {
        print("in refresh")
        
        data = dal.getAllEntries()
        self.tableView.reloadData()
    }
}
