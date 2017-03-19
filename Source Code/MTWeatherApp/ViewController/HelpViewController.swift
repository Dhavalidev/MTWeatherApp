//
//  HelpViewController.swift
//  MTWeatherApp
//
//  Created by Dhaval on 3/19/17.
//  Copyright © 2017 Dhaval. All rights reserved.
//

import UIKit

class HelpViewController: UIViewController, UIWebViewDelegate {

    @IBOutlet weak var webView: UIWebView!
    
    // MARK:- View Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        loadUrl()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadUrl()
    {
        webView.loadRequest(URLRequest.init(url: URL.init(string: "http://google.com")!, cachePolicy: URLRequest.CachePolicy.reloadIgnoringCacheData, timeoutInterval: 20))
    }

    // MARK:- Web View Delegate Methods
    func webViewDidStartLoad(_ webView: UIWebView) {
        NetworkManager.sharedManager.showActivityIndicator(uiView: self.view)
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        NetworkManager.sharedManager.hideActivityIndicator(uiView: self.view)
    }
   
    @IBAction func doneBtnClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
