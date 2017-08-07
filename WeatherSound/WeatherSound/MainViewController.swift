//
//  MainViewController.swift
//  WeatherSound
//
//  Created by HyunJomi on 2017. 8. 2..
//  Copyright © 2017년 HyunJung. All rights reserved.
//

import UIKit
import CoreLocation

class MainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate{
    
    //IBOutlet
    @IBOutlet weak var mainTableView: UITableView!
    @IBOutlet weak var weatherImageView: UIImageView!

    //
    var locationManager = CLLocationManager()
    var recommendMusicList: [Music]?
    
    //view
    var weatherInfoLabel: UILabel = {
        let label = UILabel()
        
        label.textAlignment = .center
        label.numberOfLines = 0
        
        return label
    }()
    
    //life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.locationManager.delegate = self
        self.mainTableView.delegate = self
        self.mainTableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //tableView Nib
        self.mainTableView.register(UINib.init(nibName: "MainTableViewCell", bundle: nil), forCellReuseIdentifier: MainTableViewCell.reuseId)
        
        //location
        self.loadLocation()
        
        //tableView의 data
        
        
        //prepare view
        self.prepareView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:- location
    func loadLocation(){
        
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.allowsBackgroundLocationUpdates = true
        self.locationManager.startMonitoringSignificantLocationChanges() //위도,경도 바뀔때마다 locationManager()호출되고 날씨 레이블에 데이터 업데이트(데이터센터)
        
    }
    
    //MARK:- location delegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
       
        if let coor = manager.location?.coordinate{

            print("lon: ", coor.longitude, "lan: ", coor.latitude)
            let weatherInfo: Weather? = DataCenter.shared.getCurrentWeather(lon: coor.latitude, lan: coor.longitude)
            
            if let info = weatherInfo {
                
                let attributedString: NSMutableAttributedString = NSMutableAttributedString(string: "\(info.curLocation)", attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 20, weight: UIFontWeightBold), NSForegroundColorAttributeName: UIColor(red:0.85, green:0.85, blue:0.85, alpha:1.00)])
                attributedString.append(NSAttributedString(string: "\n \(info.curTemperate)°", attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 60, weight: UIFontWeightBold), NSForegroundColorAttributeName: UIColor(red:0.29, green:0.26, blue:0.28, alpha:1.00)]))
                attributedString.append(NSAttributedString(string: "\n\(info.curWeather)", attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 20, weight: UIFontWeightBold), NSForegroundColorAttributeName: UIColor(red:0.85, green:0.85, blue:0.85, alpha:1.00)]))
                
                self.weatherInfoLabel.attributedText = attributedString
            }
            
        }
        
        DataCenter.shared.getRecommendList()
        self.recommendMusicList = DataCenter.shared.recommendList
        self.mainTableView.reloadData()
    }
    
    func prepareView(){
        
        let rect = self.view.bounds
        
        self.mainTableView.frame = CGRect(x: 0, y: 0, width: rect.width, height: rect.height)

        //weather image
        self.weatherImageView.frame = CGRect(x: 0, y: 0, width: rect.width, height: 300)
        self.weatherImageView.image = #imageLiteral(resourceName: "ClearDayIcon")
        
        //weather info, 데이터 센터에서 가져오는 걸로...
        let header = self.weatherImageView.frame
        self.weatherInfoLabel.frame = CGRect(x: 0, y: header.midX-80, width: header.width, height: 160)
        self.weatherImageView.addSubview(self.weatherInfoLabel)
    }

    
    
    //MARK:- tableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.recommendMusicList?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MainTableViewCell.reuseId) as! MainTableViewCell
        
        if let item = self.recommendMusicList?[indexPath.row]{
             cell.set(title: item.title, artist: item.artist)
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    

}
