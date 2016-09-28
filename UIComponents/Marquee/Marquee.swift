//
//  Marquee.swift
//  Copyright (c) 2015 Du Limin. All rights reserved.
//

import UIKit

class Marquee {
    init(superview:UIView, text:String) {
        createMarquee(superview, text:text)
    }
    
    func createMarquee(_ superview:UIView, text:String) {
        let tf = TextFlowView(frame: CGRect(x:0,y:0,width:320,height:40), text: text)
        
        tf?.translatesAutoresizingMaskIntoConstraints = false
        tf?.backgroundColor = UIColor.clear
        tf?.tintColor = UIColor.white
        superview.addSubview(tf!)
        
        let topConstraint = NSLayoutConstraint(item:tf!,
            attribute:.bottom,
            relatedBy:.equal,
            toItem:superview,
            attribute:.bottom,
            multiplier:1.0,
            constant:-50.0
        )
        superview.addConstraint(topConstraint)
        
        let leftConstraint = NSLayoutConstraint(item:tf!,
            attribute:.leading,
            relatedBy:.equal,
            toItem:superview,
            attribute:.leading,
            multiplier:1.0,
            constant:0.0
        )
        superview.addConstraint(leftConstraint)
        
        let rightConstraint = NSLayoutConstraint(item:tf!,
            attribute:.trailing,
            relatedBy:.equal,
            toItem:superview,
            attribute:.trailing,
            multiplier:1.0,
            constant:0.0
        )
        superview.addConstraint(rightConstraint)
        
        let heightConstraint = NSLayoutConstraint(item:tf!,
            attribute:.height,
            relatedBy:.equal,
            toItem:nil,
            attribute:.notAnAttribute,
            multiplier:1.0,
            constant:40.0
        )
        superview.addConstraint(heightConstraint)
    }
}
