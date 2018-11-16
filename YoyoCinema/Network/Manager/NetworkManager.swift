//
//  NetworkManager.swift
//  YoyoCinema
//
//  Created by Marinescu Tudor-Andrei on 13/11/2018.
//  Copyright © 2018 Marinescu Tudor-Andrei. All rights reserved.
//

import Foundation

enum NetworkResponse:String {
    case success
    case authenticationError = "You need to be authenticated."
    case badRequest = "Bad request sent"
    case outdated = "The url requested is outdated."
    case failed = "Network request failed."
    case noData = "Response returned with no data to be decoded."
    case unableToDecode = "Couldn't decode the response."
}

enum Result<String>{
    case success
    case failure(String)
}

struct NetworkManager {
    static let environment : NetworkEnvironment = .production
    static let MovieAPIKey = "4cb1eeab94f45affe2536f2c684a5c9e"
    let router = Router<MovieAPI>()
    
    func getNewMovies(page: Int, completion: @escaping (_ response: MovieAPIResponse?,_ error: String?)->()){
        router.request(.newMovies(page: page)) { data, response, error in
            
            if error != nil {
                completion(nil, "Please check your network connection.")
            }
            
            if let response = response as? HTTPURLResponse {
                let result = self.handleNetworkResponse(response)
                switch result {
                case .success:
                    guard let responseData = data else {
                        completion(nil, NetworkResponse.noData.rawValue)
                        return
                    }
                    do {
                        print(responseData)
                        let jsonData = try JSONSerialization.jsonObject(with: responseData, options: .mutableContainers)
                        print(jsonData)
                        let apiResponse = try JSONDecoder().decode(MovieAPIResponse.self, from: responseData)
                        completion(apiResponse,nil)
                    }catch {
                        print(error)
                        completion(nil, NetworkResponse.unableToDecode.rawValue)
                    }
                case .failure(let networkFailureError):
                    completion(nil, networkFailureError)
                }
            }
        }
    }
    
    
    func searchForMovies(searchCriteria: String, page: Int, completion: @escaping (_ response: MovieAPIResponse?,_ error: String?)->()){
        router.request(.searchMovies(criteria: searchCriteria, page: page)) { data, response, error in
            
            if error != nil {
                completion(nil, "Please check your network connection.")
            }
            
            if let response = response as? HTTPURLResponse {
                let result = self.handleNetworkResponse(response)
                switch result {
                case .success:
                    guard let responseData = data else {
                        completion(nil, NetworkResponse.noData.rawValue)
                        return
                    }
                    do {
                        print(responseData)
                        let jsonData = try JSONSerialization.jsonObject(with: responseData, options: .mutableContainers)
                        print(jsonData)
                        let apiResponse = try JSONDecoder().decode(MovieAPIResponse.self, from: responseData)
                        completion(apiResponse,nil)
                    }catch {
                        print(error)
                        completion(nil, NetworkResponse.unableToDecode.rawValue)
                    }
                case .failure(let networkFailureError):
                    completion(nil, networkFailureError)
                }
            }
        }
    }
    
    fileprivate func handleNetworkResponse(_ response: HTTPURLResponse) -> Result<String>{
        switch response.statusCode {
        case 200...299: return .success
        case 401...500: return .failure(NetworkResponse.authenticationError.rawValue)
        case 501...599: return .failure(NetworkResponse.badRequest.rawValue)
        case 600: return .failure(NetworkResponse.outdated.rawValue)
        default: return .failure(NetworkResponse.failed.rawValue)
        }
    }
}
