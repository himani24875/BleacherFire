//
//  ListItemTVC.swift
//  BleacherFire
//
//  Created by Himani on 02/07/20.
//  Copyright © 2020 Himani. All rights reserved.
//

import UIKit
import WebKit
import AVKit
import AVFoundation
import youtube_ios_player_helper

protocol ListItemVCDelegate {
    func shareLink(with url: String)
    func openWebView(with url: String)
}

class ListItemTVC: UITableViewCell, WKNavigationDelegate {

    @IBOutlet weak var avPlayerView: UIView!
    @IBOutlet weak var ytPlayerView: UIView!
    @IBOutlet weak var shareBtn: UIButton!
    
    @IBOutlet weak var userImgView: UIImageView!
    @IBOutlet weak var userNameLbl: UILabel!
    @IBOutlet weak var logoImgView: UIImageView!
    @IBOutlet weak var twitterHandleLbl: UILabel!
    @IBOutlet weak var postedTimeLbl: UILabel!
    @IBOutlet weak var tweetTextLbl: UILabel!
    @IBOutlet weak var userInfoView: UIView!
    @IBOutlet weak var verifiedImg: UIImageView!
    
    @IBOutlet weak var videoInfoView: UIView!
    @IBOutlet weak var videoTitleLbl: UILabel!
    @IBOutlet weak var videoDescriptionLbl: UILabel!
    @IBOutlet weak var channelNameLbl: UILabel!
    @IBOutlet weak var videoPostedTimeAgoLbl: UILabel!
    @IBOutlet weak var cardView: UIStackView!
    
    var wkWebView: WKWebView!
    var delegate: ListItemVCDelegate!
    var player: AVPlayer!
    var ytPlayer: YTPlayerView!
        
    var data: CellData? {
        didSet {
            if let cellData = data {
                self.ytPlayerView.isHidden = !cellData.isYoutubeLink
                self.avPlayerView.isHidden = cellData.isYoutubeLink
                self.userInfoView.isHidden = cellData.isYoutubeLink
                self.videoInfoView.isHidden = !cellData.isYoutubeLink
                if cellData.isYoutubeLink {
                    self.setVideoData(data: cellData.videoData, urlString: cellData.urlString)
                } else {
                    self.setData(data: cellData.data)
                }
            }
        }
    }
    
    var notifyIsCellCompletelyVisible = false {
        didSet {
            if ytPlayer != nil {
                player = nil
                if notifyIsCellCompletelyVisible {
                    ytPlayer.playVideo()
                } else {
                    ytPlayer.stopVideo()
                }
            }
            
            if player != nil {
                ytPlayer = nil
                if notifyIsCellCompletelyVisible {
                    player.play()
                } else {
                    player.pause()
                }
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.userImgView.layer.cornerRadius = userImgView.frame.size.width * 0.5
        self.userImgView.clipsToBounds = true
        self.setUpCardView()
        
        self.userInfoView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openWebView)))
        self.videoInfoView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openWebView)))
    }
    
    private func setUpCardView() {
//        self.cardView.layer.cornerRadius = 5.0
//        self.cardView.layer.borderWidth = 1.0
//        self.cardView.layer.borderColor = UIColor.clear.cgColor
//        self.cardView.layer.masksToBounds = true
        
        self.contentView.layer.shadowColor = UIColor.gray.cgColor
        self.contentView.layer.shadowOffset = CGSize(width: 0, height: 1.0)
        self.contentView.layer.shadowRadius = 5.0
        self.contentView.layer.shadowOpacity = 0.7
        self.contentView.layer.masksToBounds = false
    }
    
//    private func initializeWebView(urlString: String) {
//        let config = WKWebViewConfiguration.init()
//        config.allowsInlineMediaPlayback = true
//        config.mediaTypesRequiringUserActionForPlayback = .video
//        self.wkWebView = WKWebView.init(frame: self.playerView.bounds, configuration: config)
//        self.wkWebView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        self.wkWebView.navigationDelegate = self
//        self.wkWebView.scrollView.isScrollEnabled = false
//        self.playerView.addSubview(wkWebView)
//        self.loadVideo(urlString: urlString)
//    }
    
