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
                NotificationCenter.default.post(name: Notification.Name("FirstSongOfListLoaded"), object: nil, userInfo: ["FirstSongOfList":playItems.last!])
            }
            
        }
    }

    
//    var musicList: [Music] = []
    
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
    
    //get recommend list
    func getRecommendList(lat: Double, lon: Double ,completion:  (() -> Void)?){
        
        self.playItems = []
//        self.musicList = []
        
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
                
                
                //                    let addressArry: [String] = address.components(separatedBy: " ")
                //                    let shortAddr: String = "\(addressArry[3]) \(addressArry[4])"
                
                //weather
                let weatherDic: [String:Any] = ["location": address, "name" : weather, "temperate": temperate]
                self.weatherInfo = Weather(dic: weatherDic)
                
                //music list

                    for musicItem in musicList{
                        if let pk = musicItem["pk"].int,
                            let title = musicItem["name_music"].string,
                            let artist = musicItem["name_artist"].string,
                            let albumImg = musicItem["img_music"].string,
                            let musicUrl = musicItem["source_music"].string {
                            
                            let dic: [String:Any] = ["pk":pk, "title":title, "artist":artist, "albumImg":albumImg, "musicUrl":musicUrl]
                            let newMusicItem = Music(dic: dic)
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
    
    //내 리스트 가져오기
    func getMyList(completion: ((_ info:[UserPlayList])->Void)?){
        
        guard let _ = LoginDataCenter.shared.myLoginInfo,
            let token = UserDefaults.standard.string(forKey: Authentication.token) else{
                return
        }
        
        self.myPlayLists = []
        
//        var myWSPlayItems: [WSPlayItem] = []
        
        let url = "https://weather-sound.com/api/member/\(UserDefaults.standard.integer(forKey: Authentication.pk))/playlists/"
        let header = ["Authorization":"Token "+token]
        
        Alamofire.request(url, method: HTTPMethod.get, headers: header).responseJSON { (response) in
            switch response.result{
            case .success(let value):
                let json = JSON(value)
                
                guard let myPlayLists = json["User"]["playlists"].array else {
                    return
                }
                
                for playList in myPlayLists {
                    var myMusics: [Music] = []

                    if let pk = playList["pk"].int,
                        let namePlaylist = playList["name_playlist"].string,
                        let weather = playList["weather"].string,
//                        let isShared = playList["is_shared_list"].bool,
                        let playlistId = playList["playlist_id"].int,
                        let playlistMusics = playList["playlist_musics"].array{
                        
                        for musicItem in playlistMusics{
                            if let pk = musicItem["pk"].int,
                                let title = musicItem["name_music"].string,
                                let artist = musicItem["name_artist"].string,
                                let albumImg = musicItem["img_music"].string,
                                let musicUrl = musicItem["source_music"].string {
                                
                                let dic: [String:Any] = ["pk":pk, "title":title, "artist":artist, "albumImg":albumImg, "musicUrl":musicUrl]
                                
                                myMusics.append(Music(dic: dic))
//                                let playItem = WSPlayItem(URL: URL(string: musicUrl)!, musicItem: Music(dic: dic))
//                                myWSPlayItems.append(playItem)
                            }
                        }
                        let listdic: [String : Any] = ["pk":pk, "namePlaylist":namePlaylist, "weather":weather, "playlistId":playlistId, "playlistMusics":myMusics]
                        let newListItem = UserPlayList(dic: listdic)
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
    
    //리스트 추가
    func addMyListRequest(_ newList:String, completion: (()->Void)?){
        
        guard let _ = LoginDataCenter.shared.myLoginInfo,
            let token = UserDefaults.standard.string(forKey: Authentication.token) else{
                return
        }
        
        var myListMusic: [WSPlayItem] = []
        
        let url = "https://weather-sound.com/api/member/\(UserDefaults.standard.integer(forKey: Authentication.pk))/playlists/"
        let header = ["Authorization":"Token "+token]
        let param: [String:String] = ["create_playlist":newList]
        
        Alamofire.request(url, method: .post, parameters: param,  headers: header).responseJSON { (response) in
            switch response.result{
            case .success(let value):
                let json = JSON(value)
                
                guard let newPlayList = json["lists"].dictionaryObject else {
                    return
                }
                
                let pk = newPlayList["pk"] as! Int
                let namePlaylist = newPlayList["name_playlist"] as! String
                let weather = newPlayList["weather"] as! String
                let playlistId = newPlayList["playlist_id"] as! Int
                //                let isShared = newPlayList["is_shared_list"] as! Bool
                let PlayListMusics = newPlayList["playlist_musics"] as! [JSON]
                
                //WSMusicItem
                for musicItem in PlayListMusics{
                    if let title = musicItem["name_music"].string,
                        let artist = musicItem["name_artist"].string,
                        let albumImg = musicItem["img_music"].string,
                        let musicUrl = musicItem["source_music"].string {
                        
                        let dic = ["title":title, "artist":artist, "albumImg":albumImg, "musicUrl":musicUrl]
                        
                        let playItem = WSPlayItem(URL: URL(string: musicUrl)!, musicItem: Music(dic: dic))
                        myListMusic.append(playItem)
                    }
                }
                
                let dic = ["pk":pk, "namePlaylist":namePlaylist, "weather":weather, "playlistId":playlistId, "playlistMusics":myListMusic] as [String : Any]
                
                let newListItem = UserPlayList(dic: dic)
                self.myPlayLists.append(newListItem)
                
                
                
                print("get userList success - self.myPlayLists : ",self.myPlayLists)
                completion?()
                break
            case .failure(let error):
                print("success",error)
                
                break
                
            }
        }
    }
    
    
    //리스트 삭제
    func deleteRequestMyList(of selectedPk: [Int], completion: (()->Void)?){
        
        guard let _ = LoginDataCenter.shared.myLoginInfo,
            let token = UserDefaults.standard.string(forKey: Authentication.token) else{
                return
        }
        
        let pkStr:String = (selectedPk.map{String($0)}).joined(separator: ",")
        
        let url = "https://weather-sound.com/api/member/\(UserDefaults.standard.integer(forKey: Authentication.pk))/playlists/"
        let header = ["Authorization":"Token "+token]
        let param = ["delete_playlist": pkStr]
        
        Alamofire.request(url, method: .put, parameters: param, headers: header).responseJSON { (response) in
            switch response.result{
            case .success(let value):
                let json = JSON(value)
                
                if let detail = json["detail"].string,
                    let listDeleted = json["list deleted"].array{
                    print(detail)
                    print(listDeleted)
                    
                    for deletedIndex in listDeleted{
                        
                        if let idx = deletedIndex.string{
                            self.myPlayLists = self.myPlayLists.filter({ (userPlayList) -> Bool in
                                return userPlayList.pk != Int(idx)
                            })
                        }
                    }
                }
                completion?()
                break
            case .failure(let error):
                print("success",error)
                break
            }
        }
    }
    
    //노래 삭제
    func deleteRequestMyMusic(list lPk: Int, of selectedPk: [Int], completion: (()->Void)?){
        
        guard let _ = LoginDataCenter.shared.myLoginInfo,
            let token = UserDefaults.standard.string(forKey: Authentication.token) else{
                return
        }
        
        let pkStr:String = (selectedPk.map{String($0)}).joined(separator: ",")+","
        
        let url = "https://weather-sound.com/api/member/\(UserDefaults.standard.integer(forKey: Authentication.pk))/playlists/\(lPk)/"
        let header = ["Authorization":"Token "+token]
        let param = ["music": pkStr]
        
        Alamofire.request(url, method: .put, parameters: param, headers: header).responseJSON { (response) in
            switch response.result{
            case .success(let value):
                let json = JSON(value)
                
                if let detail = json["detail"].string,
                    let remainList = json["playlist"]["playlist_musics"].array{
                    print(detail)
                    print(remainList)
                    
                    var myMusics: [Music] = []
                    
                    for musicItem in remainList{
                        
                        if let pk = musicItem["pk"].int,
                            let title = musicItem["name_music"].string,
                            let artist = musicItem["name_artist"].string,
                            let albumImg = musicItem["img_music"].string,
                            let musicUrl = musicItem["source_music"].string {
                            
                            let dic: [String:Any] = ["pk":pk, "title":title, "artist":artist, "albumImg":albumImg, "musicUrl":musicUrl]
                            myMusics.append(Music(dic: dic))
                        }
                    }
                  
                    for (idx, list) in self.myPlayLists.enumerated(){
                        if list.pk == lPk{
                            self.myPlayLists[idx].musicList = myMusics
                        }
                    }
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
    var isShard: Bool?
    var musicList: [Music]
    
    init(dic: [String:Any]){
        
        self.pk = dic["pk"] as! Int
        self.name = dic["namePlaylist"] as! String
        self.weather = dic["weather"] as! String
        self.playListId = dic["playlistId"] as! Int
        //        self.isShard = dic["isShared"] as! Bool
        self.musicList = dic["playlistMusics"] as! [Music]
    }
}


