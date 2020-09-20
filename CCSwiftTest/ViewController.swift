//
//  ViewController.swift
//  CCSwiftTest
//
//  Created by Marnix Arnold on 20/09/2020.
//

import UIKit
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
        
        loadModel(.wateringCan)
        
        // Load the "Box" scene from the "Experience" Reality File
        let boxAnchor = try! Experience.loadBox()
        
        // Add the box anchor to the scene
        arView.scene.anchors.append(boxAnchor)
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
        guard let model = object3D, let anchor = arView.scene.anchors.first else {
            return
        }
        anchor.addChild(model)
    }
    
}
