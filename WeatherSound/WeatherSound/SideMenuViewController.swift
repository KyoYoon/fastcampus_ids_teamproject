//
//  SideMenuViewController.swift
//  WeatherSound
//
//  Created by HyunJomi on 2017. 8. 11..
//  Copyright © 2017년 정교윤. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import FBSDKLoginKit

class SideMenuViewController: UIViewController, UIViewControllerTransitioningDelegate {

    @IBOutlet weak var menuContainerView: UIView!
    @IBOutlet weak var homeBtn: UIButton!
    @IBOutlet weak var logoutBtn: UIButton!
    @IBOutlet weak var editProfile: UIButton!
    
    var token:String?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 로그아웃 상태면 로그아웃 버튼이 안 보이게 함
        if LoginDataCenter.shared.requestIsLogin() == false && LoginDataCenter.shared.myLoginInfo == nil {
            
            self.logoutBtn.isHidden = true
            
        } else { // 로그인 상태면 토큰 가져오기 
            
            if LoginDataCenter.shared.myLoginInfo != nil {
                
                self.token = LoginDataCenter.shared.myLoginInfo?.token
                
            } else {
                
                self.token = UserDefaults.standard.string(forKey: Authentication.token)
                
            }
            
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .clear
 
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer()
        tapGesture.addTarget(self, action: #selector(tapGestureHandler))
        self.view.addGestureRecognizer(tapGesture)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        
//        let rect = self.view.frame
        let rect = UIScreen.main.bounds
        self.menuContainerView.frame = CGRect(x: rect.width*0.4, y: 0, width: rect.width*0.6, height: rect.height)
        
        self.homeBtn.frame = CGRect(x: 20, y: 100, width: self.menuContainerView.frame.width, height: 50)
        self.editProfile.frame = CGRect(x: 20, y: self.homeBtn.frame.maxY+10, width: self.menuContainerView.frame.width, height: 50)
        self.logoutBtn.frame = CGRect(x: 20, y: self.editProfile.frame.maxY+10, width: self.menuContainerView.frame.width, height: 50)
        
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        self.transitioningDelegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    @IBAction func homeBtnTouched(_ sender: UIButton) {
        
        self.dismiss(animated: true, completion: {
            let window: UIWindow = ((UIApplication.shared.delegate?.window)!)!
            let container: UIViewController = window.rootViewController!
            let naviCon: UINavigationController = container.childViewControllers[0] as! UINavigationController
            naviCon.viewControllers = [naviCon.viewControllers[0]]
        })
        
    }
    
    func moveToContainerView() {
        
        // Story ID: ContainerView
        let viewController:UIViewController = UIStoryboard(name: "DY", bundle: nil).instantiateViewController(withIdentifier: "ContainerView") as UIViewController
 
        self.present(viewController, animated: false, completion: nil)
        
    }
    
    // 로그아웃 처리 로직
    func logoutFromBackendServer(with token:String) {
        
        //UserDefaults.standard.setValue(true, forKey: Authentication.isFacebookLogin)
        
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
        
//        let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
        
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
            
            // facebook 로그온으로 되어있다면 facebook 로그아웃을 시킨다.
            if UserDefaults.standard.bool(forKey: Authentication.isFacebookLogin) == true {
                
                print("------ facebook logout -----")
                
                UserDefaults.standard.setValue(false, forKey: Authentication.isFacebookLogin)
                FBSDKLoginManager().logOut()
                
            }
            
            // 로그인 화면으로 이동
            //self.showLoginVC()
            
            // Container View Controller로 이동
//            self.moveToContainerView()
            
            self.dismiss(animated: true, completion: {
                
                let window: UIWindow = ((UIApplication.shared.delegate?.window)!)!
                let container: UIViewController = window.rootViewController!
                let naviCon: UINavigationController = container.childViewControllers[0] as! UINavigationController
                naviCon.viewControllers = [naviCon.viewControllers[0]]
            })
            
            
            //self.navigationController?.popToRootViewController(animated: true)
            
//        }
        
//        alertController.addAction(OKAction)
        
//        vc.present(alertController, animated: true, completion:nil)
        
    }
    
    // 로그아웃 실패했을 때 (토큰이 유효하지 않을 때) -> 로그아웃처리하고 Login 화면을 보여준다.
    func displayLogoutFailMessageAndBackToLoginView(vc: UIViewController, title: String, messageToDisplay: String)
    {
        let alertController = UIAlertController(title: title, message: messageToDisplay, preferredStyle: .alert)
        
//        let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
        
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
            
            // facebook 로그온으로 되어있다면 facebook 로그아웃을 시킨다.
            if UserDefaults.standard.bool(forKey: Authentication.isFacebookLogin) == true {
                
                print("------ facebook logout -----")
                
                UserDefaults.standard.setValue(false, forKey: Authentication.isFacebookLogin)
                FBSDKLoginManager().logOut()
                
            }
            
            // 로그인 화면으로 이동
            //self.showLoginVC()
            
            // Container View Controller로 이동
//            self.moveToContainerView()
//            self.dismiss(animated: true, completion: nil)

            //self.navigationController?.popToRootViewController(animated: true)
            self.dismiss(animated: true, completion: {
                
                let window: UIWindow = ((UIApplication.shared.delegate?.window)!)!
                let container: UIViewController = window.rootViewController!
                let naviCon: UINavigationController = container.childViewControllers[0] as! UINavigationController
                naviCon.viewControllers = [naviCon.viewControllers[0]]
            })

            
//        }
        
//        alertController.addAction(OKAction)
        
//        vc.present(alertController, animated: true, completion:nil)
    }

    
    @IBAction func logOutBtonTouched(_ sender: UIButton) {
        
        logoutFromBackendServer(with: self.token!)
        
    }
    
    @IBAction func editProfileBtnTouched(_ sender: UIButton) {
        
        // ProfileEdit View Controller로 이동
        let viewController:UIViewController = UIStoryboard(name: "LoginAndSignup", bundle: nil).instantiateViewController(withIdentifier: "ProfileEdit") as UIViewController
        
        self.present(viewController, animated: false, completion: nil)
        
    }
    
    let myTansitioning: SideMenuTransition = SideMenuTransition()
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.myTansitioning.isPresent = true
        return self.myTansitioning
    }
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.myTansitioning.isPresent = false
        return self.myTansitioning
    }
    
    func tapGestureHandler(){
        self.dismiss(animated: true, completion: nil)
    }
    
}

