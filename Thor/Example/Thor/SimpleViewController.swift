//
//  SimpleViewController.swift
//  Thor_Example
//
//  Created by zhengxu on 2018/5/25.
//  Copyright © 2018年 CocoaPods. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Thor

class SimpleViewController: UIViewController {
    lazy var tableView: UITableView = {
       return UITableView(frame: self.view.bounds, style: .plain)
    }()
    
    var disposedBag = DisposeBag()
    let specialArrSubjec: BehaviorRelay<[Special]> = BehaviorRelay(value: [])
    
    let api = SimpleAPI()
    var loadButton: UIBarButtonItem!
    var reloadButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.addSubview(tableView)
        
        let toolbar = UIToolbar()
        self.view.addSubview(toolbar)
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        toolbar.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        toolbar.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        toolbar.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        
        loadButton = UIBarButtonItem(title: "load", style: .plain, target: self, action: #selector(loadData))
        reloadButton = UIBarButtonItem(title: "reload", style: .plain, target: self, action: #selector(reloadData))
        toolbar.items = [loadButton, UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil), reloadButton]
        
        
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        self.tableView.delegate = nil
        self.tableView.dataSource = nil
        
        specialArrSubjec.bind(to: self.tableView.rx.items(cellIdentifier: "Cell")){
            (_, model, cell) in
            cell.textLabel?.text = model.name
            }.disposed(by: disposedBag)
        
        
        loadData(force: true)
    }
    
    @objc func loadData(force: Bool = false) {
        guard force || api.paging.more else {
            promptSuccess(message: "没有更多了")
            return
        }
//        rxRequest()
        normalRequest()
    }
    
    func rxRequest() {
        api.rx_requestModel(type: SimpleAPIModel.self).subscribe(onSuccess: { [weak self] (model) in
            guard let br = self?.specialArrSubjec,
                let paging = self?.api.paging else { return }
            if let result =  model.result{
                print("当前: \(br.value.count), 新增: \(result.data.count), 总共: \(paging.total), 更多: \(paging.more)")
                br.variable.append(contentsOf: result.data)
            }
            }, onError: { [weak self] (error) in
                self?.promptError(message: error.localizedDescription)
            }).disposed(by: disposedBag)
    }
    
    func normalRequest() {
        requestPaging(api) { [weak self] (result) in
            switch result {
            case .success(let response):
                guard let br = self?.specialArrSubjec,
                    let paging = self?.api.paging else { return }
                do {
                    if let result = try response.value.mapModel(type: SimpleAPIModel.self).result {
                        print("当前: \(br.value.count), 新增: \(result.data.count), 总共: \(paging.total), 更多: \(paging.more)")
                        br.variable.append(contentsOf: result.data)
                    }
                    self?.loadButton.isEnabled = paging.more
                } catch {
                    self?.promptError(message: error.localizedDescription)
                }
                if response.isFromCache {
                    self?.promptSuccess(message: "数据来自缓存...")
                }
            case .failure(let error):
                if error.isInternetConnectionLost {
                    self?.promptError(message: "网络丢失了...")
                } else if error.isRequestTimeout {
                    self?.promptError(message: "网络不给力呀...")
                } else if let valueError = error.valueError {
                    self?.promptError(message: valueError.description)
                } else {
                    self?.promptError(message: "请求出错呀...")
                }
            }
        }
    }
    
    @objc func reloadData() {
        self.specialArrSubjec.variable.removeAll()
        api.resetPaging()
        loadData(force: true)
        
//        SimpleCDNAPI().rx_request().subscribe(onSuccess: { (resp) in
//            print("加载成功")
//        }) { (error) in
//            print("加载错误")
//        }.disposed(by: disposedBag)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    
    func prompt(title: String?, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func promptSuccess(message: String?) {
        prompt(title: "Success", message: message)
    }
    
    func promptError(message: String?) {
        prompt(title: "Error", message: message)
    }
}

extension BehaviorRelay {
    var variable: Element {
        get {
            return value
        }
        
        set {
            accept(newValue)
        }
    }
}
