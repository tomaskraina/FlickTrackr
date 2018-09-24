//
//  Networking.swift
//  FlickrTrackr
//
//  Created by Tom Kraina on 21/09/2018.
//  Copyright © 2018 Tom Kraina. All rights reserved.
//

import Foundation

enum NetworkingError: Error {
    case network(Error, response: URLResponse?)
    case serialization(Error, response: URLResponse?)
}

class Networking {
    
    static let shared = Networking(session: .shared)
    
    init(session: URLSession) {
        self.session = session
    }
    
    let session: URLSession
    
    @discardableResult
    func request<T: Codable>(url: URL, completion: @escaping (Result<T>) -> Void) -> URLSessionDataTask {
        
        let dataTask = session.dataTask(with: url) { (data, response, error) in
            DispatchQueue.main.async {            
                if let error = error {
                    completion(.failure(error: NetworkingError.network(error, response: response)))
                    
                } else if let data = data {
                    do {
                        let value = try JSONDecoder().decode(T.self, from: data)
                        completion(.success(value: value))
                    } catch {
                        completion(.failure(error: NetworkingError.serialization(error, response: response)))
                    }
                } else {
                    fatalError("Can't process response. Both error and data is not. This should never happen accordnig to Apple's documentation.")
                }
            }
        }
        
        dataTask.resume()
        return dataTask
    }
}
