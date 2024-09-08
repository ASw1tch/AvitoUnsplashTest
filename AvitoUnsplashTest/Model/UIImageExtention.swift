//
//  UIImageExtention.swift
//  AvitoUnsplashTest
//
//  Created by Anatoliy Petrov on 8.9.24..
//

import UIKit

extension UIImageView {
    func loadImage(from url: URL, placeholder: UIImage? = nil) {
        // Set a placeholder image (optional)
        if let placeholder = placeholder {
            self.image = placeholder
        }
        
        // Create a URL session to download the image data
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            // Handle error or no data
            if let error = error {
                print("Failed to load image: \(error)")
                return
            }
            
            guard let data = data, let downloadedImage = UIImage(data: data) else {
                print("Invalid image data")
                return
            }
            
            // Update the UIImageView on the main thread
            DispatchQueue.main.async {
                self?.image = downloadedImage
            }
        }.resume()  // Start the URL session task
    }
}
