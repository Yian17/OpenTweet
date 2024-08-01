//
//  Service.swift
//  OpenTweet
//
//  Created by Wu Yian on 2024-07-30.
//  Copyright © 2024 OpenTable, Inc. All rights reserved.
//

import Foundation

enum RequestError: Error {
    case urlError
    case noData
    case decodeError
    case serializeError
    case noResponse
}

protocol ServiceProtocol {
    func fetchTweets() -> Timelinemodel?
    func fetchImage(from urlString: String, completion: @escaping (Result<Data, Error>) -> Void)
}

class Service: ServiceProtocol {
    
    struct Constant {
        static let tweetFileName = "timeline"
    }
    
    enum RequestType: String {
        case post = "POST"
        case get = "GET"
        case put = "PUT"
        case delete = "DELETE"
    }
    
    private let urlDataSession: URLSession
    
    init(urlDataSession: URLSession = URLSession.shared) {
        self.urlDataSession = urlDataSession
    }
    
    func request<T: Decodable> (urlString: String,
                                requestType: RequestType = .get,
                                body: [String: Any]? = nil,
                                type: T.Type,
                                completion: @escaping (Result<T, Error>) -> Void) {
        
        guard let url = URL(string: urlString) else {
            completion(.failure(RequestError.urlError))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = requestType.rawValue
        
        if let body = body {
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: body, options: .prettyPrinted)
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            } catch {
                completion(.failure(RequestError.serializeError))
            }
        }
        
        urlDataSession.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(RequestError.noData))
                return
            }
            
            do {
                if T.self is Data.Type {
                    if let data = data as? T {
                        completion(.success(data))
                        return
                    }
                } else {
                    let dataObject = try JSONDecoder().decode(type, from: data)
                    completion(.success(dataObject))
                }
            } catch {
                completion(.failure(RequestError.decodeError))
            }
            
        }.resume()
    }
    
    func fetchTweets() -> Timelinemodel? {
        if let path = Bundle.main.path(forResource: Constant.tweetFileName, ofType: "json"),
        let data = try? Data(contentsOf: URL(fileURLWithPath: path)),
        let dataObject = try? JSONDecoder().decode(Timelinemodel.self, from: data) {
            return dataObject
        }
        return nil
    }
    
    func fetchImage(from urlString: String, completion: @escaping (Result<Data, Error>) -> Void) {
        request(urlString: urlString, type: Data.self) { result in
            switch result {
            case .success(let data):
                completion(.success(data))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
