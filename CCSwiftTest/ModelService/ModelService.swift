//
//  ModelService.swift
//  CCSwiftTest
//
//  Created by Marnix Arnold on 20/09/2020.
//

import Foundation
import RealityKit

enum UnknownError: Error {
    case unknown
}

protocol ModelService {
    func loadModel(atUrl url: URL, resultHandler: @escaping (Result<Entity, Error>) -> ())
}
