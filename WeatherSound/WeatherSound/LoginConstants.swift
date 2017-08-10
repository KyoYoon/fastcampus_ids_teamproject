//
//  LoginConstants.swift
//  WeatherSound
//
//  Created by 정교윤 on 2017. 8. 9..
//  Copyright © 2017년 정교윤. All rights reserved.
//

import Foundation

// 로그인 관련 키 관련  문자열 상수 모음

struct Authentication {
    
    static let signupURL = "https://weather-sound.com/api/member/signup/"
    
    static let loginURL = "https://weather-sound.com/api/member/login/"
    
    static let logoutURL = "https://weather-sound.com/api/member/logout/"
    
    static let email = "email"
    
    static let nickname = "nickname"
    
    static let isLoginSucceed = "isLoginSucceed" // 로그인 성공 및 로그인 중인지 아닌지 나타내는 플래그 
    
    static let baseUserInfoURL = "https://weather-sound.com/api/member/" // 이 URL에 5/ 를 붙여서 사용자 정보를 가져올 수 있다.
    
}
