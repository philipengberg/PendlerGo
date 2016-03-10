//
//  BoardContainmentController.swift
//  PendlerGo
//
//  Created by Philip Engberg on 19/02/16.
//
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import GoogleMobileAds
import Google

class BoardContainmentViewController : FinitePagedContainmentViewController {
    
    private let _view = BoardContainmentView()
//    private let viewModel: LeagueContainmentViewModel
    private let bag = DisposeBag()
    
    lazy var homeBoardViewController: BoardViewController = {
        return BoardViewController(locationType: .Home)
    }()
    
    lazy var workBoardViewController: BoardViewController = {
        return BoardViewController(locationType: .Work)
    }()
    
    override var pagedScrollViewTopOffset: Float {
        return Float(50)
    }
    
    override var pagedScrollViewBottomOffset: Float {
        return Float(self._view.showAdBanner ? 50 : 0)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        pagedViewControllers = [homeBoardViewController, workBoardViewController]
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "PendlerGo"
        
        setHairLineImageViewHidden(true)
        
        self.edgesForExtendedLayout = .None
        self.extendedLayoutIncludesOpaqueBars = false
        self.automaticallyAdjustsScrollViewInsets = false
        
        
        Settings.sharedSettings.homeLocationVariable.asObservable().map({ (location) -> String in
            return location?.name ?? ""
        }).bindTo(_view.tabView.homeButton.subtitleLabel.rx_text).addDisposableTo(bag)
        
        Settings.sharedSettings.workLocationVariable.asObservable().map({ (location) -> String in
            return location?.name ?? ""
        }).bindTo(_view.tabView.workButton.subtitleLabel.rx_text).addDisposableTo(bag)
        
        
        let settings = UIBarButtonItem(image: UIImage(named: "settings"), style: .Plain, target: nil, action: nil)
        self.navigationItem.leftBarButtonItem = settings
        settings.rx_tap.subscribeNext { [weak self] (_) -> Void in
            self?.presentSettings()
        }.addDisposableTo(bag)
        
        
        _view.insertSubview(pagedScrollView, belowSubview: _view.tabView)
        
        _view.tabView.homeButton.rx_tap.subscribeNext   { [weak self] () -> Void in
            self?.setTabIndex(0)
        }.addDisposableTo(bag)
        
        _view.tabView.workButton.rx_tap.subscribeNext   { [weak self] () -> Void in
            self?.setTabIndex(1)
        }.addDisposableTo(bag)
        
        
        let adRequest = GADRequest()
        #if DEBUG
        adRequest.testDevices = ["kGADSimulatorID", "4c67d9c602e1157d68e93c106413b5f8"]
        #endif
        _view.adBannerView.rootViewController = self
        _view.adBannerView.delegate = self
        _view.adBannerView.loadRequest(GADRequest())
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: "Board")
        
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker.send(builder.build() as [NSObject : AnyObject])
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if Settings.sharedSettings.homeLocation == nil && Settings.sharedSettings.workLocation == nil {
            self.presentSettings()
        }
    }
    
    override func loadView() {
        view = _view
    }
    
    func presentSettings() {
        let modal = SettingsViewController()
        
        modal.doneAction.elements.subscribeNext { [weak self] (_) -> Void in
            self?.dismissViewControllerAnimated(true, completion: nil)
        }.addDisposableTo(bag)
        
        modal.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
        self.presentViewController(modal, animated: true, completion: {})
    }
    
    func setTabIndex(index: Int) {
        
        switch index {
        case 0: switchToPagedViewController(homeBoardViewController)
        case 1: switchToPagedViewController(workBoardViewController)
        default: break
        }
        
    }
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        super.scrollViewDidScroll(scrollView)
        
        let totalWidth = scrollView.contentSize.width;
        let contentOffsetX = scrollView.contentOffset.x;
        
        let movePercentage = contentOffsetX / (totalWidth - scrollView.frame.size.width);
        _view.tabView.setActiveMarkerScrollPercentage(Double(movePercentage))
        
        //        let currentIndex = currentPageIndex
        //        [self.mainView.toggleView setActiveToggle:(unsigned int) currentIndex];
        
        // Handle scrolls to top enabling
        //        for (int i = 0; i < self.pagedViewControllers.count; i++) {
        //            FIBPhotosWaterfallViewController *controller = (FIBPhotosWaterfallViewController *)self.pagedViewControllers[i];
        //            controller.collectionView.scrollsToTop = i == currentIndex;
        //        }
    }
    
    func findHairlineImageViewUnder(view: UIView) -> UIImageView? {
        if view is UIImageView && view.bounds.size.height <= 1.0 {
            return view as? UIImageView;
        }
        
        for subview in view.subviews {
            if let imageView = findHairlineImageViewUnder(subview) {
                return imageView;
            }
        }
        return nil;
    }
    
    func setHairLineImageViewHidden(hidden: Bool) {
        findHairlineImageViewUnder(self.navigationController!.navigationBar)!.hidden = hidden;
    }
}

extension BoardContainmentViewController : GADBannerViewDelegate {
    func adViewDidReceiveAd(bannerView: GADBannerView!) {
        _view.showAdBanner = true
        _view.setNeedsUpdateConstraints()
        
        UIView.animateWithDuration(0.5, delay: 1, usingSpringWithDamping: 0.9, initialSpringVelocity: 20, options: UIViewAnimationOptions.BeginFromCurrentState, animations: { () -> Void in
            self._view.layoutIfNeeded()
        }, completion: nil)
    }
    
    func adView(bannerView: GADBannerView!, didFailToReceiveAdWithError error: GADRequestError!) {
        _view.showAdBanner = false
        _view.setNeedsUpdateConstraints()
        
        UIView.animateWithDuration(0.5, delay: 1, usingSpringWithDamping: 0.9, initialSpringVelocity: 20, options: UIViewAnimationOptions.BeginFromCurrentState, animations: { () -> Void in
            self._view.layoutIfNeeded()
        }, completion: nil)
    }
}