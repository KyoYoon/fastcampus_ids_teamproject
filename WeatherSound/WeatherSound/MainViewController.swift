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
    var requestCount = 0
    //location에 따라 날씨 정보 가져옴
    var grid: (lon: Double,lat: Double)?{
        didSet{
            if let lon = grid?.lon, let lat = grid?.lat{
                
                DataCenter.shared.getCurrentWeatherFromFireBase(lon: lon, lat: lat, completion: { (weatherInfo) in
                    print("weather request complete")

                    self.weatherInfo = weatherInfo
                    self.setWeatherInfo()
                    self.requestCount += 1
                    print("//weather comlpete//request count : ", self.requestCount)
                })
            }
        }
    }
    
    //날씨정보 저장되는 시점에 추천 노래 리스트 가져옴
    var weatherInfo: Weather?{
        didSet{
            DataCenter.shared.getRecommendList(completion: { (musicArry) in
                print("music request complete")
                
                self.recommendMusicList = musicArry
                
                print("//music comlpete//request count : ", self.requestCount)
            })
        }
    }
    
    //날씨정보 가져오는 시점에 tableview reload
    var recommendMusicList: [Music]?{
        didSet {
            self.mainTableView.reloadData()
            
        }
    }
    
    //view
    var weatherInfoLabel: UILabel = {
        let label = UILabel()
        
        label.textAlignment = .center
        label.numberOfLines = 0
        
        return label
    }()
    
    
    //MARK:- life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.locationManager.delegate = self
        self.mainTableView.delegate = self
        self.mainTableView.dataSource = self
        
        //scroll refresh
        let refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSMutableAttributedString(string: "pull to refresh", attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 20, weight: UIFontWeightBold), NSForegroundColorAttributeName: UIColor(red:0.85, green:0.85, blue:0.85, alpha:1.00)])
        refreshControl.addTarget(self, action: #selector(refreshHandler(sender: )), for: .valueChanged)
        self.mainTableView.refreshControl = refreshControl
        
        //tableView Nib
        self.mainTableView.register(UINib.init(nibName: "MainTableViewCell", bundle: nil), forCellReuseIdentifier: MainTableViewCell.reuseId)
        
         self.loadLocation()
    }
    
    func refreshHandler(sender: UIRefreshControl){
        
        print("refresh")
        
        self.locationManager.requestLocation()
        
        sender.endRefreshing()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        //prepare view
        self.prepareView()
        self.setWeatherInfo()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:- location
    func loadLocation(){
        print("request location")
        
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.allowsBackgroundLocationUpdates = true
        self.locationManager.startMonitoringSignificantLocationChanges()
    }
    
    //MARK:- location delegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("location manager delegate - did upadate location")
        
        if let coor = manager.location?.coordinate{
            
            //기존 값이 있으면 거리 계산, 최초에는 바로 셋팅
            //두 위치의 차이가 5km이상일 경우에만 네트워크 리퀘
            if self.requestCount == 0{
                //최초
                self.grid = (coor.longitude, coor.latitude)
                self.locationManager.stopMonitoringSignificantLocationChanges()
                print("stop monitoring")
            }
            else{
                //refresh
                print("refresh- didUpdate")
                if let lon = self.grid?.lon, let lat = self.grid?.lat{
                    let diff = CommonLibraries.sharedFunc.distance(lat1: lat, lng1: lon, lat2: coor.latitude, lng2: coor.longitude)
                    if diff > 5 {
                        print("self.gird update")
                        self.grid = (coor.longitude, coor.latitude)
                    }
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    //MARK:- view
    //날씨 정보 있는 label 업데이트
    func setWeatherInfo(){

        self.weatherImageView.image = #imageLiteral(resourceName: "ClearDayIcon")
        
        if let info = weatherInfo {
            
            let attributedString: NSMutableAttributedString = NSMutableAttributedString(string: "\(info.curLocation)", attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 20, weight: UIFontWeightBold), NSForegroundColorAttributeName: UIColor(red:0.85, green:0.85, blue:0.85, alpha:1.00)])
            attributedString.append(NSAttributedString(string: "\n \(info.curTemperate)°", attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 60, weight: UIFontWeightBold), NSForegroundColorAttributeName: UIColor(red:0.29, green:0.26, blue:0.28, alpha:1.00)]))
            attributedString.append(NSAttributedString(string: "\n\(info.curWeather)", attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 20, weight: UIFontWeightBold), NSForegroundColorAttributeName: UIColor(red:0.85, green:0.85, blue:0.85, alpha:1.00)]))
            
            self.weatherInfoLabel.attributedText = attributedString
        }
        
    }
    
    //view layout
    func prepareView(){
        
        let rect = self.view.bounds
        
        self.mainTableView.separatorStyle = .none
        self.mainTableView.frame = CGRect(x: 0, y: 65, width: rect.width, height: rect.height-55-65)
        
        //weather image
        self.weatherImageView.frame = CGRect(x: 0, y: 0, width: rect.width, height: 300)
        self.weatherImageView.image = #imageLiteral(resourceName: "default")
        
        let header = self.weatherImageView.frame
        self.weatherInfoLabel.frame = CGRect(x: 0, y: header.midY-80, width: header.width, height: 160)
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
            cell.setAlbum(urlStr: item.albumImg)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        NotificationCenter.default.post(name: Notification.Name("SongSelectedFromMain"), object: nil, userInfo: ["SongSelectedRowAt": indexPath.row])
        print("indexPath.row touched : ", indexPath.row)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
