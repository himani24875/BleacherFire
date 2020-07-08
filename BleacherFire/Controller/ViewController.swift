//
//  ViewController.swift
//  BleacherFire
//
//  Created by Himani on 02/07/20.
//  Copyright © 2020 Himani. All rights reserved.
//

import UIKit
import TwitterKit

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    let listOfTweetsAndVideos = ListDataProvider.list
    var tweetData: Tweet?
    let client = TWTRAPIClient()
    var listOfData = [CellData]()
    var indicator = UIActivityIndicatorView(style: .medium)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.registerCell()
        self.getTweetDataList()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        self.tableView.visibleCells.forEach { (cell) in
            let listCell = cell as! ListItemTVC
            if listCell.player != nil {
                listCell.player.pause()
            }
        }
    }
    
    private func registerCell() {
        self.tableView.register(UINib(nibName: Constants.IDENTIFIERS.LIST_ITEM_TVC, bundle: nil), forCellReuseIdentifier: Constants.IDENTIFIERS.LIST_ITEM_TVC)
    }
    
    func openWebViewVC(url: String) {
        let webViewVC = self.storyboard?.instantiateViewController(identifier: Constants.IDENTIFIERS.WEB_VIEW_VC) as! WebViewVC
        webViewVC.urlString = url
        webViewVC.providesPresentationContextTransitionStyle = true
        webViewVC.modalPresentationStyle = .overCurrentContext
        self.navigationController?.pushViewController(webViewVC, animated: true)
    }
}

//MARK:- UITableViewDataSource
extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.listOfData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.IDENTIFIERS.LIST_ITEM_TVC, for: indexPath) as! ListItemTVC
        cell.data = self.listOfData[indexPath.row]
        cell.delegate = self
        return cell
    }
}

//MARK:- UITableViewDelegate
extension ViewController: UITableViewDelegate {
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        let visibleCells = self.tableView.visibleCells
        if visibleCells.count > 0 {
            visibleCells.forEach { (cell) in
                let listCell = cell as! ListItemTVC
                listCell.notifyIsCellCompletelyVisible = checkVisibilityOfCells(cell: listCell)
            }
        }
//        if let indexPathForVisibleCells = self.tableView.indexPathsForVisibleRows {
//            if indexPathForVisibleCells.count > 0 {
//                for indexPath in indexPathForVisibleCells {
//                    let currentCell = self.tableView.cellForRow(at: indexPath) as! ListItemTVC
//                    currentCell.notifyIsCellCompletelyVisible = checkVisibilityOfCells(cell: currentCell, indexPath: indexPath)
//                }
//            }
//        }
    }
    
    func checkVisibilityOfCells(cell: ListItemTVC) -> Bool {
        let cellRect = cell.frame
//        let cellRect = self.tableView.rectForRow(at: indexPath)
        let completelyVisible = self.tableView.bounds.contains(cellRect)
        return completelyVisible
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let item = cell as! ListItemTVC
        if item.player != nil {
            if item.player.rate != 0.0 {
                item.player = nil
            }
        }
        
        if item.ytPlayer != nil {
            item.ytPlayer.playbackRate({ (rate, error) in
                if rate != 0.0 {
                    item.ytPlayer = nil
                }
            })
        }
    }
}

extension ViewController {
    func showLoader() {
        self.indicator.frame = self.tableView.frame
        self.indicator.center = self.tableView.center
        self.tableView.addSubview(self.indicator)
        self.indicator.startAnimating()
    }
    
    func hideLoader() {
        self.indicator.stopAnimating()
        self.indicator.removeFromSuperview()
    }
    
    func getTweetDataList() {
        self.showLoader()
        let myGroup = DispatchGroup()
        let dispatchQueue = DispatchQueue(label: "myQueue")
        let dispatchSemaphore = DispatchSemaphore(value: 0)
        
        dispatchQueue.async {
            for item in self.listOfTweetsAndVideos {
                myGroup.enter()
                var cellData = CellData()
                cellData.urlString = item
                cellData.isYoutubeLink = item.contains("youtube")
                if let id = item.split(separator: "/").last?.description {
                    if cellData.isYoutubeLink {
                        self.getVideoDetailsByYoutubeId(id: id, success: { (videoResponse) in
                            cellData.videoData = videoResponse
                            self.listOfData.append(cellData)
                            dispatchSemaphore.signal()
                            myGroup.leave()
                        }) { (error) in
                            print("Error: \(String(describing: error))")
                        }
                        dispatchSemaphore.wait()
                    } else {
                        self.getTweetById(id: id, success: { (tweetResponse) in
                            cellData.data = tweetResponse
                            self.listOfData.append(cellData)
                            dispatchSemaphore.signal()
                            myGroup.leave()
                        }) { (error) in
                            print("Error: \(String(describing: error))")
                        }
                        dispatchSemaphore.wait()
                    }
                }
            }
        }
        
        myGroup.notify(queue: dispatchQueue) {
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.hideLoader()
            }
        }
    }
    
    func getVideoDetailsByYoutubeId(id: String, success: @escaping(Video) -> Void, failure: @escaping(Error?) -> Void) {
        let urlString = Constants.YT_BASE_URL + id
        let url = URL(string: urlString)!
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            if error != nil {
                failure(error)
            } else {
                if let data = data {
                    
                    let decoder = JSONDecoder()
                    let jsonResponse = try! decoder.decode(Video.self, from: data)
                    success(jsonResponse)
                }
            }
            
        }
        task.resume()
    }
    
    func getTweetById(id: String, success: @escaping(Tweet) -> Void, failure: @escaping(Error?) -> Void) {
        
        let statusesShowEndpoint = Constants.TW_BASE_URL + id
        
        let params = ["id": id]
        var clientError : NSError?
        let request = self.client.urlRequest(withMethod: "GET", urlString: statusesShowEndpoint, parameters: params, error: &clientError)
        
        self.client.sendTwitterRequest(request) { (resposne, data, connectionError) in
            if (connectionError == nil) {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = JSONDecoder.DateDecodingStrategy.formatted(DateFormatter.iso8601Full)
                
                let jsonResponse = try! decoder.decode(Tweet.self, from: data!)
                success(jsonResponse)
                
            }else {
                failure(connectionError)
            }
        }
    }
}

extension ViewController: ListItemVCDelegate {
    func openWebView(with url: String) {
        self.openWebViewVC(url: url)
    }
    
    func shareLink(with url: String) {
        let objectsToShare = [url] as [Any]
        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        activityVC.excludedActivityTypes = [UIActivity.ActivityType.airDrop, UIActivity.ActivityType.addToReadingList]
        self.present(activityVC, animated: true, completion: nil)
    }
    
}

extension Formatter {
    static let iso8601Full: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }()
}

