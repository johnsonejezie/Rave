//
//  RedirectVC.swift
//  Rave
//
//  Created by Johnson Ejezie on 28/01/2017.
//  Copyright © 2017 johnsonejezie. All rights reserved.
//

import UIKit

class RedirectVC: UIViewController {

    fileprivate var loadingView:UIView?
    var url:String!
    var completedRedirect:((String?)->())?
    @IBOutlet var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let cancel = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(RedirectVC.cancelTapped(_:)))
        self.navigationItem.leftBarButtonItem = cancel
//        let done = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(RedirectVC.doneTapped(_:)))
//        self.navigationItem.rightBarButtonItem = done
        self.webView.delegate = self
        guard let url = URL(string: self.url) else {
            print("failed to create url")
            return
        }
        webView?.loadRequest(URLRequest(url: url))
        // Do any additional setup after loading the view.
    }
    
//    func doneTapped(_ sender:UIBarButtonItem) {
//        let doc = self.webView?.stringByEvaluatingJavaScript(from: "document.documentElement.outerHTML")!
//        
//        let startIndexJSON  = doc?.range(of:"{")?.lowerBound
//        
//        let endIndexJSON  = doc?.range(of:"}}")?.lowerBound
//        
//        let adv = doc?.index(endIndexJSON!, offsetBy: 2)
//        
//        let finalJson =   doc?.substring(with: startIndexJSON!..<adv!)
//        guard let jsonString = finalJson else {
//            completedRedirect?(nil)
//            return
//        }
//        loadingView?.removeFromSuperview()
//        completedRedirect?(jsonString)
//        self.dismiss(animated: true, completion: nil)
//    }
    
    func cancelTapped(_ sender:UIBarButtonItem) {
        completedRedirect?(nil)
        self.dismiss(animated: true, completion: nil)
    }

}
extension RedirectVC:UIWebViewDelegate {
    func webViewDidStartLoad(_ webView: UIWebView) {
        // Box config:
        loadingView = UIView(frame: CGRect(x: 115, y: 110, width: 80, height: 80))
       
        loadingView?.backgroundColor = UIColor.black
        loadingView?.alpha = 0.9
        loadingView?.layer.cornerRadius = 10
        
        // Spin config:
        let activityView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
        activityView.frame = CGRect(x: 20, y: 12, width: 40, height: 40)
        activityView.startAnimating()
        
        // Text config:
        let textLabel = UILabel(frame: CGRect(x: 0, y: 50, width: 80, height: 30))
        textLabel.textColor = UIColor.white
        textLabel.textAlignment = .center
        textLabel.font = UIFont(name: textLabel.font.fontName, size: 13)
        textLabel.text = "Loading..."
        
        // Activate:
        loadingView?.addSubview(activityView)
        loadingView?.addSubview(textLabel)
        view.addSubview(loadingView!)
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        let url = webView.request?.url
        if let url = url?.absoluteString {
            let urlString = url as NSString
            let range = urlString.range(of: FWConstants.BaseURL, options: .caseInsensitive)
            
            if range.location != NSNotFound {
                let doc = self.webView?.stringByEvaluatingJavaScript(from: "document.documentElement.outerHTML")!
                
                let startIndexJSON  = doc?.range(of:"{")?.lowerBound
                
                let endIndexJSON  = doc?.range(of:"}}")?.lowerBound
                
                let adv = doc?.index(endIndexJSON!, offsetBy: 2)
                
                let finalJson =   doc?.substring(with: startIndexJSON!..<adv!)
                guard let jsonString = finalJson else {
                    completedRedirect?(nil)
                    self.dismiss(animated: true, completion: nil)
                    return
                }
                loadingView?.removeFromSuperview()
                completedRedirect?(jsonString)
                self.dismiss(animated: true, completion: nil)
            }
        }
        loadingView?.removeFromSuperview()
        
    }
}
