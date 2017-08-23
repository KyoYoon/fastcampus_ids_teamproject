//
//  LoginDataCenter.swift
//  WeatherSound
//
//  Created by 정교윤 on 2017. 8. 9..
//  Copyright © 2017년 정교윤. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import UIKit

public typealias HTTPHeaders = [String: String]

class LoginDataCenter {
    
    static let shared = LoginDataCenter()
    
    var myLoginInfo:MyLoginInfo?
    
    
    var isLogin:Bool = false
    
    // 로그온 상태 체크
    func requestIsLogin() -> Bool {
        
        // 로그온이 된 상태인지 아닌지 판단해서 리턴값을 반환한다. 세션 판단 
        // 서버 사이드에서 rest api로 판단하는 게 좋은데 일단 지금은 임시방편으로 이렇게 처리하기로 함
        var isLoginSucceed:Bool?
        
        isLoginSucceed = UserDefaults.standard.bool(forKey: Authentication.isLoginSucceed)
        
        print("isLoginSucceed: ",isLoginSucceed ?? "false")
        
        if isLoginSucceed == true {
            self.isLogin = true
            return true
        } else {
            self.isLogin = false
            return false
        }
        
        
    }
    
    // 로그인 후 사용자 정보를 요청하면서 계속 로그인 체크하고 사용자 정보 업데이트 (서버와의 통신에 실패하는 즉시 로그인 페이지 보여주기)
    // 프로필 페이지와 같이 로그온 정보가 있어야 접근할 수 있는 페이지에 한해 이 함수를 호출하여 서버와 통신하고 성공하면 정보 가져오고
    // 실패하면 바로 로그인 페이지를 띄운다.
    func requestUserInfoFromServer(with pk:Int, token:String, comletion: (()->Void)?) {
        
        print("---------------  requestUserInfoFromServer  -------------")
        
        let headers: HTTPHeaders = [
            "Authorization": "Token "+token,
            "Accept": "application/json"
        ]

        // pk에 맞는 유저 정보를 가지고 온다.
        // 예) pk 가 5인 사용자 정보 호출 URL
        // https://weather-sound.com/api/member/profile/5
        
        // 사용자 정보를 획득하면서 기존 정보 초기화 및 새로 업데이트를 한다. 
        let url:String = Authentication.baseUserInfoURL + String(pk) + "/"
        
//        Alamofire.request(url).responseJSON { response in
//            switch response.result {
//            case .success(let value):
//                let json = JSON(value)
//                print("JSON: \(json)")
//                UserDefaults.standard.setValue(true, forKey: Authentication.isLoginSucceed)
//                self.updateMyLoginInfo(with: json)
//            case .failure(let error):
//                print(error)
//                UserDefaults.standard.setValue(false, forKey: Authentication.isLoginSucceed)
//                self.showLoginVC(vc: vc)
//            }
//        }
        
        Alamofire.request(url, method: .get, parameters: nil, encoding: URLEncoding.default, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                print("JSON: \(json)")
                
                // 토큰, pk, 로그인 상태 저장 - <난수> / <1자리 정수> / true
                UserDefaults.standard.setValue(pk, forKey: Authentication.pk)
                UserDefaults.standard.setValue(token, forKey: Authentication.token)
                
                UserDefaults.standard.setValue(true, forKey: Authentication.isLoginSucceed)
                //self.updateMyLoginInfo(with: json)
                self.parseMyLoginInfo(with: json)
                comletion?()
            case .failure(let error):
                print(error)
                
                // 토큰, pk, 로그인 상태 초기화 - nil / nil / false
                UserDefaults.standard.setValue(nil, forKey: Authentication.pk)
                UserDefaults.standard.setValue(nil, forKey: Authentication.token)
                
                UserDefaults.standard.setValue(false, forKey: Authentication.isLoginSucceed)
                self.myLoginInfo = nil
                
                // 창을 띄우고 강제 로그아웃 처리
                
                //self.showLoginVC(vc: vc)
                
                
                
            }
        }
        
        
        //self.myLoginInfo = nil
        
        
        
    }
    
    // 프로필 페이지로 접근할 때 백엔드와의 서버 통신 실패시 로그인 페이지 보여주기
    func showLoginVC(vc:UIViewController) {
        
        if let viewController = vc.storyboard?.instantiateViewController(withIdentifier: "Login") {
            
            print("login page")
            
            vc.present(viewController, animated: true, completion: nil)
        }
        
        
    }
    
    
    // 최초 로그인 후 사용자 로그인 정보 생성
    func parseMyLoginInfo(with dic:JSON) {
        
        self.myLoginInfo = MyLoginInfo.init(data: dic)
        
    }
    
    
    
    
    // 로그온 후 프로필 페이지에 접근하여 수정할 때 기본 사용자 로그인 정보를 업데이트 => pk 와 token은 그대로 유지
    func updateMyLoginInfo(with dic:JSON, token:String) {
        
        print("------------------ updateMyLoginInfo --------------------")
        
        self.myLoginInfo?.token = token
        print("token: ",self.myLoginInfo!.token!)
        self.myLoginInfo?.pk = dic["userInfo"]["pk"].intValue
        print("pk: ",self.myLoginInfo!.pk!)
        self.myLoginInfo?.email = dic["userInfo"]["username"].stringValue
        print("email: ",self.myLoginInfo!.email!)
        self.myLoginInfo?.nickname = dic["userInfo"]["nickname"].stringValue
        print("nickname: ",self.myLoginInfo!.nickname!)
        self.myLoginInfo?.img_profile = dic["userInfo"]["img_profile"].stringValue
        print("img_profile: ",self.myLoginInfo!.img_profile!)
        self.myLoginInfo?.password = dic["userInfo"]["password"].stringValue
        print("password: ",self.myLoginInfo!.password!)
        self.myLoginInfo?.is_active = dic["userInfo"]["is_active"].boolValue
        print("is_active: ",self.myLoginInfo!.is_active!)
        self.myLoginInfo?.is_admin = dic["userInfo"]["is_admin"].boolValue
        print("is_admin: ",self.myLoginInfo!.is_admin!)
        
    }
    
    // 로그아웃되지 않은 상태에서 앱이 종료되거나 재시작하는 경우를 대비하여 UserDefaults에 dictionary형태로 저장해놓는다. 
    // 로그아웃되면 지운다.
    func saveMyLoginInfoInUserDefault(myLoginInfo:MyLoginInfo) {
        
        var dic:[String:Any] = [:]
        
        dic.updateValue(myLoginInfo.token!, forKey: "token")
        dic.updateValue(myLoginInfo.pk!, forKey: "pk")
        dic.updateValue(myLoginInfo.email!, forKey: "username")
        dic.updateValue(myLoginInfo.nickname!, forKey: "nickname")
        dic.updateValue(myLoginInfo.password!, forKey: "password")
        dic.updateValue(myLoginInfo.img_profile!, forKey: "img_profile")
        dic.updateValue(myLoginInfo.is_admin!, forKey: "is_admin")
        dic.updateValue(myLoginInfo.is_active!, forKey: "is_active")
        
        UserDefaults.standard.setValue(dic, forKey: Authentication.userInfo)
        
    }
    
    
    // 로그아웃되면 UserDefaults에 저장된 dictionary의 값을 지운다.
    func initializeUserInfoInUserDefault() {
        
        UserDefaults.standard.setValue(nil, forKey: Authentication.userInfo)
        
    }
    
    
}

