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
    
    fileprivate let _view = BoardContainmentView()
    fileprivate let bag = DisposeBag()
    
    fileprivate let locationManager = CLLocationManager()
    
    lazy var homeBoardViewController: BoardViewController = {
        return BoardViewController(locationType: .home)
    }()
    
    lazy var workBoardViewController: BoardViewController = {
        return BoardViewController(locationType: .work)
    }()
    
    override var pagedScrollViewTopOffset: Float {
        return Float(50)
    }
    
    override var pagedScrollViewBottomOffset: Float {
        return Float(self._view.showAdBanner ? 50 : 0)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
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
        
        self.edgesForExtendedLayout = UIRectEdge()
        self.extendedLayoutIncludesOpaqueBars = false
        self.automaticallyAdjustsScrollViewInsets = false
        
        Settings.homeLocationVariable.asObservable().map({ (location) -> String in
            return location?.name ?? ""
        }).bind(to: _view.tabView.homeButton.subtitleLabel.rx.text).addDisposableTo(bag)
        
        Settings.workLocationVariable.asObservable().map({ (location) -> String in
            return location?.name ?? ""
        }).bind(to: _view.tabView.workButton.subtitleLabel.rx.text).addDisposableTo(bag)
        
        
        
        let settings = UIBarButtonItem(image: UIImage(named: "settings"), style: .plain, target: nil, action: nil)
        self.navigationItem.leftBarButtonItem = settings
        settings.rx.tap.subscribe(onNext: { [weak self] (_) -> Void in
            self?.presentSettings()
            Analytics.Events.trackSettingsButtonTapped()
        }).addDisposableTo(bag)
        
        
        
        
        let filters = UIBarButtonItem(image: UIImage(named: "filter"), style: .plain, target: nil, action: nil)
        self.navigationItem.rightBarButtonItem = filters
        
        _view.filterView.tapGesture.rx.event.subscribe(onNext: { [weak self] (_) -> Void in
            self?.toggleFilterView()
        }).addDisposableTo(bag)
        
        filters.rx.tap.subscribe(onNext: { [weak self] (_) -> Void in
            self?.toggleFilterView()
            Analytics.Events.trackFilterButtonTapped()
        }).addDisposableTo(bag)
        
        
        _view.filterView.trainsButton.rx.tap.subscribe(onNext: { _ -> Void in
            Settings.includeTrains = !Settings.includeTrains
            Analytics.Events.trackToggledIncludeTrains(to: Settings.includeTrains)
        }).addDisposableTo(bag)
        
        _view.filterView.sTrainsButton.rx.tap.subscribe(onNext: { _ -> Void in
            Settings.includeSTrains = !Settings.includeSTrains
            Analytics.Events.trackToggledIncludeSTrains(to: Settings.includeSTrains)
        }).addDisposableTo(bag)
        
        _view.filterView.metroButton.rx.tap.subscribe(onNext: { _ -> Void in
            Settings.includeMetro = !Settings.includeMetro
            Analytics.Events.trackToggledIncludeMetro(to: Settings.includeMetro)
        }).addDisposableTo(bag)
        
        
        Settings.includeTrainsVariable.asObservable().subscribe(onNext: { [weak self] (include) in
            self?._view.filterView.trainsButton.isSelected = include
        }).addDisposableTo(bag)
        
        Settings.includeSTrainsVariable.asObservable().subscribe(onNext: { [weak self] (include) in
            self?._view.filterView.sTrainsButton.isSelected = include
        }).addDisposableTo(bag)
        
        Settings.includeMetroVariable.asObservable().subscribe(onNext: { [weak self] (include) in
            self?._view.filterView.metroButton.isSelected = include
        }).addDisposableTo(bag)
        
        
        
        
        _view.insertSubview(pagedScrollView, belowSubview: _view.filterView)
        
        
        
        
        _view.tabView.homeButton.rx.tap.subscribe(onNext: { [weak self] () -> Void in
            self?.setTabIndex(0)
            Analytics.Events.trackManuallySwitchedDepartureBoard(to: .home)
        }).addDisposableTo(bag)
        
        _view.tabView.workButton.rx.tap.subscribe(onNext: { [weak self] () -> Void in
            self?.setTabIndex(1)
            Analytics.Events.trackManuallySwitchedDepartureBoard(to: .work)
        }).addDisposableTo(bag)
        
        
        
        
        _view.adBannerView.rootViewController = self
        _view.adBannerView.delegate = self
        _view.adBannerView.load(genreateAdRequest())
        
        
        NotificationCenter.default.rx.notification(NSNotification.Name.UIApplicationDidBecomeActive).subscribe(onNext: { [weak self] (_) in
            guard let s = self else { return }
            s.findNearestStation()
        }).addDisposableTo(bag)
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    override var childViewControllerForStatusBarStyle : UIViewController? {
        return nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let tracker = GAI.sharedInstance().defaultTracker
        tracker?.set(kGAIScreenName, value: "Board")
        tracker?.send(GAIDictionaryBuilder.createScreenView().build() as Dictionary<NSObject, AnyObject>)
    }
    
    override func viewDidAppear(_ animated: Bool) {
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
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 20, options: UIViewAnimationOptions.beginFromCurrentState, animations: { () -> Void in
            self._view.layoutIfNeeded()
            self._view.tabView.layer.shadowColor = self._view.showFilter ? UIColor.black.cgColor : nil
            self._view.tabView.layer.shadowOffset = CGSize(width: 0, height: self._view.showFilter ? 1 : 0)
            self._view.tabView.layer.shadowOpacity = self._view.showFilter ? 0.1 : 0
            self._view.tabView.layer.shadowRadius = 3.0
        }, completion: nil)
    }
    
    func presentSettings() {
        let modal = SettingsViewController()
        
        modal.doneAction.elements.subscribe(onNext: { [weak self] (_) -> Void in
            self?.dismiss(animated: true, completion: nil)
        }).addDisposableTo(bag)
        
        modal.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        self.present(modal, animated: true, completion: {})
    }
    
    func setTabIndex(_ index: Int) {
        
        switch index {
        case 0: switchToPagedViewController(homeBoardViewController)
        case 1: switchToPagedViewController(workBoardViewController)
        default: break
        }
        
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        super.scrollViewDidScroll(scrollView)
        
        let totalWidth = scrollView.contentSize.width;
        let contentOffsetX = scrollView.contentOffset.x;
        
        let movePercentage = contentOffsetX / (totalWidth - scrollView.frame.size.width);
        _view.tabView.setActiveMarkerScrollPercentage(Double(movePercentage))
        
        let currentIndex = currentPageIndex
        // Handle scrolls to top enabling
        for (index, controller) in self.pagedViewControllers.enumerated() {
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
    
    func findHairlineImageViewUnder(_ view: UIView) -> UIImageView? {
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
    
    func setHairLineImageViewHidden(_ hidden: Bool) {
        findHairlineImageViewUnder(self.navigationController!.navigationBar)!.isHidden = hidden;
    }
}

extension BoardContainmentViewController : GADBannerViewDelegate {
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        _view.showAdBanner = true
        _view.setNeedsUpdateConstraints()
        
        UIView.animate(withDuration: 0.5, delay: 1, usingSpringWithDamping: 0.9, initialSpringVelocity: 20, options: UIViewAnimationOptions.beginFromCurrentState, animations: { () -> Void in
            self._view.layoutIfNeeded()
        }, completion: nil)
    }
    
    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        _view.showAdBanner = false
        _view.setNeedsUpdateConstraints()
        
        UIView.animate(withDuration: 0.5, delay: 1, usingSpringWithDamping: 0.9, initialSpringVelocity: 20, options: UIViewAnimationOptions.beginFromCurrentState, animations: { () -> Void in
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
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        manager.stopUpdatingLocation()
        
        // Make ads more relevant
        let adRequest = genreateAdRequest()
        adRequest.setLocationWithLatitude(CGFloat(location.coordinate.latitude), longitude: CGFloat(location.coordinate.longitude), accuracy: CGFloat(location.horizontalAccuracy))
        _view.adBannerView.load(adRequest)
        
        guard
            let home = Settings.homeLocation,
            let work = Settings.workLocation else { return }
        
        let homeCoordinate = CLLocationCoordinate2D(latitude: Double(home.yCoordinate)! / 1000000, longitude: Double(home.xCoordinate)! / 1000000)
        let workCoordinate = CLLocationCoordinate2D(latitude: Double(work.yCoordinate)! / 1000000, longitude: Double(work.xCoordinate)! / 1000000)
        
        let homeDistance = CLLocation(coordinate: homeCoordinate, altitude: 1, horizontalAccuracy: 1, verticalAccuracy: -1, timestamp: Date()).distance(from: location)
        let workDistance = CLLocation(coordinate: workCoordinate, altitude: 1, horizontalAccuracy: 1, verticalAccuracy: -1, timestamp: Date()).distance(from: location)
        
        let diffPercentage = (max(homeDistance, workDistance) - min(homeDistance, workDistance)) / max(homeDistance, workDistance)
        
        guard diffPercentage > 0.1 else { return }
        
        if homeDistance < workDistance {
            setTabIndex(0)
            Analytics.Events.trackAutomaticallySwitchedDepartureBoard(to: .home)
        } else {
            setTabIndex(1)
            Analytics.Events.trackAutomaticallySwitchedDepartureBoard(to: .work)
        }
    }
    
}

extension UINavigationController {
    open override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
}