//    func loadVideo(urlString: String) {
//        let url = Bundle.main.path(forResource: "player", ofType: "html")!
//        let htmlString = htmlStringWithFilePath(url)!
//        let videoHTMLString = htmlString.replacingOccurrences(of: "%@", with: urlString + "?enablejsapi=1&rel=0&playsinline=1&autoplay=1")
//
//        self.wkWebView.loadHTMLString(videoHTMLString, baseURL: nil)
//    }
    
    func loadTwitterVideo(videoUrl: String) {
        let url = URL(string: videoUrl)!
        let asset = AVAsset(url: url)
        let playerItem = AVPlayerItem(asset: asset)
        self.player = AVPlayer(playerItem: playerItem)
        self.player.volume = 0.0
        let playerLayer = AVPlayerLayer(player: self.player)
        playerLayer.frame = self.avPlayerView.bounds
        playerLayer.videoGravity = .resizeAspectFill
        self.avPlayerView.layer.addSublayer(playerLayer)
        self.addGestureRecognizers()
    }
    
    func addGestureRecognizers() {
        // 1
        let tap = UITapGestureRecognizer(target: self, action: #selector(wasTapped))
        let doubleTap = UITapGestureRecognizer(target: self,
                                               action: #selector(wasDoubleTapped))
        doubleTap.numberOfTapsRequired = 2
        
        tap.require(toFail: doubleTap)
        
        self.avPlayerView.addGestureRecognizer(tap)
        self.avPlayerView.addGestureRecognizer(doubleTap)
        
    }
    
    @objc func wasTapped() {
        player.volume = player.volume == 1.0 ? 0.0 : 1.0
    }

    @objc func wasDoubleTapped() {
      player.rate = player.rate == 1.0 ? 2.0 : 1.0
    }
    
    @objc func openWebView() {
        if self.player != nil {
            self.player.pause()
        }
        if self.ytPlayer != nil {
            self.ytPlayer.stopVideo()
        }
        self.delegate.openWebView(with: data!.urlString)
    }
    
//    fileprivate func htmlStringWithFilePath(_ path: String) -> String? {
//
//        var error: NSError?
//
//        let htmlString: NSString?
//        do {
//            htmlString = try NSString(contentsOfFile: path, encoding: String.Encoding.utf8.rawValue)
//        } catch let error1 as NSError {
//            error = error1
//            htmlString = nil
//        }
//
//        if let _ = error {
//            print("Lookup error: no HTML file found for path, \(path)")
//        }
//
//        return htmlString! as String
//    }
    
    func loadYTVideo(with id: String) {
        self.ytPlayer = YTPlayerView()
        self.ytPlayer.frame = self.ytPlayerView.bounds
        self.ytPlayerView.addSubview(self.ytPlayer)
        self.ytPlayer.isUserInteractionEnabled = false
        let playerVars = ["playsinline" : 1,
        "autoplay" : 0,
        "rel" : 0,
        "controls" : 0,
        "modestbranding" : 0]
        self.ytPlayer.load(withVideoId: id, playerVars: playerVars)
    }
    
    func setVideoData(data: Video?, urlString: String) {
        if let data = data, let items = data.items, items.count > 0, let snippet = items[0].snippet {
            self.loadYTVideo(with: items[0].id!)
            self.videoTitleLbl.text = snippet.title
            self.videoDescriptionLbl.text = snippet.description?.trimmingCharacters(in: .whitespacesAndNewlines)
            self.channelNameLbl.text = snippet.channelTitle
            if let date = GlobalFunctions.sharedManager.getDate(from: snippet.publishedAt, dateFormat: Constants.YT_DATE_TIME_FORMAT) {
                let timeAgo = GlobalFunctions.sharedManager.timeAgoSinceDate(date: date as NSDate, numericDates: true)
                self.videoPostedTimeAgoLbl.text = timeAgo
            }
        }
    }
    
    func setData(data: Tweet?) {
        if let data = data {
            if let user = data.user {
                self.userNameLbl.text = user.name
                self.tweetTextLbl.text = data.text?.trimmingCharacters(in: .whitespacesAndNewlines)
                self.twitterHandleLbl.text = "@" + (user.screenName ?? " ")
                if let date = GlobalFunctions.sharedManager.getDate(from: data.createdAt!, dateFormat: Constants.TW_DATE_TIME_FORMAT) {
                    let timeAgo = GlobalFunctions.sharedManager.timeAgoSinceDate(date: date as NSDate, numericDates: true)
                    self.postedTimeLbl.text = timeAgo
                }
                
                if let isVerified = user.verified, isVerified {
                    self.verifiedImg.isHidden = false
                } else {
                    self.verifiedImg.isHidden = true
                }
                
                if let urlString = user.profileImageUrl {
                    let url = URL(string: urlString)!
                    GlobalFunctions.sharedManager.getImageFromURL(url: url) { (image) in
                        DispatchQueue.main.async {
                            self.userImgView.image = image
                        }
                    }
                }
            }
            
            if let extentedEntities = data.extendedEntities {
                if let media = extentedEntities.media, media.count > 0 {
                    if let videoInfo = media[0].videoInfo {
                        if let variants = videoInfo.variants, variants.count > 0 {
                            if let videoUrl = variants[0].url {
                                self.loadTwitterVideo(videoUrl: videoUrl)
                            }
                        }
                    }
                }
            } else {
                self.avPlayerView.isHidden = true
            }
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    
    @IBAction func onShareButtonClicked(_ sender: UIButton) {
        self.delegate.shareLink(with: self.data?.urlString ?? "")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.userNameLbl.text = ""
        self.twitterHandleLbl.text = ""
        self.tweetTextLbl.text = ""
        self.userImgView.image = nil
        self.verifiedImg.isHidden = true
        self.postedTimeLbl.text = ""
        
        self.videoTitleLbl.text = ""
        self.videoDescriptionLbl.text = ""
        self.channelNameLbl.text = ""
        self.videoPostedTimeAgoLbl.text = ""
        
        if self.player != nil {
            self.player = nil
        }
        
        if self.ytPlayer != nil {
            self.ytPlayer = nil
        }
    }
}