struct MyLoginInfo {
    
    // 로그인했을 때 받아오는 JSON 구조
//    {
//      "token": "2c02bb2891d7652958abc577ed6c67a9744f6821",
//      "UserInfo": [
//          {
//              "pk": 5,
//              "email": "kyoyoon@bbbb.com",
//              "username": "정교윤",
//              "img_profile": "https://s3.ap-northeast-2.amazonaws.com/weather-sound-test-s3-bucket/media/member/basic_profile.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAIUNOVI4KACUE6OMQ%2F20170809%2Fap-northeast-2%2Fs3%2Faws4_request&X-Amz-Date=20170809T052231Z&X-Amz-Expires=3600&X-Amz-SignedHeaders=host&X-Amz-Signature=688bf7aa9c0a4fba3c2ec5985e81d442e0d42ac0b2edbba210cffaae415b8abf"
//          }
//      ]
//    }
    
    // 로그인된 상태에서 로그인했을 때 나오는 메시지 
    
    
    var token:String?
    
    var pk:Int?
    var email:String?
    var password:String?
    var nickname:String?
    var img_profile:String?
    var is_active:Bool?
    var is_admin:Bool?
    
    // "is_active"
    
    
    init(data:JSON) {
        
        // 로그인 성공시 가져오는 JSON 구조
//        {
//            "token": "71c81443a6f8a065f424c7ac7d13ceb20d4cd47f",
//            "userInfo": {
//                "pk": 47,
//                "email": "eraka34455@cccc.com",
//                "username": "eraka",
//                "img_profile": "https://s3.ap-northeast-2.amazonaws.com/weather-sound-test-s3-bucket/media/member/basic_profile.png",
//                "password": "pbkdf2_sha256$36000$UaFTWXiLQVGZ$epc0MEr5A8kKwacz6KpLj8w+2M5uYv/AcXRtIM/VUW0=",
//                "is_active": true,
//                "is_admin": false
//            }
//        }
        
        
        print("----------MyLoginInfo----------")
        
        
        self.token = data["token"].stringValue
        print("token: ",self.token!)
        self.pk = data["userInfo"]["pk"].intValue
        print("pk: ",self.pk!)
        self.email = data["userInfo"]["username"].stringValue
        print("email: ",self.email!)
        self.nickname = data["userInfo"]["nickname"].stringValue
        print("nickname: ",self.nickname!)
        self.img_profile = data["userInfo"]["img_profile"].stringValue
        print("img_profile: ",self.img_profile!)
        self.password = data["userInfo"]["password"].stringValue
        print("password: ",self.password!)
        self.is_active = data["userInfo"]["is_active"].boolValue
        print("is_active: ",self.is_active!)
        self.is_admin = data["userInfo"]["is_admin"].boolValue
        print("is_admin: ",self.is_admin!)
        
    }

    
    
}
