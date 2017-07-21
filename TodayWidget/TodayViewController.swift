//
//  TodayViewController.swift
//  TodayWidget
//
//  Created by Philip Engberg on 20/07/2017.
//
//

import UIKit
import NotificationCenter
import RxSwift

class TodayViewController: UIViewController, NCWidgetProviding {
    
    let bag = DisposeBag()
        
    @IBOutlet weak var tableView: UITableView!
    
    let viewModel = TodayViewModel(locationType: .home)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        extensionContext?.widgetLargestAvailableDisplayMode = .expanded
        
        tableView.registerCell(BoardDepartureCell.self)
        viewModel.departures.asObservable().subscribe(onNext: { [weak self] (_) in
            self?.tableView.reloadData()
        }).addDisposableTo(bag)
        viewModel.update()
        // Do any additional setup after loading the view from its nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        completionHandler(NCUpdateResult.newData)
    }
    
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        if (activeDisplayMode == .expanded) {
            let totalHeight = viewModel.departures.value.reduce(0, { $0 + BoardDepartureCell.height($1, journeyDetail: nil) })
            self.preferredContentSize = CGSize(width: maxSize.width, height: totalHeight)
        } else if (activeDisplayMode == .compact) {
            self.preferredContentSize = maxSize;
        }
    }
    
}

extension TodayViewController : UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.departures.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueCell(BoardDepartureCell.self, indexPath: indexPath)
        cell.backgroundColor = .clear
        cell.configure(viewModel.departures.value[indexPath.row], journeyDetail: nil)
        return cell
    }
    
}

extension TodayViewController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return BoardDepartureCell.height(viewModel.departures.value[indexPath.row], journeyDetail: nil)
    }
}
