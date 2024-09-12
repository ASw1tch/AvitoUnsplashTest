//
//  SearchViewModel.swift
//  AvitoUnsplashTest
//
//  Created by Anatoliy Petrov on 8.9.24..
//
import Foundation

class SearchViewModel {
    private let networkManager = NetworkManager()
    var results: [Result] = []
    var onError: ((NetworkError) -> Void)?
    var onLoading: ((Bool) -> Void)?
    var onSuccess: (() -> Void)?
    
    private let searchHistoryKey = "searchHistory"
    private let maxHistoryCount = 5
    
    func saveSearchQuery(_ query: String) {
        var history = getSearchHistory()
        
        if let existingIndex = history.firstIndex(of: query) {
            history.remove(at: existingIndex)
        }
        
        history.insert(query, at: 0)
        
        if history.count > maxHistoryCount {
            history = Array(history.prefix(maxHistoryCount))
        }
        
        UserDefaults.standard.set(history, forKey: searchHistoryKey)
    }
    
    func getSearchHistory() -> [String] {
        return UserDefaults.standard.stringArray(forKey: searchHistoryKey) ?? []
    }
    
    func fetchImages(query: String, isLoadMore: Bool = false) {
        if isLoadMore {
            guard !networkManager.isLoadingMore && networkManager.currentPage < networkManager.totalPages else {
                return
            }
            networkManager.isLoadingMore = true
        } else {
            onLoading?(true)
        }
        
        let page = isLoadMore ? networkManager.currentPage + 1 : 1
        
        networkManager.searchImages(query: query, page: page) { [weak self] result in
            self?.onLoading?(false)
            
            if isLoadMore {
                self?.networkManager.isLoadingMore = false
            }
            
            switch result {
            case .success(let newResults):
                let filteredResults = newResults.filter { $0.description != nil && !$0.description!.isEmpty }
                
                let uniqueResults = filteredResults.filter { newResult in
                    !(self?.results.contains { $0.id == newResult.id } ?? false)
                }
                
                if uniqueResults.isEmpty {
                    print("No result")
                    return
                }
                
                if isLoadMore {
                    self?.results.append(contentsOf: uniqueResults)
                } else {
                    self?.results = uniqueResults
                }
                
                self?.onSuccess?()
                
            case .failure(let error):
                if let networkError = error as? NetworkError {
                    self?.onError?(networkError)
                } else {
                    self?.onError?(.unknownError)
                }
            }
        }
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
            return "Server returned an error with status code \(statusCode). Please try again later."
        case .decodingError:
            return "There was a problem processing the server's response. Please try again."
        case .unknownError:
            return "An unknown error occurred. Please try again."
        case .noInternetConnection:
            return "No iternet connection. Please try again later"
        }
    }
}
