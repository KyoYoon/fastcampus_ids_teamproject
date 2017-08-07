//
//  SongDataSource.swift
//  MusicPlayer
//
//  Created by Dong Yoon Han on 8/3/17.
//  Copyright © 2017 DY. All rights reserved.
//

import UIKit
import AVFoundation

class SongDataSource {
    
    static let shared = SongDataSource()
    private var songMetaDataArray:[SongMetaData] = []
    
    var songDatas:[SongMetaData] {
        return songMetaDataArray
    }
    
    init()
    {
        getMetaData()
    }
    
    var numberOfItems:Int{
        return songMetaDataArray.count
    }
    
    func cellForSongData(at index:Int) -> SongMetaData? {
        return  songMetaDataArray[index]
    }
    
    func getMetaData()
    {
    
        for i in 0..<30
        {
            let count:String = "\(i)"
            if let fileURL = Bundle.main.url(forResource: count, withExtension: "mp3")
            {
                let asset:AVAsset = AVURLAsset(url: fileURL, options: nil)
                let metaData:[AVMetadataItem] = asset.commonMetadata
                let songData = SongMetaData(metaData: metaData, id: i)
                songMetaDataArray.append(songData)
            }else
            {
                print("file이 없음")
            }
        }
    }
    
}
