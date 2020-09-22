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
    
    // Using 'poor man's dependency injection' for now
    private var modelService = ClassWiring.ModelService
    private var snapShotService = ClassWiring.SnapShotService

    // Simple state machine, mostly for controlling button visibility
    private enum State {
        case starting
        case loadingObject
        case readyToDropObject
        case droppingObject
        case readyToTakeSnapshot
        case takingSnapShot
        case error
    }
    private var _state: State = .starting
    private var state: State {
        get {
            return _state
        }
        set {
            guard newValue != _state else {
                return
            }
            _state = newValue
            updateButtonsForState()
            switch _state {
            case .loadingObject:
                loadObject(.wateringCan)
            case .droppingObject:
                dropObjectInScene()
            case .takingSnapShot:
                takeSnapShot()
            default:
                break
            }
        }
    }
    // Controls whether we can show the gallery
    private var hasSavedPicture = false
    
    private func updateButtonsForState() {
        dropButton.isHidden = (state != .readyToDropObject)
        cameraButton.isHidden = (state != .readyToTakeSnapshot)
        galleryButton.isHidden = !hasSavedPicture && (state != .takingSnapShot)
    }

    // The object that we want to add to our scene, after it's loaded
    private var objectEntity: ModelEntity? = nil
    private let objectAnchorName = "UserObjectAnchor"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        arView.session.delegate = self
        setupDropButton()
        state = .loadingObject
    }
    
    private func setupDropButton() {
        // Some visual tweaks that are easier in code
        dropButton.backgroundColor = UIColor.blue
        dropButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        dropButton.tintColor = UIColor.white
        dropButton.layer.cornerRadius = dropButton.frame.size.width / 2
    }
    
    private func loadObject(_ model: Object3D) {
        modelService.loadModel(model) { [weak self] (result) in
            switch result {
            case .success(let model):
                self?.objectEntity = model
                print("Model loaded successfully")
                self?.state = .readyToDropObject
            case .failure(let error):
                print("Error loading model: \(error.localizedDescription)")
                self?.state = .error
            }
        }
    }
    
    private func dropObjectInScene() {
        guard let model = objectEntity else {
            state = .error
            return
        }
        let anchorEntity = AnchorEntity(plane: .horizontal)
        arView.scene.anchors.append(anchorEntity)
        anchorEntity.addChild(model)
    }
    
    @IBAction func didTapDropButton(_ sender: Any) {
        state = .droppingObject
    }
    
    @IBAction func didTapSnapShotButton(_ sender: Any) {
        state = .takingSnapShot
    }
    
    private func takeSnapShot() {
        let cameraTransform = arView.cameraTransform
        arView.snapshot(saveToHDR: true) { [weak self] (arViewImage) in
            guard let image = arViewImage else {
                // Snapshot failed, but we can try again
                self?.state = .readyToTakeSnapshot
                return
            }
            let snapShot = SnapShot(image: image, cameraTransform: cameraTransform)
            self?.snapShotService.addSnapShot(snapShot) { [weak self] (result) in
                switch result {
                case .success:
                    print("Snapshot saved")
                    self?.hasSavedPicture = true
                    self?.state = .readyToTakeSnapshot
                case .failure(let error):
                    print("Snapshot not saved: \(error.localizedDescription)")
                    self?.state = .error
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

// Monitoring the ARSession and providing the user with feedback
extension ARViewController: ARSessionDelegate {
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        guard let frame = session.currentFrame else { return }
        updateSessionInfoLabel(for: frame, trackingState: frame.camera.trackingState)
    }
    
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        if state == .droppingObject {
            print("Did add user object anchor")
            state = .readyToTakeSnapshot
        }
    }
    
    private func updateSessionInfoLabel(for frame: ARFrame, trackingState: ARCamera.TrackingState) {
        // Update the UI to provide feedback on the state of the AR experience.
        let message: String
        cameraButton.isHidden = true
        dropButton.isHidden = true
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
            updateButtonsForState()
        default:
            // No feedback needed when tracking is normal and planes are visible.
            // (Nor when in unreachable limited-tracking states.)
            message = ""
        }
        sessionInfoLabel.text = message
        sessionInfoView.isHidden = message.isEmpty
    }
}
