//
//  AddMusicViewController.swift
//  WeatherSound
//
//  Created by HyunJomi on 2017. 8. 24..
//  Copyright © 2017년 정교윤. All rights reserved.
//

import UIKit

class AddMusicViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var addListBtn: UIButton!
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var cancelBtn: UIButton!
    
    var currentMusicPk: Int?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableview.register(UINib.init(nibName: "EditMyListTableViewCell", bundle: nil), forCellReuseIdentifier: EditMyListTableViewCell.reuseId)
        
        self.tableview.delegate = self
        self.tableview.dataSource = self
        
    
        self.view.backgroundColor = .clear
        
        let rect = UIScreen.main.bounds
        
        self.containerView.frame = CGRect(x: 5, y: 20, width: rect.width-10, height: rect.height)
       
        self.cancelBtn.frame = CGRect(x: rect.midX-25, y: 20, width: 50, height: 50)
        self.addListBtn.frame = CGRect(x: 20, y: self.cancelBtn.frame.maxY+20, width: self.containerView.frame.width-40, height: 50)
        
        self.tableview.frame = CGRect(x: 0, y: self.addListBtn.frame.maxY+20, width: self.containerView.frame.width, height: self.containerView.frame.height-80)
        
        self.containerView.layer.cornerRadius = 10
        self.addListBtn.layer.cornerRadius = 8
        self.cancelBtn.layer.cornerRadius  = 25
        
        self.tableview.separatorStyle = .none
        
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer()
        tapGesture.addTarget(self, action: #selector(tapGestureHandler))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tapGestureHandler(){
        self.dismiss(animated: true, completion: nil)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DataCenter.shared.myPlayLists.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: EditMyListTableViewCell = tableView.dequeueReusableCell(withIdentifier: EditMyListTableViewCell.reuseId, for: indexPath) as! EditMyListTableViewCell
        
        let playList = DataCenter.shared.myPlayLists[indexPath.row]
        
        cell.set(listName: playList.name, count: playList.musicList.count)
        cell.set(iconOf: playList.weather)
        
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedListName = DataCenter.shared.myPlayLists[indexPath.row].name

        if let musicPk = self.currentMusicPk{
            DataCenter.shared.addMyListRequest(list: selectedListName, music: "\(musicPk)", completion: {
                self.dismiss(animated: true, completion: nil)
            })
        }
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    @IBAction func addListBtnTouched(_ sender: UIButton) {
        let addListVC: AddListViewController = AddListViewController(completion: {
            self.tableview.reloadData()
        })
        addListVC.modalPresentationStyle = .overCurrentContext
        present(addListVC, animated: false, completion: nil)
    }
    
    @IBAction func cancelBtnTouched(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
