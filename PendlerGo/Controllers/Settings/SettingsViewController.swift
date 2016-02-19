//
//  SettingsViewController.swift
//  PendlerGo
//
//  Created by Philip Engberg on 19/02/16.
//
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class SettingsViewController: UIViewController {
    
    let _view = SettingsView()
    let viewModel = SettingsViewModel()
    let bag = DisposeBag()
    
    override func loadView() {
        view = _view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.locations.asObservable().subscribeNext { (locations) -> Void in
            print("First: \(locations.first)")
        }.addDisposableTo(bag)
        
        _view.homeTextField.rx_text.throttle(0.2, scheduler: MainScheduler.instance).bindTo(viewModel.query).addDisposableTo(bag)
        
        _view.searchResultsTableView.registerCell(LocationCell.self)
        _view.searchResultsTableView.dataSource = self
        _view.searchResultsTableView.allowsSelection = false
        
        viewModel.locations.asObservable().subscribeNext { [weak self] (locations) -> Void in
            self?._view.searchResultsTableView.reloadData()

            if locations.count > 0 {
                self?._view.showResults()
            } else {
                self?._view.hideResults()
            }
            
        }.addDisposableTo(bag)
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
}

extension SettingsViewController : UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.locations.value.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(LocationCell.self, indexPath: indexPath)
        cell.configure(viewModel.locations.value[indexPath.row])
        return cell
    }
}
