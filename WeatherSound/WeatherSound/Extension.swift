//
//  Extension.swift
//  WeatherSound
//
//  Created by 정교윤 on 2017. 8. 5..
//  Copyright © 2017년 정교윤. All rights reserved.
//

import Foundation

import UIKit

extension UIColor
{
    static func rgbColor(_ red:CGFloat, _ green:CGFloat, _ blue:CGFloat) -> UIColor {
        return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: 1)
    }

}


var cache:[String:Data] = [:]

extension UIImageView
{
    func loadImagWithURL(urlStr:String)
    {
     
        if let imageData  = cache[urlStr]
        {
            self.image = UIImage(data: imageData)
        }else
        {
            if let url = URL(string: urlStr){
                self.sd_setImage(with: url)
                
                
                cache.updateValue(UIImageJPEGRepresentation(self.image!, 1)! , forKey: urlStr)
                
            }
        }
    }
    
    func refreshCache()
    {
        if cache.count > 20
        {
           //remove
        }
    }
}
