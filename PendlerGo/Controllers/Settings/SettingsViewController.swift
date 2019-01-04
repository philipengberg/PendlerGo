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
import RxSwiftExt
import Action
import MessageUI
import GBDeviceInfo

class SettingsViewController: UIViewController {
    
    let _view = SettingsView()
    let viewModel = SettingsViewModel()
    let bag = DisposeBag()
    
    lazy var doneAction: CocoaAction = {
        return CocoaAction(workFactory: { [weak self] (_) -> Observable<Void> in
            self?._view.homeTextField.resignFirstResponder()
            self?._view.workTextField.resignFirstResponder()
            return Observable.just(())
        })
    }()
    
    override func loadView() {
        view = _view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _view.fakeNavBarTitleLabel.text = "Indstillinger"
        
        _view.fakeNavBarCloseButton.rx.action = doneAction
        
        _view.fakeNavBarFeedbackButton.isHidden = !MFMailComposeViewController.canSendMail()
        _view.fakeNavBarFeedbackButton.rx.tap.subscribe(onNext: { [weak self] () -> Void in
            Analytics.Events.trackHelpButtonTapped()
            guard let s = self else { return }
            
            let mailComposerVC = MFMailComposeViewController()
            mailComposerVC.navigationBar.tintColor = .white
            mailComposerVC.mailComposeDelegate = s
            mailComposerVC.setToRecipients(["admin@philipengberg.dk"])
            mailComposerVC.setSubject("PendlerGo feedback")
            mailComposerVC.setMessageBody("Hej PendlerGo,</br></br>Jeg har følgende problemer eller foreslag til PendlerGo: <ul><li></ul>" +
                "<br/>Detaljer:<ul>" +
                "<li>\(GBDeviceInfo.deviceInfo().modelString!)</li>" +
                "<li>iOS \(GBDeviceInfo.deviceInfo().osVersion.major).\(GBDeviceInfo.deviceInfo().osVersion.minor).\(GBDeviceInfo.deviceInfo().osVersion.patch)</li>" +
                "<li>PendlerGo \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String) (\(Bundle.main.infoDictionary?[kCFBundleVersionKey as String] as! String))</li>" +
                "</ul>" +
                "", isHTML: true)
            
            s.present(mailComposerVC, animated: true, completion: nil)
            
        }).disposed(by: bag)
        
        _view.homeTextField.rx.text.debounce(0.2, scheduler: MainScheduler.instance).bind(to: viewModel.query).disposed(by: bag)
        _view.workTextField.rx.text.debounce(0.2, scheduler: MainScheduler.instance).bind(to: viewModel.query).disposed(by: bag)
        
        
        Settings.homeLocationVariable.asObservable().map { (location) -> String in
            return location?.name ?? ""
        }.bind(to: _view.homeTextField.rx.text).disposed(by: bag)
        
        Settings.workLocationVariable.asObservable().map { (location) -> String in
            return location?.name ?? ""
        }.bind(to: _view.workTextField.rx.text).disposed(by: bag)
        
        
        _view.searchResultsTableView.registerCell(LocationCell.self)
        _view.searchResultsTableView.dataSource = self
        _view.searchResultsTableView.delegate = self
        
        viewModel.locations.asObservable().subscribe(onNext: { [weak self] (locations) -> Void in

            if locations.count > 0 {
                self?._view.searchResultsTableView.reloadData()
                self?._view.showResults(nil)
            } else {
                self?._view.hideResults({ (_) -> Void in
                    self?._view.searchResultsTableView.reloadData()
                })
            }
            
        }).disposed(by: bag)
        
        NotificationCenter.default.rx.notification(NSNotification.Name.UIKeyboardWillChangeFrame).subscribe(onNext: { [weak self] (notification) -> Void in
            guard
                let s = self,
                let info = notification.userInfo,
                let value = info[UIKeyboardFrameEndUserInfoKey] as? NSValue else { return }
            
            let rawFrame = value.cgRectValue
            
            s._view.bottomInset = UIScreen.main.bounds.height - rawFrame.origin.y
            s._view.setNeedsUpdateConstraints()
            
            UIView.animate(withDuration: info[UIKeyboardAnimationDurationUserInfoKey] as! Double, delay: 0, options: UIViewAnimationOptions(rawValue: info[UIKeyboardAnimationCurveUserInfoKey] as! UInt), animations: {
                s._view.layoutIfNeeded()
            }, completion: { finished in
            })
            
        }).disposed(by: bag)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if Settings.homeLocation == nil {
            _view.homeTextField.becomeFirstResponder()
        } else if Settings.workLocation == nil {
            _view.workTextField.becomeFirstResponder()
        }
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    deinit {
        print("Deinit \(type(of: self))")
    }
    
}

extension SettingsViewController : UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.locations.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(LocationCell.self, indexPath: indexPath)
        cell.configure(viewModel.locations.value[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if _view.homeTextField.isFirstResponder {
            Settings.homeLocation = viewModel.locations.value[indexPath.row]
            _view.homeTextField.resignFirstResponder()
            
            if Settings.workLocation == nil {
                _view.workTextField.becomeFirstResponder()
            }
            
        } else if _view.workTextField.isFirstResponder {
            Settings.workLocation = viewModel.locations.value[indexPath.row]
            _view.workTextField.resignFirstResponder()
        }
        
        tableView.reloadData()
    }
}

extension MFMailComposeViewController {
    open override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    open override var childViewControllerForStatusBarStyle : UIViewController? {
        return nil
    }
}

extension SettingsViewController : MFMailComposeViewControllerDelegate {
 
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        switch result.rawValue {
        case MFMailComposeResult.cancelled.rawValue:
            print("Mail cancelled")
        case MFMailComposeResult.saved.rawValue:
            print("Mail saved")
        case MFMailComposeResult.sent.rawValue:
            print("Mail sent")
        case MFMailComposeResult.failed.rawValue:
            print("Mail sent failure: \(error!.localizedDescription)")
        default:
            break
        }
        controller.dismiss(animated: true, completion: nil)
    }
    
}
