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

enum ModelLocation: String {
    case wateringCan = "https://github.com/CubiCasa/CCSwiftTest/blob/master/wateringcan.usdz?raw=true"
}

class ViewController: UIViewController {
    
    @IBOutlet var arView: ARView!
    
    // TODO: do proper dependency injection with e.g. Resolver
    private var modelService: ModelService = NetworkModelService()
    private var snapShotService: SnapShotService = MemorySnapShotService()
    
    // The object that we want to add to our scene
    private var object3D: Entity? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        arView.session.delegate = self
        
        loadModel(.wateringCan)
    }
    
    private func loadModel(_ location: ModelLocation) {
        guard let url = URL(string: location.rawValue) else {
            return
        }
        modelService.loadModel(atUrl: url) { [weak self] (result) in
            switch result {
            case .success(let model):
                self?.object3D = model
                print("Model loaded successfully")
                self?.dropModelInScene()
            case .failure(let error):
                print("Error loading model: \(error.localizedDescription)")
            }
        }
    }
    
    private func dropModelInScene() {
        guard let model = object3D else {
            return
        }

        // Load the "Box" scene from the "Experience" Reality File
        let boxAnchor = try! Experience.loadBox()
        
        // Add the box anchor to the scene
        arView.scene.anchors.append(boxAnchor)

        // Add the model to the box anchor
        boxAnchor.addChild(model)
    }
}

extension ViewController: ARSessionDelegate {
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        guard let frame = session.currentFrame else { return }
        updateSessionInfoLabel(for: frame, trackingState: frame.camera.trackingState)
    }
    
    private func updateSessionInfoLabel(for frame: ARFrame, trackingState: ARCamera.TrackingState) {
        // Update the UI to provide feedback on the state of the AR experience.
        let message: String

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
            
        default:
            // No feedback needed when tracking is normal and planes are visible.
            // (Nor when in unreachable limited-tracking states.)
            message = ""

        }
        if !message.isEmpty {
            print(message)
        }
//        sessionInfoLabel.text = message
//        sessionInfoView.isHidden = message.isEmpty
    }

}
