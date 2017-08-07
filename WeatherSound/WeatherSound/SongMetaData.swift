//
//  SongMetaData.swift
//  MusicPlayer
//
//  Created by Dong Yoon Han on 8/3/17.
//  Copyright © 2017 DY. All rights reserved.
//

import AVFoundation
import UIKit

struct SongMetaData {
    var songTitle:String?
    var albumName:String?
    var artistName:String?
    var albumImg:UIImage?
    var songID:Int?
    
     
    /*mp3파일에 정의되어있음.
     title
     creationDate
     artwork
     albumName
     artist
     */
    init(metaData:[AVMetadataItem], id:Int)
    {
        for item in metaData
        {
            if let key = item.commonKey
            {
             
                switch key {
                case "title":
                   songTitle = item.stringValue
                case "artwork":
                    albumImg = UIImage(data: item.value?.copy(with: nil) as! Data)
                case "albumName":
                    albumName = item.stringValue
                case "artist":
                    artistName = item.stringValue
                default:
                    break;
                }
                
            }
        }
        songID = id //array를 관리하기 위해서.
    }
    //AVasset을 통해 데이터를 끄집어 내기 위한것
}
