//
//  AppDelegate.swift
//  MyMediaPlayer
//
//  Created by wuweixin on 2019/7/8.
//  Copyright © 2019 cn.wessonwu. All rights reserved.
//

import UIKit
import MTDNavigationView

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var viewController: MMTabBarController?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        let window = UIWindow(frame: UIScreen.main.bounds)
        self.window = window
        window.backgroundColor = UIColor.white
        setupViewControllers()
        window.rootViewController = self.viewController
        window.makeKeyAndVisible()
        
        customizeInterface()
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

extension AppDelegate {
    func setupViewControllers() {
        let firstVC = FirstViewController()
        firstVC.title = "First"
        
        let secondVC = SecondViewController()
        secondVC.title = "Second"
        
        let thirdVC = ThirdViewController()
        thirdVC.title = "Third"
        
        let tabBarController = MMTabBarController()
        tabBarController.tabBarViewControllers = [MTDWrapperController(contentViewController: firstVC),
                                                  MTDWrapperController(contentViewController: secondVC),
                                                  MTDWrapperController(contentViewController: thirdVC)]
        self.viewController = tabBarController
        
        customizeTabBarForController(tabBarController)
    }
    
    
    func customizeTabBarForController(_ tabBarController: MMTabBarController) {
//        let finishedImage = UIImage(named: "tabbar_selected_background")
//        let unfinishedImage = UIImage(named: "tabbar_normal_background")
        
        let tabBarItemImages = ["first", "second", "third"]
        for (index, item) in tabBarController.tabBar.items.enumerated() {
//            item.backgroundSelectedImage = finishedImage
//            item.backgroundUnselectedImage = unfinishedImage
            let named = tabBarItemImages[index]
            item.finishedSelectedImage = UIImage(named: "\(named)_selected")
            item.finishedUnselectedImage = UIImage(named: "\(named)_normal")
        }
        
        //        let tabBar = tabBarController.tabBar
        //        if #available(iOS 11.0, *) {
        //            let safeAreaBottom = self.window?.safeAreaInsets.bottom ?? 0
        //            tabBar.height = safeAreaBottom + 49
        //            tabBar.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: safeAreaBottom, right: 0)
        //        } else {
        //            tabBar.height = 49
        //        }
    }
    
    
    func customizeInterface() {
        let navBar = UINavigationBar.appearance()
        navBar.isTranslucent = false
        let backgroundImage = UIImage(named: "navigationbar_background_tall")
        let textAttributes: [NSAttributedString.Key: Any] = [.font: UIFont.boldSystemFont(ofSize: 18),
                                                             .foregroundColor: UIColor.black]
        navBar.setBackgroundImage(backgroundImage, for: .default)
        navBar.titleTextAttributes = textAttributes
    }
}

