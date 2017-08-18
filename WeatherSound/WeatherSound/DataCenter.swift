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

    var myPlayLists: [UserPlayList] = []

    var playItems:[WSPlayItem] = [] {
        didSet {
            if playItems.count == self.numberOfList
            {
                NotificationCenter.default.post(name: Notification.Name("PlayItemsLoaded"), object: nil, userInfo: nil)
                print("Noti PlayItemsLoaded!!!!!!!!!!!!!!!!!!!!!!!!!!!")
            }
            
        }
    }

//    var playItems: [WSPlayItem] = [] {
//        didSet {
////
////                if recommendList.count > 0
////                {
////                    let musicItem = recommendList[recommendList.count - 1]
////                    let songUrl = musicItem.musicUrl
////                    print("songUrl: \(songUrl)")
////                    let playItem = WSPlayItem(URL: URL(string: songUrl)!, musicItem: musicItem)
////                    self.playItems.append(playItem)
////                }
//        }
//    }
    
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
            
            
            guard let info = snapShot.value as? [String:String] else {return}
            
            if let location = info["location"],
                let name = info["name"],
                let temperate = info["temperature"],
                let savedTime = info["timeRelease"]{
                
                let dic = ["location":location, "name":name, "temperate":temperate, "savedTime":savedTime]
                
                self.weatherInfo = Weather(dic: dic)
                completion(self.weatherInfo!)
                
            }

        })
    }

    
    //get recommend list
    func getRecommendList(completion: @escaping (_ arry: [WSPlayItem]) -> Void){
        
        self.playItems = []
        
        let url = "https://weather-sound.com/api/music/"
        
        //url += "/page=\(next)"
        
        Alamofire.request(url).responseJSON { response in
                
                switch response.result{
                case .success(let value):
//                    print("---complete request",value)

                    let json = JSON(value)
                    
//                    print("complete",json)
                    
                    guard let musicList =  json.array else {
                        return
                    }
                    
                    
//                    self.numberOfList = musicList.count
                    
                    for item in musicList {
                        if let tmp = item["playlist_musics"].array{
                            
                            self.numberOfList = tmp.count
                            
                            for temp in tmp{
                                if let title = temp["name_music"].string,
                                    let artist = temp["name_artist"].string,
                                    let albumImg = temp["img_music"].string,
                                    let musicUrl = temp["source_music"].string {
                                    
                                    let dic = ["title":title, "artist":artist, "albumImg":albumImg, "musicUrl":musicUrl]
                                    
                                    let newMusicItem = Music(dic: dic)
                                    let songUrl = newMusicItem.musicUrl
                                    print("songUrl: \(songUrl)")
                                    let playItem = WSPlayItem(URL: URL(string: songUrl)!, musicItem: newMusicItem)
                                    self.playItems.append(playItem)
                                }
                            }
                        }
                    }
//                    print("playItems: ",self.playItems)
                    completion(self.playItems)
                    break
                case .failure(let error):
                    print("failure response: ", error)
                    
                    break
                }
        }
    }
    
    //(성공여부, 반환데이터, 에러)
    //(true, response, nil)
    //(false, nil, errorCode)
    
    func getMyList(){
        //param: user pk
        //tmp user pk = 14
        
        let url = "https://weather-sound.com/api/member/14/playlists/"
        let header = ["Authorization":"Token 58bdbaff29687bac131f187898962f6d9bc95b72"]
        
        Alamofire.request(url, method: HTTPMethod.get, headers: header).responseJSON { (response) in
            switch response.result{
            case .success(let value):
                let json = JSON(value)
                print("get userList success",json)
                
                guard let myPlayLists = json["playlists"].array else {
                    return
                }
                
                for playList in myPlayLists {
                    if let pk = playList["pk"].int,
                        let namePlaylist = playList["name_playlist"].string,
                        let weather = playList["weather"].string,
                        let playlistId = playList["playlist_id"].int,
                        let playlistMusics = playList["playlist_musics"].array{
                        
                        let dic = ["pk":pk, "namePlaylist":namePlaylist, "weather":weather, "playlistId":playlistId, "playlistMusics":playlistMusics] as [String : Any]
                        
                        let newListItem = UserPlayList(dic: dic)
                        self.myPlayLists.append(newListItem)
                    }
                }
                
                print("myList",self.myPlayLists)
                
                
                break
            case .failure(let error):
                print("success",error)
                break
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
//플레이리스트 하나의 struct : my page에서는 [UserPlayList]가 생김
struct UserPlayList {
    var pk: Int
    var name: String
    var weather: String
    var playListId: String
    var musicList: [Music]
    
    init(dic: [String:Any]){
        
        self.pk = dic["pk"] as! Int
        self.name = dic["namePlaylist"] as! String
        self.weather = dic["weather"] as! String
        self.playListId = dic["playlistId"] as! String
        self.musicList = dic["playlistMusics"] as! [Music]
    }
}


