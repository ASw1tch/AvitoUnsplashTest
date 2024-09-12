//
//  DetailViewController.swift
//  AvitoUnsplashTest
//
//  Created by Anatoliy Petrov on 12.9.24..
//

import UIKit
import Photos

class DetailViewController: UIViewController {
    
    private let userImageView = UIImageView()
    private let usernameLabel = UILabel()
    private let photoImageView = UIImageView()
    private let descriptionLabel = UILabel()
    
    var userImageUrl: String?
    var username: String?
    var photoUrl: String?
    var photoDescription: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureView()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        userImageView.contentMode = .scaleAspectFill
        userImageView.clipsToBounds = true
        userImageView.layer.cornerRadius = 25
        view.addSubview(userImageView)
        
        usernameLabel.font = UIFont.boldSystemFont(ofSize: 20)
        view.addSubview(usernameLabel)
        
        photoImageView.contentMode = .scaleAspectFill
        photoImageView.clipsToBounds = true
        view.addSubview(photoImageView)
        
        descriptionLabel.font = UIFont.systemFont(ofSize: 16)
        descriptionLabel.numberOfLines = 0
        view.addSubview(descriptionLabel)
        
        userImageView.translatesAutoresizingMaskIntoConstraints = false
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        photoImageView.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        let saveButton = UIButton(type: .system)
        var config = UIButton.Configuration.filled()
        
        config.title = " Save photo "
        config.image = UIImage(systemName: "square.and.arrow.down")
        config.baseBackgroundColor = .systemBlue
        config.baseForegroundColor = .white
        saveButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        config.cornerStyle = .medium
        
        // Задаем отступы для контента
        config.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20)
        
        saveButton.configuration = config
        saveButton.addTarget(self, action: #selector(saveImage), for: .touchUpInside)
        view.addSubview(saveButton)
        
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        userImageView.translatesAutoresizingMaskIntoConstraints = false
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        photoImageView.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            userImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            userImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            userImageView.widthAnchor.constraint(equalToConstant: 50),
            userImageView.heightAnchor.constraint(equalToConstant: 50),
            
            usernameLabel.centerYAnchor.constraint(equalTo: userImageView.centerYAnchor),
            usernameLabel.leadingAnchor.constraint(equalTo: userImageView.trailingAnchor, constant: 16),
            
            photoImageView.topAnchor.constraint(equalTo: userImageView.bottomAnchor, constant: 16),
            photoImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            photoImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            photoImageView.heightAnchor.constraint(equalToConstant: 300),
            
            descriptionLabel.topAnchor.constraint(equalTo: photoImageView.bottomAnchor, constant: 16),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            saveButton.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 16),
            saveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func configureView() {
        if let userImageUrl = userImageUrl, let url = URL(string: userImageUrl) {
            userImageView.loadImage(from: url, placeholder: UIImage(named: "placeholder"))
        }
        
        usernameLabel.text = username
        
        if let photoUrl = photoUrl, let url = URL(string: photoUrl) {
            photoImageView.loadImage(from: url, placeholder: UIImage(named: "placeholder"))
        }
        
        descriptionLabel.text = photoDescription ?? "No description available."
    }
    
    @objc private func saveImage() {
        guard let image = photoImageView.image else {
            showAlert(title: "Error", message: "No image available to save.")
            return
        }
        
        PHPhotoLibrary.requestAuthorization { status in
            switch status {
            case .authorized:
                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                DispatchQueue.main.async {
                    self.showAlert(title: "Saved!", message: "The image has been saved to your photos.")
                }
            case .denied, .restricted:
                DispatchQueue.main.async {
                    self.showAlert(title: "Access Denied", message: "Please enable access to the photo library in Settings to save images.")
                }
            case .notDetermined:
                break
            case .limited:
                break
            @unknown default:
                break
            }
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
