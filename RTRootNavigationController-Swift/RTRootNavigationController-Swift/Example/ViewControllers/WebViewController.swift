//
//  WebViewController.swift
//  RTRootNavigationController-Swift
//
//  Created by wuweixin on 2019/7/28.
//  Copyright © 2019 wuweixin. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController {
    
    lazy var webView: WKWebView = WKWebView()
    lazy var indicateLabel: UILabel = UILabel()
    
    lazy var spinnerView: UIActivityIndicatorView = UIActivityIndicatorView(style: .white)
    
    override func loadView() {
        super.loadView()
        
        self.webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.webView.frame = self.view.bounds
        self.webView.navigationDelegate = self
        self.webView.allowsBackForwardNavigationGestures = true
        self.view.addSubview(self.webView)
        
        self.indicateLabel.font = UIFont.systemFont(ofSize: 14)
        self.indicateLabel.textColor = UIColor.white
        self.indicateLabel.numberOfLines = 2
        self.indicateLabel.textAlignment = .center
        self.indicateLabel.text = "Site provided by:\n"
        self.indicateLabel.sizeToFit()
        self.indicateLabel.translatesAutoresizingMaskIntoConstraints = false
        self.webView.insertSubview(self.indicateLabel, belowSubview: self.webView.scrollView)
        
        let constraints: [NSLayoutConstraint] = [NSLayoutConstraint(item: self.indicateLabel,
                                                                    attribute: .top,
                                                                    relatedBy: .equal,
                                                                    toItem: self.webView,
                                                                    attribute: .top,
                                                                    multiplier: 1.0,
                                                                    constant: 16),
                                                 NSLayoutConstraint(item: self.indicateLabel,
                                                                    attribute: .centerX,
                                                                    relatedBy: .equal,
                                                                    toItem: self.webView,
                                                                    attribute: .centerX,
                                                                    multiplier: 1.0,
                                                                    constant: 0)]
        self.webView.addConstraints(constraints)
        NSLayoutConstraint.activate(constraints)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.rt.disableInteractivePop = false

        // Do any additional setup after loading the view.
        
        self.navigationController?.isToolbarHidden = false
        self.navigationController?.toolbar.isTranslucent = false
        
        
        if let gestures = self.webView.gestureRecognizers {
            for gesture in gestures {
                if let edgeGesture = gesture as? UIScreenEdgePanGestureRecognizer {
                    self.rt.navigationController?.interactivePopGestureRecognizer?.require(toFail: edgeGesture)
                    break
                }
            }
        }
        
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.spinnerView)
        
        
        self.webView.load(URLRequest(url: URL(string: "https://github.com")!))
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func onBackward(_ sender: Any) {
        self.webView.goBack()
    }
    
    @IBAction func onForward(_ sender: Any) {
        self.webView.goForward()
    }
    
    @IBAction func onRefresh(_ sender: Any) {
        self.webView.reload()
    }
    
    @IBAction func onShare(_ sender: Any) {
    }
    
    @IBAction func onToggleToolbar(_ sender: Any) {
        guard let nav = self.navigationController else {
            return
        }
        nav.setToolbarHidden(!nav.isToolbarHidden, animated: true)
    }
    
}

extension WebViewController: RTNavigationItemCustomizable {
    func customBackItemWithTarget(_ target: Any?, action: Selector) -> UIBarButtonItem? {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "back"), for: .normal)
        button.sizeToFit()
        button.addTarget(target, action: action, for: .touchUpInside)
        return UIBarButtonItem(customView: button)
    }
}


extension WebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        self.spinnerView.startAnimating()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.spinnerView.stopAnimating()
        self.indicateLabel.text = "Site provided by: \(webView.url?.absoluteString ?? "")"
        self.title = webView.title
        
        self.toolbarItems?[0].isEnabled = webView.canGoBack
        self.toolbarItems?[2].isEnabled = webView.canGoForward
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        self.spinnerView.stopAnimating()
    }
}
