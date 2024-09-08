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
    
    // MARK: - Поиск изображений (первая загрузка)
    func searchImages(query: String) {
        onLoading?(true) // Включаем индикатор
        
        networkManager.searchImages(query: query) { [weak self] result in
            self?.onLoading?(false) // Отключаем индикатор
            
            switch result {
            case .success(let results):
                self?.results = results
                self?.onSuccess?()
            case .failure(let error):
                self?.onError?(error.localizedDescription)
            }
        }
    }
    
    // MARK: - Догрузка изображений (следующие страницы)
    func loadMoreImages(query: String) {
        // Проверяем, не грузим ли данные уже и есть ли ещё страницы
        guard !networkManager.isLoadingMore && networkManager.currentPage < networkManager.totalPages else {
            return
        }
        
        networkManager.isLoadingMore = true
        onLoading?(true) // Включаем индикатор для догрузки
        
        networkManager.searchImages(query: query, page: networkManager.currentPage + 1) { [weak self] result in
            self?.onLoading?(false) // Отключаем индикатор после загрузки
            self?.networkManager.isLoadingMore = false
            
            switch result {
            case .success(let newResults):
                self?.results.append(contentsOf: newResults) // Добавляем новые результаты
                self?.onSuccess?()
            case .failure(let error):
                self?.onError?(error.localizedDescription)
            }
        }
    }
}
