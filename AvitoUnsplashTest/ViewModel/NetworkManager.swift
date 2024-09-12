//
//  NetworkManager.swift
//  AvitoUnsplashTest
//
//  Created by Anatoliy Petrov on 8.9.24..
//

import Foundation
import Network

class NetworkManager {
    private let baseUrl = Constants.API.baseURL
    private let clientID = Constants.API.clientID
  
    var currentPage = 1
    var totalPages = 1
    var isLoadingMore = false
    var perPage = 30
   
    func searchImages(query: String, page: Int = 1, completion: @escaping (Swift.Result<[Result], NetworkError>) -> Void) {
        guard let url = URL(string: baseUrl + "query=\(query)&client_id=\(clientID)&page=\(page)&per_page=\(perPage)") else {
            completion(.failure(.invalidURL))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if error != nil {
                DispatchQueue.main.async {
                    completion(.failure(.unknownError))
                }
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                switch httpResponse.statusCode {
                case 200:
                    break
                case 429:
                    DispatchQueue.main.async {
                        completion(.failure(.rateLimitExceeded))
                    }
                    return
                case 400...499:
                    DispatchQueue.main.async {
                        completion(.failure(.serverError(statusCode: httpResponse.statusCode)))
                    }
                    return
                case 500...599:
                    DispatchQueue.main.async {
                        completion(.failure(.serverError(statusCode: httpResponse.statusCode)))
                    }
                    return
                default:
                    DispatchQueue.main.async {
                        completion(.failure(.unknownError))
                    }
                    return
                }
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(.noData))
                }
                return
            }
            
            do {
                let response = try JSONDecoder().decode(UnsplashResponse.self, from: data)
                DispatchQueue.main.async {
                    self.currentPage = page
                    self.totalPages = response.total_pages
                    completion(.success(response.results))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(.decodingError))
                }
            }
        }
        
        task.resume()
    }
    func getErrorDetails(from error: NetworkError) -> String {
        switch error {
        case .invalidURL:
            return "The URL is invalid. Please contact support."
        case .noData:
            return "No data was received from the server. Please try again later."
        case .rateLimitExceeded:
            return "You have exceeded the request limit. Please wait a few minutes and try again."
        case .serverError(let statusCode):
            switch statusCode {
            case 403:
                return "You have hit the request limit. Please wait a bit before trying again."
            case 404:
                return "The requested resource was not found. Please check your query."
            case 500:
                return "The server encountered an internal error. Please try again later."
            default:
                return "Server returned an error with status code \(statusCode). Please try again later."
            }
        case .noInternetConnection:
            return "No network. Please try again."
        case .decodingError:
            return "There was a problem processing the server's response. Please try again."
        case .unknownError:
            return "An unknown error occurred. Please try again."
        
        }
    }
}

enum NetworkError: Error {
    case invalidURL
    case noData
    case rateLimitExceeded
    case serverError(statusCode: Int)
    case decodingError
    case noInternetConnection
    case unknownError
}

