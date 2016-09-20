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
        _view.tableView.registerCell(LoadMoreCell.self)
        _view.tableView.dataSource = self
        _view.tableView.delegate = self
        
        _view.refreshControl.rx_controlEvent(.ValueChanged).subscribeNext { [weak self] in
            if let _ = self?._view.refreshControl.refreshing {
                self?.viewModel.update()
            }
        }.addDisposableTo(bag)
        
        viewModel.departures.asObservable().subscribeNext { [weak self] (departures) -> Void in
            guard let s = self else { return }
            
            let currentCount = s._view.tableView.numberOfRowsInSection(0) - 1
            let newCount = departures.count
            let diff = newCount - currentCount
            
            if currentCount > 0 && diff > 0 {
                
                var newIndexPaths: [NSIndexPath] = []
                for index in currentCount...(newCount - 1) {
                    newIndexPaths.append(NSIndexPath(forRow: index, inSection: 0))
                }
                
                s._view.tableView.beginUpdates()
                s._view.tableView.insertRowsAtIndexPaths(newIndexPaths, withRowAnimation: .Fade)
                s._view.tableView.endUpdates()
                
            } else {
            
                self?._view.tableView.reloadData()
                self?._view.tableView .scrollRectToVisible(CGRect(x: 0, y: 0, width: 1, height: 1), animated: true)
            
            }
            
            self?._view.refreshControl.endRefreshing()
        }.addDisposableTo(bag)
        
        viewModel.details.asObservable().subscribeNext { [weak self] (details) -> Void in
            self?._view.tableView.reloadData()
//            guard let s = self where details.count > 0 && details.count <= s.viewModel.departures.value.count else { return }
//            var toReload: [NSIndexPath] = []
//            for index in 0...details.count - 1 {
//                if details[index].allMessages.characters.count > 0 {
//                    toReload.append(NSIndexPath(forRow: index, inSection: 0))
//                }
//            }
//            
//            self?._view.tableView.reloadRowsAtIndexPaths(toReload, withRowAnimation: .Fade)
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
        return _view.tableView.contentOffset.y > 0
    }
    
}

extension BoardViewController : UITableViewDataSource, UITableViewDelegate {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = viewModel.departures.value.count
        return count + (count > 0 ? 1 : 0)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.row == viewModel.departures.value.count {
            return tableView.dequeueCell(LoadMoreCell.self, indexPath: indexPath)
        }
        
        let cell = tableView.dequeueCell(BoardDepartureCell.self, indexPath: indexPath)
        if viewModel.details.value.count > indexPath.row {
            cell.configure(viewModel.departures.value[indexPath.row], journeyDetail: viewModel.details.value[indexPath.row])
        } else {
            cell.configure(viewModel.departures.value[indexPath.row], journeyDetail: nil)
        }
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row == viewModel.departures.value.count {
            return LoadMoreCell.height()
        } else {
            if viewModel.details.value.count > indexPath.row {
                return BoardDepartureCell.height(viewModel.departures.value[indexPath.row], journeyDetail: viewModel.details.value[indexPath.row])
            } else {
                return BoardDepartureCell.height(viewModel.departures.value[indexPath.row], journeyDetail: nil)
            }
        }
    }
    
    func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return indexPath.row == viewModel.departures.value.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == viewModel.departures.value.count {
            viewModel.loadMore()
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
    }
}

