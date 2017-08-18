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
    var numberOfList:Int = 0
    var weatherInfo: Weather?
    var playItems:[WSPlayItem] = [] {
        didSet {
            if playItems.count == self.numberOfList
            {
                NotificationCenter.default.post(name: Notification.Name("PlayItemsLoaded"), object: nil, userInfo: nil)
                print("Noti PlayItemsLoaded!!!!!!!!!!!!!!!!!!!!!!!!!!!")
            }
            
        }
    }

    var recommendList: [Music] = [] {
        didSet {

                if recommendList.count > 0
                {
                    let musicItem = recommendList[recommendList.count - 1]
                    let songUrl = musicItem.musicUrl
                    print("songUrl: \(songUrl)")
                    let playItem = WSPlayItem(URL: URL(string: songUrl)!, musicItem: musicItem)
                    self.playItems.append(playItem)
                }
        }
    }
    
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
    
   
    //weather - firebase
    func getCurrentWeatherFromFireBase(lon: Double, lat: Double, completion: @escaping(_ weatherInfo:Weather)->Void){
        
        Database.database().reference().child("weather").observeSingleEvent(of: .value, with: { (snapShot) in
            
            let info = snapShot.value as! [String:String]
            
            if let location = info["location"],
                let name = info["name"],
                let temperate = info["temperature"],
                let savedTime = info["timeRelease"]{
                
                let dic = ["location":location, "name":name, "temperate":temperate, "savedTime":savedTime]
                
                self.weatherInfo = Weather(dic: dic)
            }
            
            if let info = self.weatherInfo{
                completion(info)
            }
        })
    }

    
    //get recommend list
    func getRecommendList(completion: @escaping (_ arry: [Music]) -> Void){
        
        self.recommendList = []
        
        let url = "https://weather-sound.com/api/music/"
        
        //url += "/page=\(next)"
        Alamofire.request(url).responseJSON { response in
                
                switch response.result{
                case .success(let value):
                    print("music api success")
                    //print("success respose: ", value)
                    
                    let json = JSON(value)
                    
                    guard let musicList =  json["results"].array else {
                        return
                    }
                    
                    self.numberOfList = musicList.count
                    
                    for item in musicList {
                        if let title = item["name_music"].string,
                            let artist = item["name_artist"].string,
                            let albumImg = item["img_music"].string,
                            let musicUrl = item["source_music"].string{
                            
                            let dic = ["title":title, "artist":artist, "albumImg":albumImg, "musicUrl":musicUrl]
                            
                            let newMusicItem = Music(dic: dic)
                            self.recommendList.append(newMusicItem)
                        }
                    }
                    completion(self.recommendList)
                    break
                case .failure(let error):
                    print("failure response: ", error)
                    break
                }
        }
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
    
    
    ////////////////////////////////////////////////////////////////////////////////////////////////////
    //MARK:- dummy data test
    

    //getWeather - dummy
    func getCurrentWeather(lon: Double, lan: Double)->Weather{
        
        //네트워크통해 받은 json값으로 가정
        let text = "{\"grid\":{\"latitude\":\"\(lan)\",\"longitude\":\"\(lon)\",\"location\":\"dogok\"},\"info\":{\"temperate\":\"30\",\"name\":\"cloudy\"},\"timeRelease\":\"2017-08-05 12:00:00\"}"
        
        
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
    var albumTitle: String?
    var duration: Double?    
    init(dic: [String:Any]){
        
        self.title = dic["title"] as! String
        self.artist = dic["artist"] as! String
        self.albumImg = dic["albumImg"] as! String
        self.musicUrl = dic["musicUrl"] as! String
//        let data = try? Data(contentsOf: albumImg)
//        let albumpic = UIImage(data: data)
    }
}
