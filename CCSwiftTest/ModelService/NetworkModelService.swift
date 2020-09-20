//
//  NetworkModelService.swift
//  CCSwiftTest
//
//  Created by Marnix Arnold on 20/09/2020.
//

import Foundation
import RealityKit
import Combine

class NetworkModelService: ModelService {
    private var downloadTask: URLSessionTask? = nil

    func loadModel(atUrl url: URL, resultHandler: @escaping (Result<Entity, Error>) -> ()) {
        downloadTask = URLSession(configuration: .default).downloadTask(with: url) {(resultUrl, response, error) in
            self.downloadTask = nil
            guard let localUrl = resultUrl else {
                if let err = error {
                    resultHandler(.failure(err))
                } else {
                    resultHandler(.failure(UnknownError.unknown))
                }
                return
            }
            
            // Move the file somewhere safe, so that the URLSession does not delete it while we are parsing
            let fileMgr = FileManager.default
            let modelFileUrl = fileMgr.temporaryDirectory.appendingPathComponent("model.usdz")
            do {
                if fileMgr.fileExists(atPath: modelFileUrl.path) {
                    try fileMgr.removeItem(atPath: modelFileUrl.path)
                }
                try fileMgr.moveItem(at: localUrl, to: modelFileUrl)
            } catch let e {
                resultHandler(.failure(e))
                return
            }
            
            // Load the model from the local file
            // Entity.loadAsync crashes so we're doing it synchronously, inside this async
            DispatchQueue.main.async {
                do {
                    let entity = try Entity.load(contentsOf: modelFileUrl)
                    resultHandler(.success(entity))
                } catch let e {
                    resultHandler(.failure(e))
                }
            }
        }
        downloadTask?.resume()
    }
}
