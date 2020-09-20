//
//  ModelService.swift
//  CCSwiftTest
//
//  Created by Marnix Arnold on 20/09/2020.
//

import Foundation
import RealityKit

enum Object3D {
    case wateringCan
}

protocol ModelService {
    func loadModel(_ object3D: Object3D, resultHandler: @escaping (Result<Entity, Error>) -> ())
}
