//
//  HomeViewController.swift
//  WeatherSound
//
//  Created by 정교윤 on 2017. 8. 4..
//  Copyright © 2017년 정교윤. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FBSDKLoginKit
import Alamofire
import SwiftyJSON

public typealias HTTPHeaders = [String: String]

class HomeViewController: UIViewController {
    
    @IBOutlet weak var displayedUserName: UILabel!
    var userName:String?
    var token:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        

        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        self.displayedUserName.text = self.userName
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
        
        showLoginStatusAlamofire()
        
    }
    
    func showLoginStatusFirebase() {

        if let currentUser = Auth.auth().currentUser {
            print("displayName",currentUser.displayName)
            
            self.displayedUserName.text = currentUser.displayName ?? currentUser.email
            
            
        } else {
            print("로그인 페이지 보여줘야 함 ")
            if let viewController = self.storyboard?.instantiateViewController(withIdentifier: "Login") {
                
                print("login page")
                
                self.present(viewController, animated: true, completion: nil)
            }
            
        }
        
    }
    
    func showLoginStatusAlamofire() {
        
        // 백엔드 서버쪽에 요청해서 로그인 중인지 상태파악을 해야 되는데 
        // 현재는 UserDefault 변수로 임시로 처리 중 
        
        if LoginDataCenter.shared.requestIsLogin() == false && LoginDataCenter.shared.myLoginInfo == nil {
            showLoginVC()
        }
        
    }
    
    func showLoginVC() {
        
        if let viewController = self.storyboard?.instantiateViewController(withIdentifier: "Login") {
            
            print("login page")
            
            self.present(viewController, animated: true, completion: nil)
        }

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func touchUpInsideLogoutButton(_ sender: UIButton) {
        
        logoutFromBackendServer(with: self.token!)
        //logoutFromFirebase()
    }
    
    func logoutFromBackendServer(with token:String) {
        
        var isLogoutSucceed = false
        
        let headers: HTTPHeaders = [
            "Authorization": "Token "+token,
            "Accept": "application/json"
        ]
        
        Alamofire.request(Authentication.logoutURL, headers: headers)
            .responseJSON { response in
                
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    
                    let successMsg = json["detail"].stringValue
                    
                    CommonLibraries.sharedFunc.displayAlertMessage(vc: self, title: "Logout", messageToDisplay: successMsg)
                    
                    isLogoutSucceed = true
                    
                    break
                case .failure(let error):
                    
                    print(error)
                    CommonLibraries.sharedFunc.displayAlertMessage(vc: self, title: "Error", messageToDisplay: error.localizedDescription)
                    
                    break
                }

        
        
        }
        
        if isLogoutSucceed == true {
            
            UserDefaults.standard.setValue(false, forKey: Authentication.isLoginSucceed)
            
            // 데이터 초기화 
            LoginDataCenter.shared.myLoginInfo = nil
            
            // Login View로 이동
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "Login")
            self.present(vc!, animated: true, completion: nil)
            
        } else {
            
            UserDefaults.standard.setValue(true, forKey: Authentication.isLoginSucceed)
            
        }
        
    }
    
    
    func logoutFromFirebase() {
        
        // logout
        do {
            try Auth.auth().signOut()
            //FBSDKLoginManager().logOut()
            
            // 데이터 초기화
            
            
            // 로그인 페이지로 이동
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "Login")
            self.present(vc!, animated: true, completion: nil)
            
        }catch {
            
        }

        
    }
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
