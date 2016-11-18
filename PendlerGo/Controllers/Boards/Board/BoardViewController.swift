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
        
        _view.refreshControl.rx.controlEvent(.valueChanged).subscribe(onNext: { [weak self] in
            if let _ = self?._view.refreshControl.isRefreshing {
                self?.viewModel.update()
                guard let s = self else { return }
                Analytics.Events.trackForceRefreshDepartureBoard(for: s.viewModel.locationType)
            }
        }).addDisposableTo(bag)
        
        viewModel.departures.asObservable().subscribe(onNext: { [weak self] (departures) -> Void in
            guard let s = self else { return }
            
            let currentCount = s._view.tableView.numberOfRows(inSection: 0) - 1
            let newCount = departures.count
            let diff = newCount - currentCount
            
            if currentCount > 0 && diff > 0 {
                
                var newIndexPaths: [IndexPath] = []
                for index in currentCount...(newCount - 1) {
                    newIndexPaths.append(IndexPath(row: index, section: 0))
                }
                
                s._view.tableView.beginUpdates()
                s._view.tableView.insertRows(at: newIndexPaths, with: .fade)
                s._view.tableView.endUpdates()
                
            } else {
            
                self?._view.tableView.reloadData()
                self?._view.tableView .scrollRectToVisible(CGRect(x: 0, y: 0, width: 1, height: 1), animated: true)
            
            }
            
            self?._view.refreshControl.endRefreshing()
        }).addDisposableTo(bag)
        
        viewModel.details.asObservable().subscribe(onNext: { [weak self] (details) -> Void in
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
        }).addDisposableTo(bag)
        
    }
    
    override func loadView() {
        view = _view
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    func scrollToTop() {
        _view.tableView.scrollRectToVisible(CGRect(x: 0, y: 0, width: 1, height: 1), animated: true)
    }
    
    func isScrolledToTop() -> Bool {
        return _view.tableView.contentOffset.y > 0
    }
    
}

extension BoardViewController : UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = viewModel.departures.value.count
        return count + (count > 0 ? 1 : 0)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
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
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return indexPath.row == viewModel.departures.value.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == viewModel.departures.value.count {
            viewModel.loadMore()
            tableView.deselectRow(at: indexPath, animated: true)
            Analytics.Events.trackForceLoadedMoreDepartures(for: viewModel.locationType, numberOfExistingDepartures: viewModel.departures.value.count)
        }
    }
}

