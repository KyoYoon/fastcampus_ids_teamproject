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

class LoginDataCenter {
    
    static let shared = LoginDataCenter()
    
    var myLoginInfo:MyLoginInfo?
    
    var isLogin:Bool = false
    
    
    
    
    func requestIsLogin() -> Bool {
        
        // 로그온이 된 상태인지 아닌지 판단해서 리턴값을 반환한다. 세션 판단 
        // 서버 사이드에서 rest api로 판단하는 게 좋은데 일단 지금은 임시방편으로 이렇게 처리하기로 함
        let isLoginSucceed:Bool = UserDefaults.standard.bool(forKey: Authentication.isLoginSucceed)
        
        if isLoginSucceed == true {
            self.isLogin = true
            return true
        } else {
            self.isLogin = false
            return false
        }
        
        
    }
    
    func parseMyLoginInfo(with dic:JSON) {
        
        self.myLoginInfo = MyLoginInfo.init(data: dic)
        
    }
    
    func requestUserData(with pk:Int) {
        
        // pk 가 5인 사용자 정보 호출 URL
        // https://weather-sound.com/api/member/5/
        
        // 현재 로그온 세션이 유지되지 않은 경우 바로 실행을 중지하고 return 한다.
        //guard let uid = Auth.auth().currentUser?.uid else { return }
        
        // 사용자 정보를 획득
        
        
//        Alamofire.request(url, method: .get).validate().responseJSON { response in
//            switch response.result {
//            case .success(let value):
//                let json = JSON(value)
//                print("JSON: \(json)")
//                
//                
//            case .failure(let error):
//                print(error)
//            }
//        }
        
//        Database.database().reference().child(uid).child("UserInfo").observeSingleEvent(of: .value, with: { (snapshot) in
//            
//            let dic = snapshot.value as! [String:Any]
//            
//            completion(MyLoginInfo(data: dic))
//        })
        
        // 알라모파이어로 요청해서 현재 유저에 대한 데이터를 가지고 온다.. 
        
        
        
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
    var nickname:String?
    var img_profile:String?
    
    
    init(data:JSON) {
        
//        self.token = data["token"] as? String ?? ""
//        self.userInfo = data["UserInfo"] as? [[String:Any]] ?? nil
//        
//        if self.userInfo == nil {
//            self.is_active = false
//        } else {
//            self.is_active = true
//            
//            self.pk = self.userInfo?[0]["pk"] as? Int
//            self.email = self.userInfo?[0]["email"] as? String
//            self.nickname = self.userInfo?[0]["nickname"] as? String
//            self.img_profile = self.userInfo?[0]["img_profile"] as? String
//            
//            
//            
//        }
        
        self.token = data["token"].stringValue
        self.pk = data["UserInfo"][0]["pk"].intValue
        self.email = data["UserInfo"][0]["email"].stringValue
        self.nickname = data["UserInfo"][0]["username"].stringValue
        self.img_profile = data["UserInfo"][0]["img_profile"].stringValue
        
        
    }

    
    
    
}
