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

class BoardViewController : UIViewController {
    
    let bag = DisposeBag()
    
    let viewModel = BoardViewModel()
    let _view = BoardView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Sorø st."
        
        let refresh = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Refresh, target: nil, action: nil)
        self.navigationItem.rightBarButtonItem = refresh
        refresh.rx_tap.subscribeNext { [weak self] (_) -> Void in
//            let modal = SettingsViewController()
//            modal.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
//            self?.presentViewController(modal, animated: true, completion: {})

            self?.viewModel.update()
        }.addDisposableTo(bag)
        
        _view.tableView.registerCell(BoardDepartureCell.self)
        _view.tableView.dataSource = self
        _view.tableView.allowsSelection = false
        
        viewModel.departures.asObservable().subscribeNext { [weak self] (_) -> Void in
            self?._view.tableView.reloadData()
        }.addDisposableTo(bag)
        
        
        viewModel.update()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        viewModel.update()
    }
    
    override func loadView() {
        view = _view
    }
    
}

extension BoardViewController : UITableViewDataSource {
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
}

