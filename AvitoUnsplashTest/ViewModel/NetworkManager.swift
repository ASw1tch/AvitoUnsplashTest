//
//  NetworkManager.swift
//  AvitoUnsplashTest
//
//  Created by Anatoliy Petrov on 8.9.24..
//

import Foundation

class NetworkManager {
    private let baseUrl = Constants.API.baseURL
    private let clientID = Constants.API.clientID
    
    var currentPage = 1
    var totalPages = 1
    var isLoadingMore = false
    
    func searchImages(query: String, page: Int = 1, completion: @escaping (Swift.Result<[Result], Error>) -> Void) {
        guard let url = URL(string: baseUrl+"query=\(query)&client_id=\(clientID)&page=\(page)") else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1, userInfo: nil)))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "No data", code: -2, userInfo: nil)))
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
            } catch let decodingError {
                DispatchQueue.main.async {
                    completion(.failure(decodingError))
                }
            }
        }
        print(url)
        task.resume()
    }
}

