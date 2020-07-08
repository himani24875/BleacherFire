//
//  WebViewVC.swift
//  BleacherFire
//
//  Created by Himani on 02/07/20.
//  Copyright © 2020 Himani. All rights reserved.
//

import UIKit
import WebKit

class WebViewVC: UIViewController, WKNavigationDelegate {
    
    var urlString: String!
    var indicator = UIActivityIndicatorView(style: .medium)
    
    @IBOutlet weak var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setUpWebView()
    }
    
    //MARK:- Custom Functions
    func setUpWebView() {
        self.webView.navigationDelegate = self
        self.webView.uiDelegate = self
        self.loadUrl()
    }
    
    func loadUrl() {
        if let searchText = self.urlString {
            let request = GlobalFunctions.sharedManager.getURL(searchText)
            self.webView.load(request)
        }
    }

}

//MARK:- WKNavigationDelegate
extension WebViewVC {
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        
        let alert = UIAlertController(title: "", message: error.localizedDescription, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default) {
            (action) in
            self.navigationController?.popViewController(animated: true)
        }
        
        alert.addAction(alertAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        self.showLoader()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.hideLoader()
    }
    
    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if(challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust)
        {
            let cred = URLCredential(trust: challenge.protectionSpace.serverTrust!)
            completionHandler(.useCredential, cred)
        }
        else
        {
            completionHandler(.performDefaultHandling, nil)
        }
    }
}

//MARK:- WKUIDelegate
extension WebViewVC: WKUIDelegate {
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if navigationAction.targetFrame == nil || navigationAction.targetFrame?.isMainFrame == false {
            self.webView.load(navigationAction.request)
        }
        return nil
    }
}

//MARK:- Loader Functions
extension WebViewVC {
    func showLoader() {
        self.indicator.frame = self.webView.frame
        self.indicator.center = self.webView.center
        self.webView.addSubview(self.indicator)
        self.indicator.startAnimating()
    }
    
    func hideLoader() {
        self.indicator.stopAnimating()
        self.indicator.removeFromSuperview()
    }
}
