//
//  BoardViewController.swift
//  PendlerGo
//
//  Created by Philip Engberg on 18/02/16.
//
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class BoardViewController : UIViewController, ScrollableViewController {
    
    let bag = DisposeBag()
    
    let viewModel: BoardViewModel
    let _view = BoardView()
    
    init(locationType: Settings.LocationType) {
        self.viewModel = BoardViewModel(locationType: locationType)
        
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _view.tableView.registerCell(BoardDepartureCell.self)
        _view.tableView.dataSource = self
        _view.tableView.delegate = self
        _view.tableView.allowsSelection = false
        
        _view.refreshControl.rx_controlEvent(.ValueChanged).subscribeNext { [weak self] in
            if let _ = self?._view.refreshControl.refreshing {
                self?.viewModel.update()
            }
        }.addDisposableTo(bag)
        
        viewModel.departures.asObservable().subscribeNext { [weak self] (_) -> Void in
            self?._view.refreshControl.endRefreshing()
            self?._view.tableView.reloadData()
        }.addDisposableTo(bag)
        
    }
    
    override func loadView() {
        view = _view
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    func scrollToTop() {
        _view.tableView.scrollRectToVisible(CGRect(x: 0, y: 0, width: 1, height: 1), animated: true)
    }
    
    func isScrolledToTop() -> Bool {
        return false
    }
    
}

extension BoardViewController : UITableViewDataSource, UITableViewDelegate {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.departures.value.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(BoardDepartureCell.self, indexPath: indexPath)
        cell.configure(viewModel.departures.value[indexPath.row])
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let departure = viewModel.departures.value[indexPath.row]
        return departure.hasMessages ? 70 : 48
    }
}

