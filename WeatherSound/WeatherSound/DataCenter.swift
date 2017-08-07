//
//  LoginDataCenter.swift
//  WeatherSound
//
//  Created by 정교윤 on 2017. 8. 5..
//  Copyright © 2017년 정교윤. All rights reserved.
//

import Foundation
import CoreData
import Alamofire
import SwiftyJSON

import Firebase

class DataCenter {
    
    static let shared = DataCenter()
    
    var isLogin:Bool = false
    
    var weatherInfo: Weather?
    var recommendList: [Music] = []
    
    
    
    func requestIsLogin() -> Bool {
        
        if Auth.auth().currentUser == nil {
            isLogin = false
            return false
        } else {
            
            
            isLogin = true
            return true
        }
        
    }
    
    func requestUserData(completion: @escaping (_ info:MyUser)->Void) {
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        // 사용자 정보를 획득
        Database.database().reference().child(uid).child("UserInfo").observeSingleEvent(of: .value, with: { (snapshot) in
            
            let dic = snapshot.value as! [String:Any]
            
            completion(MyUser(data: dic))
        })
    }
    
    func getCurrentWeather(lon: Double, lan: Double)->Weather{
        
        //네트워크통해 받은 json값으로 가정
        let text = "{\"grid\":{\"latitude\":\"\(lan)\",\"longitude\":\"\(lon)\",\"location\":\"dogok\"},\"info\":{\"temperate\":\"30\",\"name\":\"clear\"},\"timeRelease\":\"2017-08-05 12:00:00\"}"
        
        
        if let data = text.data(using: String.Encoding.utf8){
            
            let json = JSON(data:data)
            
            
            if let location = json["grid"]["location"].string,
                let name = json["info"]["name"].string,
                let temperate = json["info"]["temperate"].string,
                let savedTime = json["timeRelease"].string{
                
                let dic = ["location":location, "name":name, "temperate":temperate, "savedTime":savedTime]
                
                self.weatherInfo = Weather(dic: dic)
            }
        }
        return self.weatherInfo!
    }
    
    func requestWeather(){
        
        let url = "http://apis.skplanetx.com/weather/current/hourly"
        let param = [
            "version" : "1",
            "lat" : "37.76191539",
            "lon" : "-122.40588589"
        ]
        
        
        Alamofire.request(url,
                          parameters: param,
                          headers: ["appKey":"e863fb9a-2fa2-3f02-863b-884b60865987"])
            .responseJSON { response in
                
                switch response.result{
                case .success(let value):
                    print("success respose: ", value)
                    break
                case .failure(let error):
                    print("failure response: ", error)
                    break
                }
        }
    }
    
    func getRecommendList(){
        
        self.recommendList = []
        
        let text = "{\"clear\":[{\"title\":\"나의 옛날이야기\",\"artist\":\"IU\",\"img\":\"imgadress\",\"src\":\"musicSrc\"},{\"title\":\"우울시계\",\"artist\":\"IU\",\"img\":\"imgadress\",\"src\":\"musicSrc\"}]}"
        
        if let data = text.data(using: String.Encoding.utf8){
            
            let json = JSON(data:data)
            
            let curWeather = self.weatherInfo?.curWeather ?? "clear"
            
            
            guard let musicList =  json["\(curWeather)"].array else {
                return
            }
            
            for item in musicList {
                
                if let title = item["title"].string,
                    let artist = item["artist"].string,
                    let albumImg = item["img"].string,
                    let musicUrl = item["src"].string{
                    
                    
                    let dic = ["title":title, "artist":artist, "albumImg":albumImg, "musicUrl":musicUrl]
                    
                    let newMusicItem = Music(dic: dic)
                    self.recommendList.append(newMusicItem)
                }
            }
        }
    }
    
}

struct MyUser {
    
    //var myuser_pk:String?
    var email:String?
    var password:String?
    var nickname:String?
    var img_profile:String?
    var is_admin:String?
    var is_active:String?
    var is_superuser:String?
    
    
    // ["userName":userName, "profileImg":urlStr]
    init(data:[String:Any]) {
        
        //self.myuser_pk = data["myuser_pk"] as? String ?? "0"
        self.email = Auth.auth().currentUser?.email ?? ""
        self.password = data["password"] as? String ?? ""
        self.nickname = data["nickname"] as? String ?? ""
        self.img_profile = data["img_profile"] as? String ?? ""
        self.is_admin = data["is_admin"] as? String ?? ""
        self.is_active = data["is_active"] as? String ?? ""
        self.is_superuser = data["is_superuser"] as? String ?? ""
        
    }
    
}


struct Weather{
    
    var curLocation: String
    var savedTime: String
    var curWeather: String
    var curTemperate: String
    
    init(dic: [String:Any]) {
        
        self.curLocation = dic["location"] as! String
        self.curWeather = dic["name"] as! String
        self.curTemperate = dic["temperate"] as! String
        self.savedTime = dic["savedTime"] as! String
    }
}

struct Music {
    
    var title: String
    var artist: String
    var albumImg: String
    var musicUrl: String
    
    init(dic: [String:Any]){
        
        self.title = dic["title"] as! String
        self.artist = dic["artist"] as! String
        self.albumImg = dic["albumImg"] as! String
        self.musicUrl = dic["musicUrl"] as! String
    }
}
