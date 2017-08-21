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

protocol DataCenterDelegate
{
    func appendPlayback(item: WSPlayItem)
}

class DataCenter {
    
    static let shared = DataCenter()
    
    var isLogin:Bool = false
//    var numberOfList:Int = 0
    var weatherInfo: Weather?

    var myPlayLists: [UserPlayList] = []
 
    //play될 노래 리스트
    var delegate:DataCenterDelegate?
    var playItems:[WSPlayItem] = [] {
        didSet {
//            if playItems.count == self.numberOfList
//            {
//                NotificationCenter.default.post(name: Notification.Name("PlayItemsLoaded"), object: nil, userInfo: nil)
//                print("Noti PlayItemsLoaded!!!!!!!!!!!!!!!!!!!!!!!!!!!")
//            }
            
            if playItems.count > 0
            {
                self.delegate?.appendPlayback(item: playItems.last!)
            }
            if playItems.count == 1
            {
                NotificationCenter.default.post(name: Notification.Name("FirstSongOfList"), object: nil, userInfo: ["FirstSongOfList":playItems.last!])
            }
            
        }
    }

    var musicList: [Music] = []
    
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
    func getRecommendList(lat: Double, lon: Double ,completion:  (() -> Void)?){
        
        self.playItems = []
        self.musicList = []
        
        let url = "https://weather-sound.com/api/music/"
        let param = ["longitude" : lon, "latitude" : lat]
        
        Alamofire.request(url, method: .post, parameters: param).responseJSON { (response) in
            switch response.result{
                case .success(let value):
                    print(">>>>recomment request<<<<")
                    
                    let json = JSON(value)
                    
                    guard let address = json["address"].string,
                        let weather = json["weather"].string,
                        let temperate = json["temperature"].double,
                        let musicList = json["listInfo"]["playlist_musics"].array else {
                        return
                    }
                    
                    
                    let addressArry: [String] = address.components(separatedBy: " ")
                    let shortAddr: String = "\(addressArry[3]) \(addressArry[4])"
                    
                    //weather
                    let weatherDic: [String:Any] = ["location": shortAddr, "name" : weather, "temperate": temperate]
                    self.weatherInfo = Weather(dic: weatherDic)
                    
                    //music list
//                    self.numberOfList = musicList.count

                    for musicItem in musicList{
                        if let pk = musicItem["pk"].int,
                            let title = musicItem["name_music"].string,
                            let artist = musicItem["name_artist"].string,
                            let albumImg = musicItem["img_music"].string,
                            let musicUrl = musicItem["source_music"].string {
                            
                            let dic: [String:Any] = ["pk":pk, "title":title, "artist":artist, "albumImg":albumImg, "musicUrl":musicUrl]
                            
                            let newMusicItem = Music(dic: dic)
                            
//                            self.musicList.append(newMusicItem)
                            
                            let songUrl = newMusicItem.musicUrl
                            let playItem = WSPlayItem(URL: URL(string: musicUrl)!, musicItem: newMusicItem)
                            self.playItems.append(playItem)
                        }
                    }
                    completion?()
                    break
                case .failure(let error):
                    print(error)
                    break

            }
        }
    }
    
    //(성공여부, 반환데이터, 에러)
    //(true, response, nil)
    //(false, nil, errorCode)
    
