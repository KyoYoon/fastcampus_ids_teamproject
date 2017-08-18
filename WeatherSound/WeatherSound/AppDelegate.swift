//
//  AppDelegate.swift
//  WeatherSound
//
//  Created by 정교윤 on 2017. 7. 28..
//  Copyright © 2017년 정교윤. All rights reserved.
//

import UIKit
import Firebase
import FBSDKCoreKit
import Alamofire
import SwiftyJSON

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // Firebase 기본 셋팅
        FirebaseApp.configure()
        
        // Facebook 기본 셋팅 
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        return true
    }
    
    // Facebook 기본 셋팅
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        let handled = FBSDKApplicationDelegate.sharedInstance().application(app, open: url, options: options)
        
        return handled
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        // 로그아웃 처리 로직 삽입 예정
        print("applicationDidEnterBackground")
        //UserDefaults.standard.setValue(false, forKey: Authentication.isLoginSucceed)
        //LoginDataCenter.shared.myLoginInfo = nil
        //logoutFromBackendServer(with: (LoginDataCenter.shared.myLoginInfo?.token)!)
        
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        
        // 로그아웃 처리 로직 삽입 예정
        //logoutFromBackendServer(with: (LoginDataCenter.shared.myLoginInfo?.token)!)
        //UserDefaults.standard.setValue(false, forKey: Authentication.isLoginSucceed)
        
        // 유저 디폴트에 딕셔너리로 저장 
        
    }
    
    func logoutFromBackendServer(with token:String) {
        
        let headers: HTTPHeaders = [
            "Authorization": "Token "+token,
            "Accept": "application/json"
        ]
        
        
        
        Alamofire.request(Authentication.logoutURL, headers: headers)
            .responseJSON { response in
                
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    
                    // 데이터 초기화
                    LoginDataCenter.shared.myLoginInfo = nil
                    
                    print(json)
                    
                    //let successMsg = json["detail"].stringValue
                    
                    UserDefaults.standard.setValue(false, forKey: Authentication.isLoginSucceed)
                    
                    //                    CommonLibraries.sharedFunc.displayAlertMessage(vc: self, title: "Logout", messageToDisplay: successMsg)
                    
                    // move to login vc
                    //self.showLoginVC()
                    
                    break
                case .failure(let error):
                    
                    UserDefaults.standard.setValue(true, forKey: Authentication.isLoginSucceed)
                    
                    print(error)
                    //CommonLibraries.sharedFunc.displayAlertMessage(vc: self, title: "Error", messageToDisplay: error.localizedDescription)
                    
                    break
                }
                
                
                
        }
        
        
        
    }
    


}

