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
    
    func switchToPagedViewController(controller: UIViewController)
    func getCurrentPagedViewController() -> UIViewController
    
}

class FinitePagedContainmentViewController: UIViewController, UIScrollViewDelegate {
    
    var pagedScrollView = UIScrollView().setUp {
        $0.pagingEnabled = true
        $0.showsHorizontalScrollIndicator = false
        $0.showsVerticalScrollIndicator = false
        $0.scrollsToTop = false
    }
    
    var pagedViewControllers: [UIViewController] = []
    
    var currentPageIndex: Int {
        let contentOffsetX = pagedScrollView.contentOffset.x + UIScreen.mainScreen().bounds.width / 2
        return Int(floor(contentOffsetX / UIScreen.mainScreen().bounds.width))
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
        
        pagedScrollView.snp_updateConstraintsWithSuper { (make, superview) -> Void in
            make.left.equalTo(superview);
            make.right.equalTo(superview);
            make.top.equalTo(superview).offset(pagedScrollViewTopOffset)
            make.bottom.equalTo(superview).offset(-pagedScrollViewBottomOffset)
        }
        
        for (index, viewController) in pagedViewControllers.enumerate() {
            addChildViewController(viewController)
            
            pagedScrollView.addSubview(viewController.view)
            viewController.view.snp_updateConstraintsWithSuper({ (make, superview) -> Void in
                make.top.equalTo(pagedScrollView)
                make.left.equalTo(pagedScrollView).offset(index * Int(UIScreen.mainScreen().bounds.width))
                make.width.equalTo(UIScreen.mainScreen().bounds.width)
                make.height.equalTo(pagedScrollView)
                
                if index == pagedViewControllers.count - 1 {
                    make.right.equalTo(pagedScrollView)
                }
            })
            
            viewController.didMoveToParentViewController(self)
        }
        
        pagedScrollView.delegate = self
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // Update green marker on deep link
        scrollViewDidScroll(pagedScrollView)
    }
    
    
    func switchToPagedViewController<T : UIViewController where T : ScrollableViewController>(viewController: T) {
        if let index = pagedViewControllers.indexOf(viewController) {
            if index == currentPageIndex {
                if let scrollableViewController = pagedViewControllers[index] as? ScrollableViewController {
                    scrollableViewController.scrollToTop()
                }
            }
            self.viewWillAppear(true)
            pagedScrollView.setContentOffset(CGPoint(x: index * Int(UIScreen.mainScreen().bounds.width), y: 0), animated: true)
        }
    }
    
    func getCurrentPagedViewController() -> UIViewController? {
        if currentPageIndex < pagedViewControllers.count {
            return pagedViewControllers[currentPageIndex]
        }
        return nil
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
    }
    
    func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
        self.viewDidAppear(true)
        
        // Update green marker on deep link
        scrollViewDidScroll(scrollView)
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        scrollViewDidEndScroll(scrollView)
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            scrollViewDidEndScroll(scrollView)
        }
    }
    
    func scrollViewDidEndScroll(scrollView: UIScrollView) {
        self.viewDidAppear(true)
    }
    
    
}