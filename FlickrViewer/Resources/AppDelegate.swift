//
//  AppDelegate.swift
//  FlickrViewer
//
//  Created by Anton Makarov on 2/13/19.
//  Copyright © 2019 TecSynt Solutions. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        configureWindow()
        return true
    }
    
    private func configureWindow() {
        self.window = UIWindow(frame: UIScreen.main.bounds)
        let navigation = UINavigationController()
        navigation.isNavigationBarHidden = true
        self.window?.rootViewController = navigation
        self.window?.makeKeyAndVisible()
        MainCoordinator(navigation).start()
    }
}
