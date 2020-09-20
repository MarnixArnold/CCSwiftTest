//
//  SnapShotService.swift
//  CCSwiftTest
//
//  Created by Marnix Arnold on 20/09/2020.
//

import Foundation

protocol SnapShotService {
    func getSnapShots(resultHandler: @escaping (Result<[SnapShot], Error>) -> ())
    func addSnapShot(_ snapShot: SnapShot, resultHandler: @escaping (Result<Void, Error>) -> ())
}
