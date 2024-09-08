//
//  UnsplashResponse.swift
//  AvitoUnsplashTest
//
//  Created by Anatoliy Petrov on 8.9.24..
//

import Foundation

// MARK: - UnsplashResponse
struct UnsplashResponse: Codable {
    let total: Int
    let total_pages: Int
    let results: [Result]
}


// MARK: - Result
struct Result: Codable {
    let id: String
    let description: String?
    let user: User
    let urls: Urls
}

// MARK: - Urls
struct Urls: Codable {
    let full, regular, small, thumb: String
}

// MARK: - User
struct User: Codable {
    let username, name: String
    let profileImage: ProfileImage
    
    enum CodingKeys: String, CodingKey {
        case username, name
        case profileImage = "profile_image"
    }
}

// MARK: - ProfileImage
struct ProfileImage: Codable {
    let small, medium, large: String
}
