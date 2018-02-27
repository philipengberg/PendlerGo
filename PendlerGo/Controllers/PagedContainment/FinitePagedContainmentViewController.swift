//
//  FinitePagedContainmentViewController.swift
//  Tonsser
//
//  Created by Philip Engberg on 13/01/16.
//  Copyright © 2016 tonsser. All rights reserved.
//

import Foundation
import UIKit

protocol ScrollableViewController {
    func scrollToTop()
    func isScrolledToTop() -> Bool
}

protocol FinitePagedContainmentViewControllerProtocol {
    
    func switchToPagedViewController(_ controller: UIViewController)
    func getCurrentPagedViewController() -> UIViewController
    
}

class FinitePagedContainmentViewController: UIViewController, UIScrollViewDelegate {
    
    var pagedScrollView = UIScrollView().setUp {
        $0.isPagingEnabled = true
        $0.showsHorizontalScrollIndicator = false
        $0.showsVerticalScrollIndicator = false
        $0.scrollsToTop = false
    }
    
    var pagedViewControllers: [UIViewController] = []
    
    var currentPageIndex: Int {
        let contentOffsetX = pagedScrollView.contentOffset.x + UIScreen.main.bounds.width / 2
        return Int(floor(contentOffsetX / UIScreen.main.bounds.width))
    }
    
    var pagedScrollViewTopOffset: Float {
        return 0
    }
    var pagedScrollViewBottomOffset: Float {
        return 0
    }
    
    var currentPagedViewController: UIViewController? {
        get {
            if currentPageIndex < pagedViewControllers.count {
                return pagedViewControllers[currentPageIndex]
            }
            return nil
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(pagedScrollView)
        
        for (index, viewController) in pagedViewControllers.enumerated() {
            addChildViewController(viewController)
            
            pagedScrollView.addSubview(viewController.view)
            viewController.view.snp.updateConstraints { make in
                make.top.equalTo(pagedScrollView)
                make.left.equalTo(pagedScrollView).offset(index * Int(UIScreen.main.bounds.width))
                make.width.equalTo(UIScreen.main.bounds.width)
                make.height.equalTo(pagedScrollView)
                
                if index == pagedViewControllers.count - 1 {
                    make.right.equalTo(pagedScrollView)
                }
            }
            
            viewController.didMove(toParentViewController: self)
        }
        
        pagedScrollView.delegate = self
    }
    
    override func updateViewConstraints() {
        
        pagedScrollView.snp.updateConstraints { make in
            make.left.equalToSuperview();
            make.right.equalToSuperview();
            make.top.equalToSuperview().offset(pagedScrollViewTopOffset)
            make.bottom.equalToSuperview().offset(-pagedScrollViewBottomOffset)
        }
        
        super.updateViewConstraints()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Update green marker on deep link
        scrollViewDidScroll(pagedScrollView)
    }
    
    
    func switchToPagedViewController<T : UIViewController>(_ viewController: T) where T : ScrollableViewController {
        if let index = pagedViewControllers.index(of: viewController) {
            if index == currentPageIndex {
                if let scrollableViewController = pagedViewControllers[index] as? ScrollableViewController {
                    scrollableViewController.scrollToTop()
                }
            }
            self.viewWillAppear(true)
            pagedScrollView.setContentOffset(CGPoint(x: index * Int(UIScreen.main.bounds.width), y: 0), animated: true)
        }
    }
    
    func getCurrentPagedViewController() -> UIViewController? {
        if currentPageIndex < pagedViewControllers.count {
            return pagedViewControllers[currentPageIndex]
        }
        return nil
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        self.viewDidAppear(true)
        
        // Update green marker on deep link
        scrollViewDidScroll(scrollView)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollViewDidEndScroll(scrollView)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            scrollViewDidEndScroll(scrollView)
        }
    }
    
    func scrollViewDidEndScroll(_ scrollView: UIScrollView) {
        self.viewDidAppear(true)
    }
    
    
}
