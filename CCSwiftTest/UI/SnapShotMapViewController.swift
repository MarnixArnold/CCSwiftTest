//
//  SnapShotMapViewController.swift
//  CCSwiftTest
//
//  Created by Marnix Arnold on 21/09/2020.
//

import UIKit

class SnapShotMapViewController: BaseViewController {
    
    @IBOutlet weak var mapView: UIView!
    
    private var snapShotService = ClassWiring.SnapShotService
    
    private var snapShots: [SnapShot] = []
    private var shouldLoadSnapshots = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Snapshots"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if shouldLoadSnapshots {
            shouldLoadSnapshots = false
            loadSnapShots()
        }
    }
    
    private func loadSnapShots() {
        snapShotService.getSnapShots { [weak self] (result) in
            switch result {
            case .success(let snapshots):
                self?.snapShots = snapshots
                self?.view.setNeedsLayout()
            case .failure(let error):
                print("Error loading snapshots: \(error.localizedDescription)")
                self?.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        clearSnapShots()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        drawSnapShots()
    }
    
    private func clearSnapShots() {
        mapView.subviews.forEach { (subview) in
            subview.removeFromSuperview()
        }
    }
    
    private func drawSnapShots() {
        guard snapShots.count != 0 else {
            return
        }
        
        let viewWidth = mapView.frame.size.width
        let viewHeight = mapView.frame.size.height
        
        guard snapShots.count > 1 else {
            // if there is only one point, we draw it in the middle
            placeDotView(x: viewWidth / 2, y: viewHeight / 2, tag: 0)
            return
        }
        
        // Let's make the points cloud fill the map view, so we need to compute the scale
        let minXSnapShot = snapShots.min { $0.cameraTransform.translation.x < $1.cameraTransform.translation.x }
        let maxXSnapShot = snapShots.max { $0.cameraTransform.translation.x < $1.cameraTransform.translation.x }
        let minYSnapShot = snapShots.min { $0.cameraTransform.translation.z < $1.cameraTransform.translation.z }
        let maxYSnapShot = snapShots.max { $0.cameraTransform.translation.z < $1.cameraTransform.translation.z }
        guard let minX = minXSnapShot?.cameraTransform.translation.x,
              let maxX = maxXSnapShot?.cameraTransform.translation.x,
              let minY = minYSnapShot?.cameraTransform.translation.z,
              let maxY = maxYSnapShot?.cameraTransform.translation.z else {
            return
        }
        
        let diffX = maxX - minX
        let diffY = maxY - minY
        var tag = 0
        snapShots.forEach { (snapShot) in
            // Shift, normalize and scale
            let normX = (snapShot.cameraTransform.translation.x - minX) / diffX
            let normY = (snapShot.cameraTransform.translation.z - minY) / diffY
            let x: CGFloat = CGFloat(normX) * viewWidth
            let y: CGFloat = CGFloat(normY) * viewHeight
            placeDotView(x: x, y: y, tag: tag)
            tag += 1
        }
    }
    
    private func placeDotView(x: CGFloat, y: CGFloat, tag: Int) {
        print("Placing dot at (\(x),\(y))")
        let pointsize: CGFloat = 32
        let dotView = UIView(frame: CGRect(x: x-pointsize/2,
                                           y: y-pointsize/2,
                                           width: pointsize,
                                           height: pointsize))
        dotView.backgroundColor = UIColor.black
        dotView.layer.cornerRadius = pointsize/2
        dotView.tag = tag
        dotView.isUserInteractionEnabled = true
        dotView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapDotView(_:))))
        mapView.addSubview(dotView)
    }
    
    @objc
    func didTapDotView(_ sender: UITapGestureRecognizer) {
        guard let tag = sender.view?.tag, tag < snapShots.count else {
            return
        }
        print("Dot view \(tag) tapped")
        let snapShotViewController: SnapShotViewController = SnapShotViewController.fromNib()
        snapShotViewController.snapShot = snapShots[tag]
        navigationController?.pushViewController(snapShotViewController, animated: true)
    }
}
