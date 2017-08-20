//
//  CommonLibraries.swift
//  WeatherSound
//
//  Created by 정교윤 on 2017. 8. 6..
//  Copyright © 2017년 정교윤. All rights reserved.
//

import Foundation
import UIKit

class CommonLibraries {
    
    static let sharedFunc = CommonLibraries()
    
    // 이메일 주소 유효성 검사
    func isValidEmailAddress(emailAddressString: String) -> Bool {
        
        // [A-Z0-9a-z.-_]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,3}
        var returnValue = true
        let emailRegEx = "[A-Z0-9a-z.-_]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,3}"
        
        do {
            let regex = try NSRegularExpression(pattern: emailRegEx)
            let nsString = emailAddressString as NSString
            let results = regex.matches(in: emailAddressString, range: NSRange(location: 0, length: nsString.length))
            
            if results.count == 0
            {
                returnValue = false
            }
            
        } catch let error as NSError {
            print("invalid regex: \(error.localizedDescription)")
            returnValue = false
        }
        
        return  returnValue
    }
    
    // 비밀번호 유효성 검사 - 8자리 이상, 대문자, 소문자, 숫자, 특수문자 반드시 포함
    func isPasswordValid(password: String) -> Bool{
        
        // ^.*(?=.*\d)(?=.*[a-zA-Z])(?=.*[!@#$%^&+=]).*$
        // ^(?=.*[A-Z])(?=.*[0-9])(?=.*[a-z]).{8}$
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[A-Z])(?=.*[0-9])(?=.*[a-z]).{8}$")
        return passwordTest.evaluate(with: password)
    }
    
    // 알럿 메시지 보여주기
    func displayAlertMessage(vc: UIViewController, title: String, messageToDisplay: String)
    {
        let alertController = UIAlertController(title: title, message: messageToDisplay, preferredStyle: .alert)
        
        let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
            
            // Code in this block will trigger when OK button tapped.
            print("Ok button tapped");
            
        }
        
        alertController.addAction(OKAction)
        
        vc.present(alertController, animated: true, completion:nil)
    }
    
    //거리 계산
    func distance(lat1: Double, lng1: Double, lat2: Double, lng2: Double) -> Double {
        
        // 위도,경도를 라디안으로 변환
        let rlat1 = lat1 * .pi / 180
        let rlng1 = lng1 * .pi / 180
        let rlat2 = lat2 * .pi / 180
        let rlng2 = lng2 * .pi / 180
        
        // 2점의 중심각(라디안) 요청
        let a = sin(rlat1) * sin(rlat2) + cos(rlat1) * cos(rlat2) * cos(rlng1 - rlng2)
        let rr = acos(a)
        
        // 지구 적도 반경(m단위)
        let earth_radius = 6378140.0
        
        // 두 점 사이의 거리 (km단위)
        let distance = earth_radius * rr / 1000
        
        return distance
    }

    
}
