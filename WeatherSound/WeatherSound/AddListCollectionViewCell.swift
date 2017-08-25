//
//  AddListCollectionViewCell.swift
//  WeatherSound
//
//  Created by Dong Yoon Han on 8/25/17.
//  Copyright © 2017 정교윤. All rights reserved.
//

import UIKit

class AddListCollectionViewCell: UICollectionViewCell {
    
    
    @IBOutlet weak var addNewListButton: UIButton!
    @IBAction func addNewListButtonTouched(_ sender: UIButton)
    {
        
//        let addListVC: AddListViewController = AddListViewController(completion: {
//            self.tableview.reloadData()
//        })
//        addListVC.modalPresentationStyle = .overCurrentContext
//        present(addListVC, animated: false, completion: nil)
        
    }
}

protocol AddListCollectionViewCellDelegate
{
    
}
