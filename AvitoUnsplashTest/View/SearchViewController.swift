//
//  SearchViewController.swift
//  AvitoUnsplashTest
//
//  Created by Anatoliy Petrov on 8.9.24..
//

import UIKit

class SearchViewController: UIViewController {
    
    private var searchBar: UISearchBar!
    private var collectionView: UICollectionView!
    private var activityIndicator: UIActivityIndicatorView!
    private var noResultsLabel: UILabel!
    private var tableView: UITableView!
    
    private var viewModel = SearchViewModel()
    private var suggestions: [String] = []
    private var filteredSuggestions: [String] = []
    
    let maxVisibleSuggestions = 5
    var tableViewHeightConstraint: NSLayoutConstraint!
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        setupTableView()
        
        suggestions = viewModel.getSearchHistory()
        filteredSuggestions = suggestions
    }
    
    // MARK: - Setup Methods
    
    private func setupUI() {
        view.backgroundColor = .white
        
        searchBar = UISearchBar()
        searchBar.placeholder = "Search Images"
        searchBar.delegate = self
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.searchBarStyle = .minimal
        searchBar.backgroundImage = UIImage()
        view.addSubview(searchBar)
        
        activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityIndicator)
        
        noResultsLabel = UILabel()
        noResultsLabel.text = "No results found"
        noResultsLabel.textAlignment = .center
        noResultsLabel.textColor = .gray
        noResultsLabel.font = UIFont.systemFont(ofSize: 20)
        noResultsLabel.translatesAutoresizingMaskIntoConstraints = false
        noResultsLabel.isHidden = true
        view.addSubview(noResultsLabel)
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 1
        layout.minimumLineSpacing = 1
        layout.itemSize = CGSize(width: view.frame.size.width/2 - 1, height: view.frame.size.width/2 - 1)
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(CustomCollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.layoutIfNeeded()
        collectionView.backgroundColor = .clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            searchBar.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 10),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            noResultsLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            noResultsLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupBindings() {
        viewModel.onLoading = { [weak self] isLoading in
            DispatchQueue.main.async {
                if isLoading {
                    self?.activityIndicator.startAnimating()
                    self?.collectionView.isHidden = true
                } else {
                    self?.activityIndicator.stopAnimating()
                    self?.collectionView.isHidden = false
                }
            }
        }
        
        viewModel.onError = { [weak self] errorMessage in
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self?.present(alert, animated: true)
            }
        }
        
        viewModel.onSuccess = { [weak self] in
            DispatchQueue.main.async {
                self?.collectionView.reloadData()
                if self?.viewModel.results.isEmpty == true {
                    self?.showNoResultsLabel()
                } else {
                    self?.hideNoResultsLabel()
                }
            }
        }
    }
    
    
    private func setupTableView() {
        tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "SuggestionCell")
        
        tableViewHeightConstraint = tableView.heightAnchor.constraint(equalToConstant: 0)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 10),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        tableView.isHidden = true
    }
    
    private func showNoResultsLabel() {
        noResultsLabel.isHidden = false
        collectionView.isHidden = true
    }
    
    private func hideNoResultsLabel() {
        noResultsLabel.isHidden = true
        collectionView.isHidden = false
    }
}

// MARK: - UISearchBarDelegate
extension SearchViewController: UISearchBarDelegate {
    func filterSuggestions(_ query: String) {
        if query.isEmpty {
            filteredSuggestions = suggestions
        } else {
            filteredSuggestions = suggestions.filter { $0.lowercased().contains(query.lowercased()) }
        }
        tableView.reloadData()
        tableView.isHidden = filteredSuggestions.isEmpty
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        if !suggestions.isEmpty {
            tableView.isHidden = false
            adjustTableViewHeight()
        }
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        tableView.isHidden = true
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let query = searchBar.text, !query.isEmpty else { return }
        
        NSLayoutConstraint.deactivate(view.constraints.filter { $0.firstAnchor == searchBar.centerYAnchor })
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
        ])
        
        viewModel.searchImages(query: query)
        viewModel.saveSearchQuery(query)
        print(viewModel.getSearchHistory())
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterSuggestions(searchText)
        adjustTableViewHeight()
    }
}

// MARK: - UITableViewDelegate and UITableViewDataSource
extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredSuggestions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SuggestionCell", for: indexPath)
        cell.textLabel?.text = filteredSuggestions[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedSuggestion = filteredSuggestions[indexPath.row]
        searchBar.text = selectedSuggestion
        viewModel.saveSearchQuery(selectedSuggestion)
        tableView.isHidden = true
        viewModel.searchImages(query: selectedSuggestion)
        searchBarSearchButtonClicked(searchBar)
    }
    
    func adjustTableViewHeight() {
        let rowHeight: CGFloat = 44.0
        let numberOfRows = min(filteredSuggestions.count, maxVisibleSuggestions)
        let newHeight = CGFloat(numberOfRows) * rowHeight
        
        tableViewHeightConstraint.constant = newHeight
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
}

// MARK: - UICollectionViewDelegate and UICollectionViewDataSource
extension SearchViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.results.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CustomCollectionViewCell
        let result = viewModel.results[indexPath.item]
        cell.imageView.loadImage(from: URL(string: result.urls.thumb)!)
        cell.label.text = result.description
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let frameHeight = scrollView.frame.size.height
        
        
        if offsetY > contentHeight - frameHeight * 2 && !viewModel.results.isEmpty {
            viewModel.loadMoreImages(query: searchBar.text ?? "")
        }
    }
}
