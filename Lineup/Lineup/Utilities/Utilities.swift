//
//  Utilities.swift
//  Lineup
//
//  Created by Derek Nopp on 4/15/23.
//

import Foundation
import UIKit
final class Utilities {
    static let shared = Utilities()
    
    private init() {
        
    }
    
    /*
     Imported UIKit here to access UIViewController. Needed for sign in with google... (to my knowledge) there is not an updated way of doing this with just SWIFTUI
     */
    
    @MainActor
    func topViewController(controller: UIViewController? = nil) -> UIViewController? {
        
        let controller = controller ?? UIApplication.shared.keyWindow?.rootViewController
        
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }
}
