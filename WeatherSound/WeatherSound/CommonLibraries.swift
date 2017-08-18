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
    
    // 알럿 메시지 보여주기
    func displayAlertMessageAndDissmiss(vc: UIViewController, title: String, messageToDisplay: String)
    {
        let alertController = UIAlertController(title: title, message: messageToDisplay, preferredStyle: .alert)
        
        let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
            
            // Code in this block will trigger when OK button tapped.
            //print("Ok button tapped");
            
            vc.dismiss(animated: false, completion: nil)
            
        }
        
        alertController.addAction(OKAction)
        
        vc.present(alertController, animated: true, completion:nil)
    }

    
    
}
