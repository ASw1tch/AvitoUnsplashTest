//
//  AppConstants.swift
//  AvitoUnsplashTest
//
//  Created by Anatoliy Petrov on 8.9.24..
//

import Foundation

struct Constants {
    struct API {
        static let baseURL = "https://api.unsplash.com/search/photos?"
        static let clientID = "AZ4a8eD6MVZ-_gqNkQhUV88JHDHx5oyxdiJwcP04pqA"
    }
    
    struct NetworkErrorMessages {
        static let invalidURL = "Неверный URL"
        static let noData = "Данные не были получены"
        static let decodingFailed = "Ошибка декодирования данных"
    }
}
