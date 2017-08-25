//
//  MyMusicListCollectionViewCell.swift
//  WeatherSound
//
//  Created by Dong Yoon Han on 8/25/17.
//  Copyright © 2017 정교윤. All rights reserved.
//

import UIKit

class MyMusicListCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var listImageView: UIImageView!

    @IBOutlet weak var infoLB: UILabel!
    @IBOutlet weak var infoSubLB: UILabel!
    
    
    
    //플레이리스트 하나의 struct : my page에서는 [UserPlayList]가 생김
//    struct UserPlayList {
//        var pk: Int
//        var name: String
//        var weather: String
//        var playListId: Int
//        var isShard: Bool?
//        var musicList: [Music]
//        
//        init(dic: [String:Any]){
//            
//            self.pk = dic["pk"] as! Int
//            self.name = dic["namePlaylist"] as! String
//            self.weather = dic["weather"] as! String
//            self.playListId = dic["playlistId"] as! Int
//            //        self.isShard = dic["isShared"] as! Bool
//            self.musicList = dic["playlistMusics"] as! [Music]
//        }
//    }
    
    func set(listName: String, count: Int){
        
        let attributedString: NSMutableAttributedString = NSMutableAttributedString(string: "\(listName)", attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 15, weight: UIFontWeightThin), NSForegroundColorAttributeName: UIColor(red:0.29, green:0.26, blue:0.28, alpha:1.00)])
        
        let attributedSubString: NSMutableAttributedString = NSMutableAttributedString(string: "\(count)곡", attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 14, weight: UIFontWeightThin), NSForegroundColorAttributeName: UIColor(red:0.29, green:0.26, blue:0.28, alpha:1.00)])
        
        self.infoLB.attributedText = attributedString
        self.infoSubLB.attributedText = attributedSubString
    }
    
    func set(iconOf: String){
        
        let icon: UIImage
        
        switch iconOf {
        case "sunny":
            icon = #imageLiteral(resourceName: "sunny")
        case "snowy":
            icon = #imageLiteral(resourceName: "snowy")
        case "foggy":
            icon = #imageLiteral(resourceName: "foggy")
        case "rainy":
            icon = #imageLiteral(resourceName: "rainny")
        case "cloudy":
            icon = #imageLiteral(resourceName: "cloudy")
        default:
            icon = #imageLiteral(resourceName: "question")
        }
        
        self.listImageView.image = icon
    }
}
