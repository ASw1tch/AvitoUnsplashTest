//
//  SearchViewModel.swift
//  AvitoUnsplashTest
//
//  Created by Anatoliy Petrov on 8.9.24..
//
import Foundation

import Foundation

class SearchViewModel {
    private let networkManager = NetworkManager()
    var results: [Result] = []
    var onError: ((String) -> Void)?
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
    
    func searchImages(query: String) {
        onLoading?(true)
        
        networkManager.searchImages(query: query) { [weak self] result in
            self?.onLoading?(false)
            
            switch result {
            case .success(let results):
                self?.results = results
                self?.onSuccess?()
            case .failure(let error):
                self?.onError?(error.localizedDescription)
            }
        }
    }
    
    func loadMoreImages(query: String) {
        
        guard !networkManager.isLoadingMore && networkManager.currentPage < networkManager.totalPages else {
            return
        }
        
        networkManager.isLoadingMore = true
        onLoading?(true)
        
        networkManager.searchImages(query: query, page: networkManager.currentPage + 1) { [weak self] result in
            self?.onLoading?(false)
            self?.networkManager.isLoadingMore = false
            
            switch result {
            case .success(let newResults):
                self?.results.append(contentsOf: newResults)
                self?.onSuccess?()
            case .failure(let error):
                self?.onError?(error.localizedDescription)
            }
        }
    }
}