    func getMyList(completion: ((_ info:[UserPlayList])->Void)?){
        //param: user pk
        //tmp user pk = 14
        
        self.myPlayLists = []
        var myListMusic: [WSPlayItem] = []
        
        let url = "https://weather-sound.com/api/member/14/playlists/"
        let header = ["Authorization":"Token 58bdbaff29687bac131f187898962f6d9bc95b72"]
        
        Alamofire.request(url, method: HTTPMethod.get, headers: header).responseJSON { (response) in
            switch response.result{
            case .success(let value):
                let json = JSON(value)
                
                guard let myPlayLists = json["User"]["playlists"].array else {
                    return
                }

                for playList in myPlayLists {
                    if let pk = playList["pk"].int,
                        let namePlaylist = playList["name_playlist"].string,
                        let weather = playList["weather"].string,
                        let playlistId = playList["playlist_id"].int,
                        let playlistMusics = playList["playlist_musics"].array{
                        
                        for musicItem in playlistMusics{
                            if let title = musicItem["name_music"].string,
                                let artist = musicItem["name_artist"].string,
                                let albumImg = musicItem["img_music"].string,
                                let musicUrl = musicItem["source_music"].string {
                                
                                let dic = ["title":title, "artist":artist, "albumImg":albumImg, "musicUrl":musicUrl]
                                
                                let playItem = WSPlayItem(URL: URL(string: musicUrl)!, musicItem: Music(dic: dic))
                                myListMusic.append(playItem)
                            }
                        }
                        
                        let dic: [String : Any] = ["pk":pk, "namePlaylist":namePlaylist, "weather":weather, "playlistId":playlistId, "playlistMusics":myListMusic]
                        
                        let newListItem = UserPlayList(dic: dic)
                        self.myPlayLists.append(newListItem)
                    }
                }
                completion?(self.myPlayLists)
                break
            case .failure(let error):
                print("success",error)
                break
            }
        }
    }
    
    func putRequestAddMyList(_ newList:String, completion: (()->Void)?){
        
        self.myPlayLists = []
        
        let url = "https://weather-sound.com/api/member/14/playlists/"
        let header = ["Authorization":"Token 58bdbaff29687bac131f187898962f6d9bc95b72"]
        let param: [String:String] = ["name_playlist":newList]
        
        Alamofire.request(url, method: HTTPMethod.put, parameters: param,  headers: header).responseJSON { (response) in
            switch response.result{
            case .success(let value):
                let json = JSON(value)
                
                guard let myPlayLists = json["data"]["playlists"].array else {
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
                print("get userList success - self.myPlayLists : ",self.myPlayLists)
                completion?()
                break
            case .failure(let error):
                print("success",error)

                break
                
                
            }
        }
     
    }
    
    func deleteRequestMyList(_ indexArray: [Int], completion: (()->Void)?){
        
        let url = "https://weather-sound.com/api/member/14/playlists/\(indexArray[0])/"
        let header = ["Authorization":"Token 58bdbaff29687bac131f187898962f6d9bc95b72"]

        Alamofire.request(url, method: HTTPMethod.delete, headers: header).responseJSON { (response) in
            switch response.result{
            case .success(let value):
                let json = JSON(value)
                
                print(json)
                if let detail = json["detail"].string{
                    print(detail)
                    self.myPlayLists = self.myPlayLists.filter({ (userPlayList) -> Bool in
                        return userPlayList.playListId != indexArray[0]
                    })
                    print("after remove : ",self.myPlayLists)
                }
                
                completion?()
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
    var curWeather: String
    var curTemperate: Double
    
    init(dic: [String:Any]) {
        
        self.curLocation = dic["location"] as! String
        self.curWeather = dic["name"] as! String
        self.curTemperate = dic["temperate"] as! Double
    }
}

struct Music {
    var pk: Int
    var title: String
    var artist: String
    var albumImg: String
    var musicUrl: String
    var albumTitle: String?
    var duration: Double?
    
    init(dic: [String:Any]){
        self.pk = dic["pk"] as! Int
        self.title = dic["title"] as! String
        self.artist = dic["artist"] as! String
        self.albumImg = dic["albumImg"] as! String
        self.musicUrl = dic["musicUrl"] as! String
    }
}

//플레이리스트 하나의 struct : my page에서는 [UserPlayList]가 생김
struct UserPlayList {
    var pk: Int
    var name: String
    var weather: String
    var playListId: Int
    var musicList: [WSPlayItem]
    
    init(dic: [String:Any]){
        
        self.pk = dic["pk"] as! Int
        self.name = dic["namePlaylist"] as! String
        self.weather = dic["weather"] as! String
        self.playListId = dic["playlistId"] as! Int
        self.musicList = dic["playlistMusics"] as! [WSPlayItem]
    }
}


