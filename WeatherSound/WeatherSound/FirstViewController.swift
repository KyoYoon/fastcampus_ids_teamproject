//
//  FirstViewController.swift
//  DYMusicPlayer
//
//  Created by Dong Yoon Han on 8/3/17.
//  Copyright © 2017 DY. All rights reserved.
//

import UIKit
import ARNTransitionAnimator

class FirstViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SongDataSource.shared.songDatas.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        guard let cellTextLabel = cell.textLabel else { return cell}
        cellTextLabel.text = SongDataSource.shared.songDatas[indexPath.row].songTitle
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let secondVC = SecondViewController()
//        self.navigationController?.pushViewController(secondVC, animated: true)
//        self.present(secondVC, animated: true, completion: nil)
        print("\(indexPath) is seleceted")
    }
    
}
