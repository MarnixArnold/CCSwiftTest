//
//  MemorySnapShotService.swift
//  CCSwiftTest
//
//  Created by Marnix Arnold on 20/09/2020.
//

import Foundation

class MemorySnapShotService: SnapShotService {
    func getSnapShots(resultHandler: @escaping (Result<[SnapShot], Error>) -> ()) {
        resultHandler(.success(snapShots))
    }
    
    func addSnapShot(_ snapShot: SnapShot, resultHandler: @escaping (Result<Void, Error>) -> ()) {
        snapShots.append(snapShot)
        resultHandler(.success(()))
    }
    
    private var snapShots: [SnapShot] = []
}
