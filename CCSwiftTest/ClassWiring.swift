//
//  ClassWiring.swift
//  CCSwiftTest
//
//  Created by Marnix Arnold on 21/09/2020.
//

import Foundation

// TODO: better to use proper dependency injection instead, using e.g. Resolver,
// but for now we don't want to depend on any third-party libraries
class ClassWiring {
    
    static var ModelService: ModelService = NetworkModelService()
    static var SnapShotService: SnapShotService = MemorySnapShotService()

}
