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
import CoreLocation

class BoardContainmentViewController : FinitePagedContainmentViewController {
    
    private let _view = BoardContainmentView()
    private let bag = DisposeBag()
    
    private let locationManager = CLLocationManager()
    
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
        
        findNearestStation()
        
        self.title = "PendlerGo"
        
        setHairLineImageViewHidden(true)
        
        self.edgesForExtendedLayout = .None
        self.extendedLayoutIncludesOpaqueBars = false
        self.automaticallyAdjustsScrollViewInsets = false
        
        Settings.homeLocationVariable.asObservable().map({ (location) -> String in
            return location?.name ?? ""
        }).bindTo(_view.tabView.homeButton.subtitleLabel.rx_text).addDisposableTo(bag)
        
        Settings.workLocationVariable.asObservable().map({ (location) -> String in
            return location?.name ?? ""
        }).bindTo(_view.tabView.workButton.subtitleLabel.rx_text).addDisposableTo(bag)
        
        
        
        let settings = UIBarButtonItem(image: UIImage(named: "settings"), style: .Plain, target: nil, action: nil)
        self.navigationItem.leftBarButtonItem = settings
        settings.rx_tap.subscribeNext { [weak self] (_) -> Void in
            self?.presentSettings()
        }.addDisposableTo(bag)
        
        
        
        
        let filters = UIBarButtonItem(image: UIImage(named: "filter"), style: .Plain, target: nil, action: nil)
        self.navigationItem.rightBarButtonItem = filters
        
        _view.filterView.tapGesture.rx_event.subscribeNext { [weak self] (_) -> Void in
            self?.toggleFilterView()
        }.addDisposableTo(bag)
        
        filters.rx_tap.subscribeNext { [weak self] (_) -> Void in
            self?.toggleFilterView()
        }.addDisposableTo(bag)
        
        
        _view.filterView.trainsButton.rx_tap.subscribeNext   { _ -> Void in
            Settings.includeTrains = !Settings.includeTrains
        }.addDisposableTo(bag)
        
        _view.filterView.sTrainsButton.rx_tap.subscribeNext   { _ -> Void in
            Settings.includeSTrains = !Settings.includeSTrains
        }.addDisposableTo(bag)
        
        _view.filterView.metroButton.rx_tap.subscribeNext   { _ -> Void in
            Settings.includeMetro = !Settings.includeMetro
        }.addDisposableTo(bag)
        
        
        Settings.includeTrainsVariable.asObservable().subscribeNext { [weak self] (include) in
            self?._view.filterView.trainsButton.selected = include
        }.addDisposableTo(bag)
        
        Settings.includeSTrainsVariable.asObservable().subscribeNext { [weak self] (include) in
            self?._view.filterView.sTrainsButton.selected = include
        }.addDisposableTo(bag)
        
        Settings.includeMetroVariable.asObservable().subscribeNext { [weak self] (include) in
            self?._view.filterView.metroButton.selected = include
        }.addDisposableTo(bag)
        
        
        
        
        _view.insertSubview(pagedScrollView, belowSubview: _view.filterView)
        
        
        
        
        _view.tabView.homeButton.rx_tap.subscribeNext   { [weak self] () -> Void in
            self?.setTabIndex(0)
        }.addDisposableTo(bag)
        
        _view.tabView.workButton.rx_tap.subscribeNext   { [weak self] () -> Void in
            self?.setTabIndex(1)
        }.addDisposableTo(bag)
        
        
        
        
        _view.adBannerView.rootViewController = self
        _view.adBannerView.delegate = self
        _view.adBannerView.loadRequest(genreateAdRequest())
        
        
        NSNotificationCenter.defaultCenter().rx_notification(UIApplicationDidBecomeActiveNotification).subscribeNext { [weak self] (_) in
            guard let s = self else { return }
            s.findNearestStation()
        }.addDisposableTo(bag)
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    override func childViewControllerForStatusBarStyle() -> UIViewController? {
        return nil
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
        
        if Settings.homeLocation == nil && Settings.workLocation == nil {
            self.presentSettings()
        }
    }
    
    override func loadView() {
        view = _view
    }
    
    func toggleFilterView() {
        _view.showFilter = !_view.showFilter
        _view.setNeedsUpdateConstraints()
        
        UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 20, options: UIViewAnimationOptions.BeginFromCurrentState, animations: { () -> Void in
            self._view.layoutIfNeeded()
            self._view.tabView.layer.shadowColor = self._view.showFilter ? UIColor.blackColor().CGColor : nil
            self._view.tabView.layer.shadowOffset = CGSize(width: 0, height: self._view.showFilter ? 1 : 0)
            self._view.tabView.layer.shadowOpacity = self._view.showFilter ? 0.1 : 0
            self._view.tabView.layer.shadowRadius = 3.0
        }, completion: nil)
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
        
        let currentIndex = currentPageIndex
        // Handle scrolls to top enabling
        for (index, controller) in self.pagedViewControllers.enumerate() {
            guard let con = controller as? BoardViewController else { continue }
            con._view.tableView.scrollsToTop = index == currentIndex
        }
    }
    
    func genreateAdRequest() -> GADRequest {
        let adRequest = GADRequest()
        #if DEBUG
            adRequest.testDevices = [kGADSimulatorID, "4c67d9c602e1157d68e93c106413b5f8"]
        #endif
        return adRequest
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

extension BoardContainmentViewController : CLLocationManagerDelegate {
    
    func findNearestStation() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        manager.stopUpdatingLocation()
        
        // Make ads more relevant
        let adRequest = genreateAdRequest()
        adRequest.setLocationWithLatitude(CGFloat(location.coordinate.latitude), longitude: CGFloat(location.coordinate.longitude), accuracy: CGFloat(location.horizontalAccuracy))
        _view.adBannerView.loadRequest(adRequest)
        
        guard
            let home = Settings.homeLocation,
            let work = Settings.workLocation else { return }
        
        let homeCoordinate = CLLocationCoordinate2D(latitude: Double(home.yCoordinate)! / 1000000, longitude: Double(home.xCoordinate)! / 1000000)
        let workCoordinate = CLLocationCoordinate2D(latitude: Double(work.yCoordinate)! / 1000000, longitude: Double(work.xCoordinate)! / 1000000)
        
        let homeDistance = CLLocation(coordinate: homeCoordinate, altitude: 1, horizontalAccuracy: 1, verticalAccuracy: -1, timestamp: NSDate()).distanceFromLocation(location)
        let workDistance = CLLocation(coordinate: workCoordinate, altitude: 1, horizontalAccuracy: 1, verticalAccuracy: -1, timestamp: NSDate()).distanceFromLocation(location)
        
        let diffPercentage = (max(homeDistance, workDistance) - min(homeDistance, workDistance)) / max(homeDistance, workDistance)
        
        guard diffPercentage > 0.1 else { return }
        
        if homeDistance < workDistance {
            setTabIndex(0)
        } else {
            setTabIndex(1)
        }
    }
    
}

extension UINavigationController {
    public override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
}