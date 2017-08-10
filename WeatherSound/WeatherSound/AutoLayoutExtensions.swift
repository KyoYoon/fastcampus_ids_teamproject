//
//  AutoLayoutExtensions.swift
//  DYMusicPlayer
//
//  Created by Dong Yoon Han on 8/3/17.
//  Copyright © 2017 DY. All rights reserved.
//

import Foundation
import UIKit


//extension UIColor
//{
//    static func rgbColor(_ red: CGFloat, _ green: CGFloat, _ blue: CGFloat) -> UIColor
//    {
//        return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: 1.0)
//    }
//    
//}

extension UIStackView
{
    func addArrangedSubViews(_ views:[UIView])
    {
        views.forEach { (view) in
            self.addArrangedSubview(view)
        }
        
        //위 코드랑 똑같음
        //        for v in views
        //        {
        //            self.addArrangedSubview(v)
        //        }
    }
}

extension UIView
{
    func addSubviews(_ views:[UIView])
    {
        views.forEach { (view) in
            self.addSubview(view)
        }
    }
}


extension UIView
{
    func anchor(top:NSLayoutYAxisAnchor?,
                left:NSLayoutXAxisAnchor?,
                right:NSLayoutXAxisAnchor?,
                bottom:NSLayoutYAxisAnchor?,
                topConstant:CGFloat,
                leftConstant:CGFloat,
                rightConstant:CGFloat,
                bottomConstant:CGFloat,
                width:CGFloat,
                height:CGFloat,
                centerX:NSLayoutXAxisAnchor?,
                centerY:NSLayoutYAxisAnchor?)
    {
        self.translatesAutoresizingMaskIntoConstraints = false
        
        if let top = top
        {
            self.topAnchor.constraint(equalTo: top, constant: topConstant).isActive = true
        }
        if let left = left
        {
            self.leftAnchor.constraint(equalTo: left, constant: leftConstant).isActive = true
        }
        if let right = right
        {
            self.rightAnchor.constraint(equalTo: right, constant: -rightConstant).isActive = true
        }
        if let bottom = bottom
        {
            self.bottomAnchor.constraint(equalTo: bottom, constant: -bottomConstant).isActive = true
        }
        
        if width > 0
        {
            self.widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        if height > 0
        {
            self.heightAnchor.constraint(equalToConstant: height).isActive = true
        }
        if let centerX = centerX
        {
            self.centerXAnchor.constraint(equalTo: centerX).isActive = true
        }
        if let centerY = centerY
        {
            self.centerYAnchor.constraint(equalTo: centerY).isActive = true
        }
    }
    
//    func anchor(top:NSLayoutYAxisAnchor? = nil,
//                left:NSLayoutXAxisAnchor? = nil,
//                right:NSLayoutXAxisAnchor? = nil,
//                bottom:NSLayoutYAxisAnchor? = nil,
//                topConstant:CGFloat = 0,
//                leftConstant:CGFloat = 0,
//                rightConstant:CGFloat = 0,
//                bottomConstant:CGFloat = 0,
//                width:CGFloat = 0,
//                height:CGFloat = 0,
//                centerX:NSLayoutXAxisAnchor? = nil,
//                centerY:NSLayoutYAxisAnchor? = nil) -> [NSLayoutConstraint]
//    {
//        self.translatesAutoresizingMaskIntoConstraints = false
//        var anchors = [NSLayoutConstraint]()
//        if let top = top
//        {
//            anchors.append(topAnchor.constraint(equalTo: top, constant: topConstant))
//        }
//        if let left = left
//        {
//            anchors.append(leftAnchor.constraint(equalTo: left, constant: leftConstant))
//        }
//        if let right = right
//        {
//            anchors.append(rightAnchor.constraint(equalTo: right, constant: -rightConstant))
//        }
//        if let bottom = bottom
//        {
//            anchors.append(bottomAnchor.constraint(equalTo: bottom, constant: -bottomConstant))
//        }
//        
//        if width > 0
//        {
//            anchors.append(widthAnchor.constraint(equalToConstant: width))
//        }
//        if height > 0
//        {
//            anchors.append(heightAnchor.constraint(equalToConstant: height))
//        }
//        if let centerX = centerX
//        {
//            anchors.append(centerXAnchor.constraint(equalTo: centerX))
//        }
//        if let centerY = centerY
//        {
//            anchors.append(centerYAnchor.constraint(equalTo: centerY))
//        }
//        
//        anchors.forEach { $0.isActive = true }
//        return anchors
//    }
}
