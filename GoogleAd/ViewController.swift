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
    var iAdSupported = false
    var iAdView:ADBannerView?
    var bannerView:GADBannerView?
    var interstitial:GADInterstitial?
    var button:UIButton?
    var imageView:UIImageView?
    var timer:NSTimer?
    var loadRequestAllowed = true
    var bannerDisplayed = false
    let statusbarHeight:CGFloat = 20.0
    var adViewHeight:CGFloat = 0
    var buttonHeight:CGFloat = 0.0
    var buttonOffsetY:CGFloat = 0.0
    let screen = UIScreen.mainScreen().bounds
    let IS_IPAD = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.Pad
    
    var demoButton:UIButton?
    var demoCoreDataButton:UIButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        iAdSupported = iAdTimeZoneSupported()
        
        bannerDisplayed = false
        
        if iAdSupported {
            iAdView = ADBannerView(adType: ADAdType.Banner)
            iAdView?.frame = CGRectMake(0, 0 - iAdView!.frame.height, iAdView!.frame.width, iAdView!.frame.height)
            iAdView?.delegate = self
            self.view.addSubview(iAdView!)
            adViewHeight = iAdView!.frame.size.height
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
            adViewHeight = bannerView!.frame.size.height
            bannerView?.loadRequest(GADRequest())
        
            timer?.invalidate()
            timer = NSTimer.scheduledTimerWithTimeInterval(40, target: self, selector: "GoogleAdRequestTimer", userInfo: nil, repeats: true)
        }
        
        let image = UIImage(named: "admob.png")
        imageView = UIImageView(image: image)
        var frame = imageView!.frame
        frame.origin.x = 0
        frame.origin.y = statusbarHeight
        frame.size.width = screen.width
        frame.size.height = screen.height
        imageView!.frame = frame
        self.view.addSubview(imageView!)
        
        //Admob Interstitial
        buttonHeight = IS_IPAD ? 30 : 20
        buttonOffsetY = statusbarHeight
        if !iAdSupported {
            interstitial = createAndLoadInterstitial()
            
            button = UIButton(type: UIButtonType.System)
            button?.frame = CGRectMake(60, buttonOffsetY, IS_IPAD ? 400 : 180, buttonHeight)
            button?.setTitle("<<<点此测试插屏广告>>>", forState: UIControlState.Normal)
            button?.enabled = false
            button?.userInteractionEnabled = true
            button?.addTarget(self, action: "presentInterstitial:", forControlEvents: .TouchUpInside)
            self.view.addSubview(button!)
            
            buttonOffsetY = buttonOffsetY + buttonHeight
        }
        
        buttonOffsetY = buttonOffsetY + 5
        demoButton = UIButton(type: UIButtonType.System)
        demoButton?.frame = CGRectMake(40, buttonOffsetY, IS_IPAD ? 500 : 240, buttonHeight)
        demoButton?.setTitle("<<<点此测试 Wrapping FMDB>>>", forState: UIControlState.Normal)
        demoButton?.userInteractionEnabled = true
        demoButton?.addTarget(self, action: "showDemo:", forControlEvents: .TouchUpInside)
        self.view.addSubview(demoButton!)
        
        buttonOffsetY = buttonOffsetY + buttonHeight + 5
        demoCoreDataButton = UIButton(type: UIButtonType.System)
        demoCoreDataButton?.frame = CGRectMake(20, buttonOffsetY, IS_IPAD ? 600 : 280, buttonHeight)
        demoCoreDataButton?.setTitle("<<<点此测试 Wrapping CoreData>>>", forState: UIControlState.Normal)
        demoCoreDataButton?.userInteractionEnabled = true
        demoCoreDataButton?.addTarget(self, action: "showCoreDataDemo:", forControlEvents: .TouchUpInside)
        self.view.addSubview(demoCoreDataButton!)
        
        Marquee(superview: self.view , text: marqueeText)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "AppBecomeActive", name: UIApplicationDidBecomeActiveNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "AppResignActive", name: UIApplicationWillResignActiveNotification, object: nil)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.view.makeToast("Ready for demo")
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
        print("adViewDidReceiveAd:\(view)");
        bannerDisplayed = true
        relayoutViews()
    }
    
    func adView(view: GADBannerView!, didFailToReceiveAdWithError error: GADRequestError!) {
        print("\(view) error:\(error)")
        bannerDisplayed = false
        relayoutViews()
    }
    
    func adViewWillPresentScreen(adView: GADBannerView!) {
        print("adViewWillPresentScreen:\(adView)")
        bannerDisplayed = false
        relayoutViews()
    }
    
    func adViewWillLeaveApplication(adView: GADBannerView!) {
        print("adViewWillLeaveApplication:\(adView)")
        bannerDisplayed = false
        relayoutViews()
    }
    
    func adViewWillDismissScreen(adView: GADBannerView!) {
        print("adViewWillDismissScreen:\(adView)")
        bannerDisplayed = false
        relayoutViews()
    }
    
    func relayoutViews() {
        if (bannerDisplayed) {
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
            buttonOffsetY = statusbarHeight + adViewHeight
            //Admob Interstitial button
            if !iAdSupported {
                buttonFrame = button!.frame
                buttonFrame.origin.y = buttonOffsetY
                button!.frame = buttonFrame
                buttonOffsetY = buttonOffsetY + buttonHeight + 5
            }
            
            buttonFrame = demoButton!.frame
            buttonFrame.origin.y = buttonOffsetY
            demoButton!.frame = buttonFrame
            buttonOffsetY = buttonOffsetY + buttonHeight + 5
            
            buttonFrame = demoCoreDataButton!.frame
            buttonFrame.origin.y = buttonOffsetY
            demoCoreDataButton!.frame = buttonFrame
            
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
                buttonFrame = button!.frame
                buttonFrame.origin.y = buttonOffsetY
                button!.frame = buttonFrame
                buttonOffsetY = buttonOffsetY + buttonHeight + 5
            }
            
            buttonFrame = demoButton!.frame
            buttonFrame.origin.y = buttonOffsetY
            demoButton!.frame = buttonFrame
            buttonOffsetY = buttonOffsetY + buttonHeight + 5
            
            buttonFrame = demoCoreDataButton!.frame
            buttonFrame.origin.y = buttonOffsetY
            demoCoreDataButton!.frame = buttonFrame
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
    
    func presentInterstitial(sender:UIButton!) {
        if let _ = interstitial?.isReady {
            interstitial?.presentFromRootViewController(self)
        }
    }
    
    //Interstitial delegate
    func interstitial(ad: GADInterstitial!, didFailToReceiveAdWithError error: GADRequestError!) {
        print("interstitialDidFailToReceiveAdWithError:\(error.localizedDescription)")
        button?.enabled = false
        interstitial = createAndLoadInterstitial()
    }
    
    func interstitialDidReceiveAd(ad: GADInterstitial!) {
        print("interstitialDidReceiveAd")
        button?.enabled = true
    }
    
    func interstitialWillDismissScreen(ad: GADInterstitial!) {
        print("interstitialWillDismissScreen")
        button?.enabled = false
        interstitial = createAndLoadInterstitial()
    }
    
    func interstitialDidDismissScreen(ad: GADInterstitial!) {
        print("interstitialDidDismissScreen")
    }
    
    func interstitialWillLeaveApplication(ad: GADInterstitial!) {
        print("interstitialWillLeaveApplication")
    }
    
    func interstitialWillPresentScreen(ad: GADInterstitial!) {
        print("interstitialWillPresentScreen")
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
        bannerDisplayed = true
        relayoutViews()
    }
    
    func bannerView(banner: ADBannerView!, didFailToReceiveAdWithError error: NSError!) {
        print("didFailToReceiveAd error:\(error)")
        bannerDisplayed = false
        relayoutViews()
    }
    
    func bannerViewActionDidFinish(banner: ADBannerView!) {
        print("bannerViewActionDidFinish")
        bannerDisplayed = false
        relayoutViews()
    }
    
    func bannerViewActionShouldBegin(banner: ADBannerView!, willLeaveApplication willLeave: Bool) -> Bool {
        print("bannerViewActionShouldBegin")
        return true;
    }
    
    //FMDB
    func showDemo(sender:UIButton!) {
        loadRequestAllowed = false
        let demoVC = FMDBDemoViewController()
        let navVC = UINavigationController(rootViewController: demoVC)
        let backButton = UIBarButtonItem(title: "Close", style: .Plain, target: self, action: "back")
        demoVC.navigationItem.setLeftBarButtonItem(backButton, animated: true)
        
        self.presentViewController(navVC, animated: true, completion: nil)
    }
    
    func back() {
        loadRequestAllowed = true
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //CoreData
    func showCoreDataDemo(sender:UIButton!) {
        loadRequestAllowed = false
        let demoVC = CoreDataDemoViewController()
        let navVC = UINavigationController(rootViewController: demoVC)
        let backButton = UIBarButtonItem(title: "Close", style: .Plain, target: self, action: "back")
        demoVC.navigationItem.setLeftBarButtonItem(backButton, animated: true)
        
        self.presentViewController(navVC, animated: true, completion: nil)
    }
}

