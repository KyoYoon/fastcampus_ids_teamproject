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

//public typealias HTTPHeaders = [String: String]

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
        
        if LoginDataCenter.shared.requestIsLogin() == false && LoginDataCenter.shared.myLoginInfo == nil { // 로그아웃된 상태
            
            // do nothing
            self.userName = ""
            self.token = ""
            
        } else { // 로그인 중
            
            if LoginDataCenter.shared.myLoginInfo != nil { // 앱을 처음 실행해서 제대로 정보가 myLoginInfo에 들어간 상태
                
                self.userName = LoginDataCenter.shared.myLoginInfo?.nickname
                self.token = LoginDataCenter.shared.myLoginInfo?.token
                
            } else { // 앱이 중간에 종료되어서 미리 저장해둔 UserDefaults의 dictionary 정보를 이용해야 될 때
                
                print("UserDefaults is needed!")
                
                
                var dic:[String:Any] = UserDefaults.standard.dictionary(forKey: Authentication.userInfo)!
                
                self.userName = dic["nickname"] as? String
                self.token = dic["token"] as? String
                
                print("self.userName: ",self.userName ?? "none")
                print("self.token: ",self.token ?? "none")

                
            }
            
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //showLoginStatusFirebase()
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
    
    // 로그인 상태 판단하여 로그아웃된 상태면 로그인 페이지를 띄우고 아니면 현재 페이지에 데이터를 채워넣는다.
    func showLoginStatusAlamofire() {
        
        print("------------------ showLoginStatusAlamofire() -------------------")
        
        print("LoginDataCenter.shared.requestIsLogin(): ",LoginDataCenter.shared.requestIsLogin())
        print("LoginDataCenter.shared.myLoginInfo: ",LoginDataCenter.shared.myLoginInfo ?? "no data in myLoginInfo")
        
        // 로그인상태가 아니고 현재 데이터 센터에 값이 비어있다면 로그인 페이지를 띄운다. 
        if LoginDataCenter.shared.requestIsLogin() == false && LoginDataCenter.shared.myLoginInfo == nil {
            showLoginVC()
        }
        else { // UserDefaults에 저장된 값을 가지고 데이터를 가지고 오고 화면을 구성한다.
            
            self.displayedUserName.text = self.userName
            
            print("UserDefaults is needed!")
            
        }
        
    }
    
    func showLoginVC() {
        
        if let viewController = self.storyboard?.instantiateViewController(withIdentifier: "Login") {
            
            print("login page")
            
            self.present(viewController, animated: false, completion: nil)
        }

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func touchUpInsideProfileEditButton(_ sender: UIButton) {
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ProfileEdit")
        self.present(vc!, animated: true, completion: nil)
        
    }
    
    // 상태 구분
    @IBAction func touchUpInsideLogoutButton(_ sender: UIButton) {
        
        // 정상적으로 로그아웃된 상태
        if LoginDataCenter.shared.myLoginInfo != nil {
            
            logoutFromBackendServer(with: (LoginDataCenter.shared.myLoginInfo?.token)!)
            
        } else { // 앱을 껐다가 다시 켜서 로그아웃된 상태
            
            // UserDefaults.standard.setValue(LoginDataCenter.shared.myLoginInfo?.token, forKey: Authentication.token)
            
            logoutFromBackendServer(with: UserDefaults.standard.string(forKey: Authentication.token)!)
            
        }
        
        
        
        
        
        
        
        
        //logoutFromFirebase()
    }
    
    // 로그아웃 처리 로직 
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
                    
                    // statusCode가 200이 아니라면 에러 메시지를 뿌리고 롤백한다.
                    let statusCode = (response.response?.statusCode)!
                    print("...HTTP code: \(statusCode)")
                    
                    if statusCode == 202 { // 로그아웃 성공
                        
                        print(json["detail"].stringValue)
                        
                        self.displayLogoutConfirmMessageAndBackToLoginView(vc: self, title: "Logout Success", messageToDisplay: json["detail"].stringValue)
                        
                    } else {
                        
                        print(json["detail"].stringValue)
                        
                        self.displayLogoutFailMessageAndBackToLoginView(vc: self, title: "Logout Error", messageToDisplay: json["detail"].stringValue)
                        
                    }
                    
                    break
                case .failure(let error):
                    
                    UserDefaults.standard.setValue(true, forKey: Authentication.isLoginSucceed)
                    
                    print(error)
                    self.displayLogoutFailMessageAndBackToLoginView(vc: self, title: "Logout Error", messageToDisplay: error.localizedDescription)
                    
                    break
                }

        
        
        }
        
        
        
    }
    
    // 로그아웃 성공했을 때 (토큰이 유효할 때) => 로그아웃 처리하고 Login 화면을 보여준다.
    func displayLogoutConfirmMessageAndBackToLoginView(vc: UIViewController, title: String, messageToDisplay: String)
    {
        let alertController = UIAlertController(title: title, message: messageToDisplay, preferredStyle: .alert)
        
        let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
            
            // Code in this block will trigger when OK button tapped.
            print("OK button tapped");
            
            // pk 초기화 (UserDefaults)
            UserDefaults.standard.setValue(nil, forKey: Authentication.pk)
            
            // token 초기화 (UserDefaults)
            UserDefaults.standard.setValue(nil, forKey: Authentication.token)
            
            // UserDefaults에 저장된 userInfo 초기화
            LoginDataCenter.shared.initializeUserInfoInUserDefault()
            
            // 로그온 상태 false로 셋팅
            UserDefaults.standard.setValue(false, forKey: Authentication.isLoginSucceed)
            
            self.showLoginVC()
            
        }
        
        alertController.addAction(OKAction)
        
        vc.present(alertController, animated: true, completion:nil)
        
    }

    // 로그아웃 실패했을 때 (토큰이 유효하지 않을 때) -> 로그아웃처리하고 Login 화면을 보여준다.
    func displayLogoutFailMessageAndBackToLoginView(vc: UIViewController, title: String, messageToDisplay: String)
    {
        let alertController = UIAlertController(title: title, message: messageToDisplay, preferredStyle: .alert)
        
        let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
            
            // Code in this block will trigger when OK button tapped.
            print("OK button tapped");
            
            // pk 초기화 (UserDefaults)
            UserDefaults.standard.setValue(nil, forKey: Authentication.pk)
            
            // token 초기화 (UserDefaults)
            UserDefaults.standard.setValue(nil, forKey: Authentication.token)
            
            // UserDefaults에 저장된 userInfo 초기화
            LoginDataCenter.shared.initializeUserInfoInUserDefault()
            
            // 로그온 상태 false로 셋팅
            UserDefaults.standard.setValue(false, forKey: Authentication.isLoginSucceed)
            
            self.showLoginVC()
            
        }
        
        alertController.addAction(OKAction)
        
        vc.present(alertController, animated: true, completion:nil)
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
