//
//  Service.swift
//  OpenTweet
//
//  Created by Wu Yian on 2024-07-30.
//  Copyright © 2024 OpenTable, Inc. All rights reserved.
//

import Foundation

enum RequestError: Error {
    case urlError          // Invalid URL
    case noData            // No data received
    case decodeError       // Error decoding the received data
    case serializeError    // Error serializing the request body
    case noResponse        // No response received
}

protocol ServiceProtocol {
    /// Fetches tweets from a local JSON file
    /// - Returns: A TimelineModel object if successful, nil otherwise
    func fetchTweets() -> TimelineModel?
    
    /// Fetches an image from a given URL
    /// - Parameters:
    ///   - urlString: The URL of the image as a string
    ///   - completion: A closure to be called with the result of the fetch
    func fetchImage(from urlString: String, completion: @escaping (Result<Data, Error>) -> Void)
}

class Service: ServiceProtocol {
    
    struct Constant {
        static let tweetFileName = "timeline" // Name of the local JSON file containing tweets
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
    
    /// Performs a generic network request
    /// - Parameters:
    ///   - urlString: The URL for the request
    ///   - requestType: The HTTP method to use. Defaults to .get
    ///   - body: The body of the request, if any
    ///   - type: The expected return type, which must conform to Decodable
    ///   - completion: A closure to be called with the result of the request
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
    
    func fetchTweets() -> TimelineModel? {
        if let path = Bundle.main.path(forResource: Constant.tweetFileName, ofType: "json"),
        let data = try? Data(contentsOf: URL(fileURLWithPath: path)),
        let dataObject = try? JSONDecoder().decode(TimelineModel.self, from: data) {
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
