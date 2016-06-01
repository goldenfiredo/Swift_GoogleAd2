//
//  ViewController.swift
//  GoogleAd
//
//  Created by Limin Du on 8/27/14.
//  Copyright (c) 2014 GoldenFire.Do. All rights reserved.
//

import UIKit
import iAd
import GoogleMobileAds

let marqueeText = "本呆猫包含Google条幅广告、插屏广告、Apple条幅广告、Swift封装CoreData、Swift封装FMDB、Apple Watch Data Sharing/Communication/Glance/Local Notification、Toast和跑马灯..."

class ViewController: UIViewController, GADBannerViewDelegate, GADInterstitialDelegate,  ADBannerViewDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var buttonAd: UIButton!
    @IBOutlet weak var buttonFMDB: UIButton!
    @IBOutlet weak var buttonCoreData: UIButton!
    
    var iAdSupported = false
    var iAdView:ADBannerView?
    var bannerView:GADBannerView?
    var interstitial:GADInterstitial?
    var timer:NSTimer?
    var loadRequestAllowed = true
    let statusbarHeight:CGFloat = 20.0
    var buttonHeight:CGFloat = 0.0
    var buttonOffsetY:CGFloat = 0.0
    let screen = UIScreen.mainScreen().bounds
    let IS_IPAD = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.Pad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //iAdSupported = iAdTimeZoneSupported()
        iAdSupported = false //Apple has stopped iAd service
        
        if iAdSupported {
            iAdView = ADBannerView(adType: ADAdType.Banner)
            iAdView?.frame = CGRectMake(0, 0 - iAdView!.frame.height, iAdView!.frame.width, iAdView!.frame.height)
            iAdView?.delegate = self
            self.view.addSubview(iAdView!)
        } else {
            if IS_IPAD {
                bannerView = GADBannerView(adSize: kGADAdSizeLeaderboard)
            } else {
                bannerView = GADBannerView(adSize: kGADAdSizeBanner)
            }
            bannerView?.adUnitID = "ca-app-pub-6938332798224330/9023870805"
            bannerView?.delegate = self
            bannerView?.rootViewController = self
            self.view.addSubview(bannerView!)
            
            timer?.invalidate()
            timer = NSTimer.scheduledTimerWithTimeInterval(40, target: self, selector: #selector(ViewController.GoogleAdRequestTimer), userInfo: nil, repeats: true)
        }
        
        //Admob Interstitial
        buttonHeight = IS_IPAD ? 30 : 20 //TODO:
        buttonOffsetY = statusbarHeight
        if !iAdSupported {
            interstitial = createAndLoadInterstitial()
        } else {
            buttonAd.hidden = true;
        }
        
        _ = Marquee(superview: self.view , text: marqueeText)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.AppBecomeActive), name: UIApplicationDidBecomeActiveNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.AppResignActive), name: UIApplicationWillResignActiveNotification, object: nil)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.relayoutViews(false)
        
        self.view.makeToast("Ready for demo")
    }
    
    func scheduleRequest(wait:NSTimeInterval) {
        NSTimer.scheduledTimerWithTimeInterval(wait, target: self, selector: #selector(ViewController.GoogleAdRequestTimer), userInfo: nil, repeats: false)
    }
    
    func GoogleAdRequestTimer() {
        if iAdSupported {
            return;
        }
        
        if (!loadRequestAllowed) {
            print("load request not allowed")
            return
        }
        
        print("load request")
        bannerView?.loadRequest(GADRequest())
    }
    
    func AppBecomeActive() {
        print("received UIApplicationDidBecomeActiveNotification")
        loadRequestAllowed = true
        
        scheduleRequest(5)
    }
    
    func AppResignActive() {
        print("received UIApplicationWillResignActiveNotification")
        loadRequestAllowed = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //GADBannerViewDelegate
    func adViewDidReceiveAd(view: GADBannerView!) {
        print("adViewDidReceiveAd");
        relayoutViews(true)
    }
    
    func adView(view: GADBannerView!, didFailToReceiveAdWithError error: GADRequestError!) {
        print("\(view) error:\(error)")
        relayoutViews(false)
    }
    
    func adViewWillPresentScreen(adView: GADBannerView!) {
        print("adViewWillPresentScreen")
        relayoutViews(false)
    }
    
    func adViewWillLeaveApplication(adView: GADBannerView!) {
        print("adViewWillLeaveApplication")
        relayoutViews(false)
    }
    
    func adViewWillDismissScreen(adView: GADBannerView!) {
        print("adViewWillDismissScreen")
        relayoutViews(false)
    }
    
    func adViewDidDismissScreen(bannerView: GADBannerView!) {
        print("adViewDidDismissScreen")
    }
    
    func relayoutViews(displayed:Bool) {
        if (displayed) {
            var bannerFrame = iAdSupported ? iAdView!.frame : bannerView!.frame
            bannerFrame.origin.x = (screen.width - bannerFrame.width)/2
            bannerFrame.origin.y = statusbarHeight
            if iAdSupported {
                iAdView!.frame = bannerFrame
            } else {
                bannerView!.frame = bannerFrame
            }
            
            var imageviewFrame = imageView!.frame
            imageviewFrame.origin.x = 0
            imageviewFrame.origin.y = statusbarHeight + bannerFrame.size.height
            imageView!.frame = imageviewFrame
            
            var buttonFrame:CGRect
            buttonOffsetY = statusbarHeight + bannerFrame.size.height
            //Admob Interstitial button
            if !iAdSupported {
                buttonFrame = buttonAd!.frame
                buttonFrame.origin.y = buttonOffsetY
                buttonAd!.frame = buttonFrame
                buttonOffsetY = buttonOffsetY + buttonHeight + 5
            }
            
            buttonFrame = buttonFMDB!.frame
            buttonFrame.origin.y = buttonOffsetY
            buttonFMDB!.frame = buttonFrame
            buttonOffsetY = buttonOffsetY + buttonHeight + 5
            
            buttonFrame = buttonCoreData!.frame
            buttonFrame.origin.y = buttonOffsetY
            buttonCoreData!.frame = buttonFrame
            
        } else {
            var bannerFrame = iAdSupported ? iAdView!.frame : bannerView!.frame
            bannerFrame.origin.x = 0
            bannerFrame.origin.y = 0 - bannerFrame.size.height
            if iAdSupported {
                iAdView!.frame = bannerFrame
            } else {
                bannerView!.frame = bannerFrame
            }
            
            var imageviewFrame = imageView!.frame
            imageviewFrame.origin.x = 0
            imageviewFrame.origin.y = statusbarHeight
            imageView!.frame = imageviewFrame
            
            var buttonFrame:CGRect
            buttonOffsetY = statusbarHeight
            //Admob Interstitial button
            if !iAdSupported {
                buttonFrame = buttonAd!.frame
                buttonFrame.origin.y = buttonOffsetY
                buttonAd!.frame = buttonFrame
                buttonOffsetY = buttonOffsetY + buttonHeight + 5
            }
            
            buttonFrame = buttonFMDB!.frame
            buttonFrame.origin.y = buttonOffsetY
            buttonFMDB!.frame = buttonFrame
            buttonOffsetY = buttonOffsetY + buttonHeight + 5
            
            buttonFrame = buttonCoreData!.frame
            buttonFrame.origin.y = buttonOffsetY
            buttonCoreData!.frame = buttonFrame
        }
    }
    
    //Interstitial func
    func createAndLoadInterstitial()->GADInterstitial {
        print("createAndLoadInterstitial")
        let interstitial = GADInterstitial(adUnitID: "ca-app-pub-6938332798224330/6206234808")
        interstitial.delegate = self
        interstitial.loadRequest(GADRequest())
        
        return interstitial
    }
    
    @IBAction func presentInterstitial(sender:UIButton!) {
        if let _ = interstitial?.isReady {
            interstitial?.presentFromRootViewController(self)
        }
    }
    
    //Interstitial delegate
    func interstitial(ad: GADInterstitial!, didFailToReceiveAdWithError error: GADRequestError!) {
        print("interstitialDidFailToReceiveAdWithError:\(error.localizedDescription)")
        buttonAd?.enabled = false
        interstitial = createAndLoadInterstitial()
    }
    
    func interstitialDidReceiveAd(ad: GADInterstitial!) {
        print("interstitialDidReceiveAd")
        buttonAd?.enabled = true
    }
    
    func interstitialWillDismissScreen(ad: GADInterstitial!) {
        print("interstitialWillDismissScreen")
        buttonAd?.enabled = false
        interstitial = createAndLoadInterstitial()
    }
    
    func interstitialDidDismissScreen(ad: GADInterstitial!) {
        print("interstitialDidDismissScreen")
        scheduleRequest(3)
    }
    
    func interstitialWillLeaveApplication(ad: GADInterstitial!) {
        print("interstitialWillLeaveApplication")
        relayoutViews(false)
    }
    
    func interstitialWillPresentScreen(ad: GADInterstitial!) {
        print("interstitialWillPresentScreen")
        relayoutViews(false)
    }
    
    
    //iAd func
    func iAdTimeZoneSupported()->Bool {
        let iAdTimeZones = "America/;US/;Pacific/;Asia/Tokyo;Europe/".componentsSeparatedByString(";")
        let myTimeZone = NSTimeZone.localTimeZone().name
        for zone in iAdTimeZones {
            if (myTimeZone.hasPrefix(zone)) {
                return true;
            }
        }
        
        return false;
    }
    
    //iAdBannerViewDelegate
    func bannerViewWillLoadAd(banner: ADBannerView!) {
        print("bannerViewWillLoadAd")
    }
    
    func bannerViewDidLoadAd(banner: ADBannerView!) {
        print("bannerViewDidLoadAd")
        relayoutViews(true)
    }
    
    func bannerView(banner: ADBannerView!, didFailToReceiveAdWithError error: NSError!) {
        print("bannerViewDidFailToReceiveAd error:\(error)")
        relayoutViews(false)
    }
    
    func bannerViewActionDidFinish(banner: ADBannerView!) {
        print("bannerViewActionDidFinish")
        relayoutViews(false)
    }
    
    func bannerViewActionShouldBegin(banner: ADBannerView!, willLeaveApplication willLeave: Bool) -> Bool {
        print("bannerViewActionShouldBeginWillLeaveApplication")
        return true;
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        loadRequestAllowed = false
        if !iAdSupported {
            relayoutViews(false)
        }
    }
    
    @IBAction func unwindForSegue(unwindSegue: UIStoryboardSegue) {
        loadRequestAllowed = true
        
        scheduleRequest(3)
    }
}

