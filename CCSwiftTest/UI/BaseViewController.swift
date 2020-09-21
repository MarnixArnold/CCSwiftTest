//
//  BaseViewController.swift
//  CCSwiftTest
//
//  Created by Marnix Arnold on 21/09/2020.
//

import UIKit

class BaseViewController: UIViewController {

    private lazy var barCancelButton = UIBarButtonItem(image: UIImage(named: "icon-cancel"), style: .plain, target: self, action: #selector(didTapCancelButton))

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = barCancelButton
    }

    @objc
    func didTapCancelButton(_ sender: Any) {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
}
