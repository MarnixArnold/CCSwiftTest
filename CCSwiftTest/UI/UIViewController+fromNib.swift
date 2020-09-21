//
//  UIViewController+fromNib.swift
//  CCSwiftTest
//
//  Created by Marnix Arnold on 21/09/2020.
//

import UIKit

extension UIViewController {
    class func fromNib<T: UIViewController>() -> T {
         return T(nibName: String(describing: self), bundle: nil)
    }
}
