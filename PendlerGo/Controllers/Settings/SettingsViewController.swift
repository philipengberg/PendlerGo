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
import Action
import Google

class SettingsViewController: UIViewController {
    
    let _view = SettingsView()
    let viewModel = SettingsViewModel()
    let bag = DisposeBag()
    
    lazy var doneAction: CocoaAction = {
        return CocoaAction(workFactory: { [weak self] (_) -> Observable<Void> in
            self?._view.homeTextField.resignFirstResponder()
            self?._view.workTextField.resignFirstResponder()
            return Observable.just()
        })
    }()
    
    override func loadView() {
        view = _view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _view.fakeNavBarTitleLabel.text = "Indstillinger"
        
//        _view.homeTextField.text = Settings.sharedSettings.homeLocation?.name
//        _view.workTextField.text = Settings.sharedSettings.workLocation?.name
        
        _view.fakeNavBarCloseButton.rx_action = doneAction
        
        _view.homeTextField.rx_text.throttle(0.2, scheduler: MainScheduler.instance).bindTo(viewModel.query).addDisposableTo(bag)
        _view.workTextField.rx_text.throttle(0.2, scheduler: MainScheduler.instance).bindTo(viewModel.query).addDisposableTo(bag)
        
        
        Settings.sharedSettings.homeLocationVariable.asObservable().map { (location) -> String in
            return location?.name ?? ""
        }.bindTo(_view.homeTextField.rx_text).addDisposableTo(bag)
        
        Settings.sharedSettings.workLocationVariable.asObservable().map { (location) -> String in
            return location?.name ?? ""
        }.bindTo(_view.workTextField.rx_text).addDisposableTo(bag)
        
        
        _view.searchResultsTableView.registerCell(LocationCell.self)
        _view.searchResultsTableView.dataSource = self
        _view.searchResultsTableView.delegate = self
        
        viewModel.locations.asObservable().subscribeNext { [weak self] (locations) -> Void in

            if locations.count > 0 {
                self?._view.searchResultsTableView.reloadData()
                self?._view.showResults(nil)
            } else {
                self?._view.hideResults({ (_) -> Void in
                    self?._view.searchResultsTableView.reloadData()
                })
            }
            
        }.addDisposableTo(bag)
        
        NSNotificationCenter.defaultCenter().rx_notification(UIKeyboardWillChangeFrameNotification).subscribeNext { [weak self] (notification) -> Void in
            guard
                let s = self,
                let info = notification.userInfo,
                let value = info[UIKeyboardFrameEndUserInfoKey] else { return }
            
            let rawFrame = value.CGRectValue
            
            s._view.bottomInset = UIScreen.mainScreen().bounds.height - rawFrame.origin.y
            s._view.setNeedsUpdateConstraints()
            
            UIView.animateWithDuration(info[UIKeyboardAnimationDurationUserInfoKey] as! Double, delay: 0, options: UIViewAnimationOptions(rawValue: info[UIKeyboardAnimationCurveUserInfoKey] as! UInt), animations: {
                s._view.layoutIfNeeded()
            }, completion: { finished in
            })
            
        }.addDisposableTo(bag)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: "Settings")
        
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker.send(builder.build() as [NSObject : AnyObject])
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if Settings.sharedSettings.homeLocation == nil {
            _view.homeTextField.becomeFirstResponder()
        } else if Settings.sharedSettings.workLocation == nil {
            _view.workTextField.becomeFirstResponder()
        }
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    deinit {
        print("Deinit \(self.dynamicType)")
    }
    
}

extension SettingsViewController : UITableViewDataSource, UITableViewDelegate {
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
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if _view.homeTextField.isFirstResponder() {
            Settings.sharedSettings.homeLocation = viewModel.locations.value[indexPath.row]
            _view.homeTextField.resignFirstResponder()
            
            if Settings.sharedSettings.workLocation == nil {
                _view.workTextField.becomeFirstResponder()
            }
            
        } else if _view.workTextField.isFirstResponder() {
            Settings.sharedSettings.workLocation = viewModel.locations.value[indexPath.row]
            _view.workTextField.resignFirstResponder()
        }
        
        tableView.reloadData()
    }
}