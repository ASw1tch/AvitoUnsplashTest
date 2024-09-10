//
//  UIImageExtention.swift
//  AvitoUnsplashTest
//
//  Created by Anatoliy Petrov on 8.9.24..
//

import UIKit

let imageCache = NSCache<NSString, UIImage>()

extension UIImageView {
    func loadImage(from url: URL, placeholder: UIImage?) {
        self.image = placeholder
        
        if let cachedImage = imageCache.object(forKey: url.absoluteString as NSString) {
            self.image = cachedImage
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, let image = UIImage(data: data), error == nil else {
                return
            }
            
            imageCache.setObject(image, forKey: url.absoluteString as NSString)
            
            DispatchQueue.main.async {
                UIView.transition(with: self,
                                  duration: 0.3,
                                  options: .transitionCrossDissolve,
                                  animations: {
                    self.image = image
                },
                                  completion: nil)
            }
        }.resume()
    }
}
