//
//  AppDelegate.swift
//  chess20
//
//  Created by Dimic Milos on 4/13/17.
//  Copyright © 2017 G11. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // Svaki put kad se promeni orijentacija uredjaja ova funkcija poziva func rotated
        NotificationCenter.default.addObserver(self, selector: #selector(AppDelegate.rotated), name: UIDevice.orientationDidChangeNotification, object: nil)
        
        return true
    }
    
    @objc func rotated() {
        if  UIDevice.current.orientation.isLandscape {
            print("JUST ROTATED to Landscape")
        }
        
        if  UIDevice.current.orientation.isPortrait {
            print("JUST ROTATED to Portrait")
        }
        dummie?.UpdateScreenForNewArrangment()
    }
    

}

