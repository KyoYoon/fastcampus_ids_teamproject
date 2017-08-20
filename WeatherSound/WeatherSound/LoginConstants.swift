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
    
    static let facebookLoginURL = "https://weather-sound.com/api/member/facebook-login/"
    
    static let logoutURL = "https://weather-sound.com/api/member/logout/"
    
    static let baseUserInfoURL = "https://weather-sound.com/api/member/profile/" // 이 URL에 5/ 를 붙여서 사용자 정보를 가져올 수 있다.

    
    static let isLoginSucceed = "isLoginSucceed" // 로그인 성공 및 로그인 중인지 아닌지 나타내는 플래그 
    
    static let isFacebookLogin = "isFacebookLogin" // false: 이메일/비밀번호 로그인 , true: 페이스북 로그인
    
    static let token = "token" // token = 로그인 후 로그아웃 누를 때까지 토큰 저장 / 로그아웃 누르면 토큰 삭제
    
    static let pk = "pk" // pk = 로그인 후 로그아웃 누를 때까지 primary key 저장 / 로그아웃 누르면 primary key 삭제
    
    static let userInfo = "userInfo" // 사용자 정보를 담은 MyLoginInfo를 Dictionary 형태로 UserDefaults에 저장할 때 쓰는 키
    
}
