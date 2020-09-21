//
//  ViewController.swift
//  CCSwiftTest
//
//  Created by Marnix Arnold on 20/09/2020.
//

import UIKit
import ARKit
import RealityKit
import Combine

class ARViewController: UIViewController {

    @IBOutlet var arView: ARView!
    @IBOutlet weak var sessionInfoView: UIVisualEffectView!
    @IBOutlet weak var sessionInfoLabel: UILabel!
    @IBOutlet weak var galleryButton: UIButton!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var dropButton: UIButton!
    
    private var modelService = ClassWiring.ModelService
    private var snapShotService = ClassWiring.SnapShotService
    
    // The object that we want to add to our scene
    private var objectEntity: Entity? = nil
    private var objectWasDropped = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        arView.session.delegate = self
        
        setupDropButton()
        dropButton.isHidden = true
        cameraButton.isHidden = true
        galleryButton.isHidden = true
        
        loadModel(.wateringCan)
    }
    
    private func setupDropButton() {
        // Some visual tweaks that are easier in code
        dropButton.backgroundColor = UIColor.blue
        dropButton.tintColor = UIColor.white
        dropButton.layer.cornerRadius = dropButton.frame.size.width / 2
    }
    
    private func loadModel(_ model: Object3D) {
        modelService.loadModel(model) { [weak self] (result) in
            switch result {
            case .success(let model):
                self?.objectEntity = model
                print("Model loaded successfully")
                self?.dropButton.isHidden = false
            case .failure(let error):
                print("Error loading model: \(error.localizedDescription)")
            }
        }
    }
    
    private func dropModelInScene() {
        guard let model = objectEntity else {
            return
        }

        // Load the "Box" scene from the "Experience" Reality File
        let boxAnchor = try! Experience.loadBox()
        
        // Add the box anchor to the scene
        arView.scene.anchors.append(boxAnchor)

        // Add the model to the box anchor
        boxAnchor.addChild(model)
        
        objectWasDropped = true
        self.dropButton.isHidden = true
    }
    
    @IBAction func didTapDropButton(_ sender: Any) {
        if !objectWasDropped {
            dropModelInScene()
        }
    }
    
    @IBAction func didTapSnapShotButton(_ sender: Any) {
        let cameraTransform = arView.cameraTransform
        print("Camera transform: \(cameraTransform)")
        arView.snapshot(saveToHDR: true) { (arViewImage) in
            guard let image = arViewImage else {
                return
            }
            let snapShot = SnapShot(image: image, cameraTransform: cameraTransform)
            self.snapShotService.addSnapShot(snapShot) { (result) in
                switch result {
                case .success:
                    print("Snapshot saved")
                    self.galleryButton.isHidden = false
                case .failure(let error):
                    print("Snapshot not saved: \(error.localizedDescription)")
                }                
            }
        }
    }
    
    @IBAction func didTapGalleryButton(_ sender: Any) {
        let snapShotMapViewController: SnapShotMapViewController = SnapShotMapViewController.fromNib()
        let navController = UINavigationController(rootViewController: snapShotMapViewController)
        present(navController, animated: true, completion: nil)
    }
}

extension ARViewController: ARSessionDelegate {
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        guard let frame = session.currentFrame else { return }
        updateSessionInfoLabel(for: frame, trackingState: frame.camera.trackingState)
    }
    
    private func updateSessionInfoLabel(for frame: ARFrame, trackingState: ARCamera.TrackingState) {
        // Update the UI to provide feedback on the state of the AR experience.
        let message: String
        cameraButton.isHidden = true
        switch trackingState {
        case .normal where frame.anchors.isEmpty:
            // No planes detected; provide instructions for this app's AR interactions.
            message = "Move the device around to detect horizontal and vertical surfaces."
        case .notAvailable:
            message = "Tracking unavailable."
        case .limited(.excessiveMotion):
            message = "Tracking limited - Move the device more slowly."
        case .limited(.insufficientFeatures):
            message = "Tracking limited - Point the device at an area with visible surface detail, or improve lighting conditions."
        case .limited(.initializing):
            message = "Initializing AR session."
        case .normal:
            message = ""
            cameraButton.isHidden = !objectWasDropped
        default:
            // No feedback needed when tracking is normal and planes are visible.
            // (Nor when in unreachable limited-tracking states.)
            message = ""
        }
        sessionInfoLabel.text = message
        sessionInfoView.isHidden = message.isEmpty
    }
}
