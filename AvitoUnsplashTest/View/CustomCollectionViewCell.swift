//
//  CustomCollectionViewCell.swift
//  AvitoUnsplashTest
//
//  Created by Anatoliy Petrov on 8.9.24..
//

import UIKit

class CustomCollectionViewCell: UICollectionViewCell {
    
    // Create the UILabel and UIImageView as properties of the cell
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    let label: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.numberOfLines = 1
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // Add the imageView and label to the content view
        contentView.addSubview(imageView)
        contentView.addSubview(label)
        
        // Enable auto layout
        imageView.translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false
        
        // Set constraints for the imageView and label
        NSLayoutConstraint.activate([
            // Image view constraints (top of the cell, width and height)
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            
            {
                let constraint = imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor)
                constraint.priority = UILayoutPriority(999)
                return constraint
            }(),
            
            label.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            label.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // Method to configure the cell with data
    func configure(with image: UIImage, text: String) {
        imageView.image = image
        label.text = text
    }
}
