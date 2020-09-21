//
//  SnapShotViewController.swift
//  CCSwiftTest
//
//  Created by Marnix Arnold on 21/09/2020.
//

import UIKit

class SnapShotViewController: BaseViewController {

    @IBOutlet weak var imageView: UIImageView!
    
    var snapShot: SnapShot? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let x = snapShot?.cameraTransform.translation.x,
           let y = snapShot?.cameraTransform.translation.z {
            navigationItem.title = String(format: "(%1.5f, %1.5f)", x, y)
        }
        imageView.image = snapShot?.image
    }
}
