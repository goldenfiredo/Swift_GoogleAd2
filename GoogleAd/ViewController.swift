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
    var timer:Timer?
    var loadRequestAllowed = true
    var statusbarHeight:CGFloat = 20.0
    var buttonHeight:CGFloat = 0.0
    var buttonOffsetY:CGFloat = 0.0
    let screen = UIScreen.main.bounds
    let IS_IPAD = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad
    let IS_iPhoneX = (UIScreen.main.bounds.size.width == 375 && UIScreen.main.bounds.size.height == 812)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        if IS_iPhoneX {
            statusbarHeight = 44.0
        }
        
        //iAdSupported = iAdTimeZoneSupported()
        iAdSupported = false //Apple has stopped iAd service
        
        if iAdSupported {
            iAdView = ADBannerView(adType: ADAdType.banner)
            iAdView?.frame = CGRect(x: 0, y: 0 - iAdView!.frame.height, width: iAdView!.frame.width, height: iAdView!.frame.height)
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
            timer = Timer.scheduledTimer(timeInterval: 40, target: self, selector: #selector(ViewController.GoogleAdRequestTimer), userInfo: nil, repeats: true)
        }
        
        //Admob Interstitial
        buttonHeight = IS_IPAD ? 30 : 20 //TODO:
        buttonOffsetY = statusbarHeight
        if !iAdSupported {
            interstitial = createAndLoadInterstitial()
        } else {
            buttonAd.isHidden = true;
        }
        
        _ = Marquee(superview: self.view , text: marqueeText)
        
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.AppBecomeActive), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.AppResignActive), name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.relayoutViews(false)
        
        self.view.makeToast("Ready for demo")
    }
    
    func scheduleRequest(_ wait:TimeInterval) {
        Timer.scheduledTimer(timeInterval: wait, target: self, selector: #selector(ViewController.GoogleAdRequestTimer), userInfo: nil, repeats: false)
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
        bannerView?.load(GADRequest())
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
    func adViewDidReceiveAd(_ view: GADBannerView!) {
        print("adViewDidReceiveAd");
        relayoutViews(true)
    }
    
    func adView(_ view: GADBannerView!, didFailToReceiveAdWithError error: GADRequestError!) {
        print("\(view) error:\(error)")
        relayoutViews(false)
    }
    
    func adViewWillPresentScreen(_ adView: GADBannerView!) {
        print("adViewWillPresentScreen")
        relayoutViews(false)
    }
    
    func adViewWillLeaveApplication(_ adView: GADBannerView!) {
        print("adViewWillLeaveApplication")
        relayoutViews(false)
    }
    
    func adViewWillDismissScreen(_ adView: GADBannerView!) {
        print("adViewWillDismissScreen")
        relayoutViews(false)
    }
    
    func adViewDidDismissScreen(_ bannerView: GADBannerView!) {
        print("adViewDidDismissScreen")
    }
    
    func relayoutViews(_ displayed:Bool) {
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
        interstitial.load(GADRequest())
        
        return interstitial
    }
    
    @IBAction func presentInterstitial(_ sender:UIButton!) {
        if let _ = interstitial?.isReady {
            interstitial?.present(fromRootViewController: self)
        }
    }
    
    //Interstitial delegate
    func interstitial(_ ad: GADInterstitial!, didFailToReceiveAdWithError error: GADRequestError!) {
        print("interstitialDidFailToReceiveAdWithError:\(error.localizedDescription)")
        buttonAd?.isEnabled = false
        interstitial = createAndLoadInterstitial()
    }
    
    func interstitialDidReceiveAd(_ ad: GADInterstitial!) {
        print("interstitialDidReceiveAd")
        buttonAd?.isEnabled = true
    }
    
    func interstitialWillDismissScreen(_ ad: GADInterstitial!) {
        print("interstitialWillDismissScreen")
        buttonAd?.isEnabled = false
        interstitial = createAndLoadInterstitial()
    }
    
    func interstitialDidDismissScreen(_ ad: GADInterstitial!) {
        print("interstitialDidDismissScreen")
        scheduleRequest(3)
    }
    
    func interstitialWillLeaveApplication(_ ad: GADInterstitial!) {
        print("interstitialWillLeaveApplication")
        relayoutViews(false)
    }
    
    func interstitialWillPresentScreen(_ ad: GADInterstitial!) {
        print("interstitialWillPresentScreen")
        relayoutViews(false)
    }
    
    
    //iAd func
    func iAdTimeZoneSupported()->Bool {
        let iAdTimeZones = "America/;US/;Pacific/;Asia/Tokyo;Europe/".components(separatedBy: ";")
        let myTimeZone = TimeZone.autoupdatingCurrent.identifier
        for zone in iAdTimeZones {
            if (myTimeZone.hasPrefix(zone)) {
                return true;
            }
        }
        
        return false;
    }
    
    //iAdBannerViewDelegate
    func bannerViewWillLoadAd(_ banner: ADBannerView!) {
        print("bannerViewWillLoadAd")
    }
    
    func bannerViewDidLoadAd(_ banner: ADBannerView!) {
        print("bannerViewDidLoadAd")
        relayoutViews(true)
    }
    
    func bannerView(_ banner: ADBannerView!, didFailToReceiveAdWithError error: Error!) {
        print("bannerViewDidFailToReceiveAd error:\(error)")
        relayoutViews(false)
    }
    
    func bannerViewActionDidFinish(_ banner: ADBannerView!) {
        print("bannerViewActionDidFinish")
        relayoutViews(false)
    }
    
    func bannerViewActionShouldBegin(_ banner: ADBannerView!, willLeaveApplication willLeave: Bool) -> Bool {
        print("bannerViewActionShouldBeginWillLeaveApplication")
        return true;
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        loadRequestAllowed = false
        if !iAdSupported {
            relayoutViews(false)
        }
    }
    
    @IBAction func unwindForSegue(_ unwindSegue: UIStoryboardSegue) {
        loadRequestAllowed = true
        
        scheduleRequest(3)
    }
}

