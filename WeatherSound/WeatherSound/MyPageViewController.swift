//
//  MyPageViewController.swift
//  WeatherSound
//
//  Created by HyunJomi on 2017. 8. 7..
//  Copyright © 2017년 HyunJung. All rights reserved.
//

import UIKit

class MyPageViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var myPageTableView: UITableView!
    
    @IBOutlet weak var userInfoViewContainer: UIView!
    @IBOutlet weak var userInfoView: UIView! //배경

    @IBOutlet weak var profileImgView: UIImageView! //프로필사진
    @IBOutlet weak var profileLable: UILabel!
    
    @IBOutlet weak var myListButton: UIButton!

    var backgroundProfileImageView: UIImageView! = {
        let imgView = UIImageView()
        return imgView
    }()
    
    var effectView: UIView! = {
        let imgView = UIView()
        return imgView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.myPageTableView.delegate = self
        self.myPageTableView.dataSource = self
        
        //main의 locationManager호출해서 delegate 끊기
//        let main: MainViewController = (self.navigationController as? MainViewController)!
//        main.locationManager.stopMonitoringSignificantLocationChanges()

        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "< HOME", style: .plain, target: self, action: #selector(backToHome))
//        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "M", style: .plain, target: self, action: #selector(hamHandler))

        let btn = UIButton()
        btn.setImage(#imageLiteral(resourceName: "hamMenu"), for: .normal)
        
        self.prepareView()

    }
    func backToHome(){
        self.navigationController?.popViewController(animated: true)
    }
    func hamHandler(){
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func prepareView(){
        
        let rect = self.view.bounds
        
        self.myPageTableView.frame = CGRect(x: 0, y: 0, width: rect.width, height: rect.height)
        self.userInfoViewContainer.frame = CGRect(x: 0, y: 0, width: rect.width, height: 300)
        self.userInfoView.frame = CGRect(x: 0, y: 0, width: rect.width, height: 245)
        self.myListButton.frame = CGRect(x: rect.minX+20, y: self.userInfoView.frame.maxY+12.5,width: rect.width, height: 30)
        
        let attributedString: NSMutableAttributedString = NSMutableAttributedString(string: "내 리스트  > ", attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 15, weight: UIFontWeightBold), NSForegroundColorAttributeName: UIColor(red:0.29, green:0.56, blue:0.89, alpha:1.00)])
        self.myListButton.contentHorizontalAlignment = .left
        self.myListButton.setAttributedTitle(attributedString, for: .normal)
        
        self.profileImgView.frame = CGRect(x: self.userInfoView.frame.midX-40, y: self.userInfoView.frame.midY-64+40, width: 80, height: 80)
        self.profileImgView.layer.cornerRadius = 40
        
        //hotdog asset쓰는 부분 url로 가져오는 것으로 수정 예정
        self.profileImgView.image = #imageLiteral(resourceName: "hotdog")
        
        self.backgroundProfileImageView.frame = CGRect(x: 0, y: 0, width: rect.width, height: 245)
        self.backgroundProfileImageView.image = #imageLiteral(resourceName: "hotdog")
        self.backgroundProfileImageView.contentMode = .center
        
        self.effectView.frame = self.userInfoView.frame
        self.effectView.backgroundColor = .gray
        self.effectView.alpha = 0.1
        
        self.userInfoView.addSubview(self.effectView)
        self.userInfoView.addSubview(self.backgroundProfileImageView)
        self.backgroundProfileImageView.sendSubview(toBack: self.effectView)
        self.userInfoView.bringSubview(toFront: self.profileImgView)
        self.userInfoView.bringSubview(toFront: self.profileLable)

        self.profileLable.frame = CGRect(x: 0, y:  self.profileImgView.frame.maxY+2, width: rect.width, height: 50)
        self.profileLable.textAlignment = .center
        let attributedProfileString: NSMutableAttributedString = NSMutableAttributedString(string: "hyunjung", attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 18, weight: UIFontWeightLight), NSForegroundColorAttributeName: UIColor(red:0.29, green:0.26, blue:0.28, alpha:1.00)])
        attributedProfileString.append(NSAttributedString(string: "\nseoul", attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 17, weight: UIFontWeightUltraLight), NSForegroundColorAttributeName: UIColor(red:0.29, green:0.26, blue:0.28, alpha:1.00)]))
        self.profileLable.attributedText = attributedProfileString
        self.profileLable.numberOfLines = 0
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if section == 0{
            return "공개"
        }
        else{
            return "비공개"
        }
    }
    

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let label : UILabel = UILabel()
        
        if section == 0{
            label.text = "    공개"
        }
        else{
            label.text = "    비공개"
        }
        label.font = UIFont.systemFont(ofSize: 16, weight: UIFontWeightMedium)
        label.backgroundColor = UIColor(red:0.29, green:0.56, blue:0.89, alpha:0.05)
        
        return label
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListCell", for: indexPath)
        
        cell.textLabel?.text = "임현정의 리스트"
        
        return cell
    }
    
    
    @IBAction func MyListButtonTouched(_ sender: UIButton) {
        
        print("mylist Touched")
    }
}
