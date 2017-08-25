//
//  AddSongViewController.swift
//  WeatherSound
//
//  Created by Dong Yoon Han on 8/25/17.
//  Copyright © 2017 정교윤. All rights reserved.
//

import UIKit

class AddSongViewController: UIViewController, UIGestureRecognizerDelegate {

    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    var currentMusicPk: Int?
    let cellScaling:CGFloat = 0.5

    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.dataSource = self
        
        
        let screenSize = contentView.bounds.size
        let cellWidth = floor(screenSize.width * cellScaling)
        let cellHeight = floor(screenSize.height * cellScaling)
        
        let insetX = (contentView.bounds.width - cellWidth) / 3.0
        let insetY = (contentView.bounds.height - cellHeight) / 3.0
        print("insetX: ", insetX)
        print("insetY: ", insetY)
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: cellWidth, height: cellHeight)
        collectionView.contentInset = UIEdgeInsets(top: insetY, left: insetX, bottom: insetY, right: insetX)

    }
    override func viewWillAppear(_ animated: Bool) {
        
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        affineAction()
    }
    
    func affineAction()
    {
        if self.contentView.transform == .identity
        {
            UIView.animate(withDuration: 0.5, animations: {
                self.contentView.transform = CGAffineTransform(translationX: -340, y: 0)
                //                self.myView.transform = CGAffineTransform(scaleX: 1.8, y: 1.5)
//                self.myCollectionView.transform = CGAffineTransform(scaleX: 1.8, y: 1.5)
                
                
            }, completion: { (true) in
                //                UIView.animate(withDuration: 1, animations: {
                //                    self.myView.transform = CGAffineTransform(scaleX: 1.8, y: 1.5)
                //
                //                }, completion: { (true) in
                //
                //                })
            })
        } else
        {
            UIView.animate(withDuration: 0.5, animations: {
                self.contentView.transform = .identity
//                self.myCollectionView.transform = .identity
                
            }, completion: { (true) in
                
            })
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view?.isDescendant(of: self.collectionView) == true
        {
            return false
        }
        return true
    }
    @IBAction func backgroundTapGesture(_ sender: UITapGestureRecognizer) {
        
        print("background touched")
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func collectionViewTapGesture(_ sender: UITapGestureRecognizer) {
        
        //        if let location = sender.location(in: self.collectionView)
        //        collectionView(self.collectionView, didSelectItemAt: self.collectionView.indexPathForItem(at: location)!)
        
        if let indexPath = self.collectionView?.indexPathForItem(at: sender.location(in: self.collectionView))
        {
            if indexPath.item == 0
            {
                let addListVC: AddListViewController = AddListViewController(completion: {
                    DispatchQueue.main.async {
                        self.collectionView.reloadData()
                    }
                })
                addListVC.modalPresentationStyle = .overCurrentContext
                present(addListVC, animated: false, completion: nil)
            } else
            {
                let selectedListName = DataCenter.shared.myPlayLists[indexPath.item - 1].name
                
                if let musicPk = self.currentMusicPk
                {
                    DataCenter.shared.addMyListRequest(list: selectedListName, music: "\(musicPk)", completion: {
                        self.dismiss(animated: true, completion: nil)
                    })
                }
                
                print("hello you touch indexPath.item: ", indexPath.item - 1)
                //            let cell = self.collectionView?.cellForItem(at: indexPath)
                
                //            print("you can do something with the cell or index path here")
            }
        }
        
    }
}

extension AddSongViewController: UICollectionViewDataSource
{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("내리스트 카운트: ",DataCenter.shared.myPlayLists.count)
        return DataCenter.shared.myPlayLists.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.item == 0
        {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "addCell", for: indexPath)
            return cell
        } else
        {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "myListCell", for: indexPath) as! MyMusicListCollectionViewCell
            
            let playList = DataCenter.shared.myPlayLists[indexPath.row - 1]
            
            cell.set(listName: playList.name, count: playList.musicList.count)
            cell.set(iconOf: playList.weather)
            
            return cell
        }
    }
}

extension AddSongViewController: UICollectionViewDelegate
{
    
}
