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
    private var displayFormatControl: UISegmentedControl!
    
    
    private var viewModel = SearchViewModel()
    private var suggestions: [String] = []
    private var filteredSuggestions: [String] = []
    private var isFirstPageLoading = true
    
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
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapOutside))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
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
        updateLayoutForTwoColumns(layout)
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(CustomCollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.dataSource = self
        collectionView.delegate = self
        view.addSubview(collectionView)
        
        displayFormatControl = UISegmentedControl(items: ["Two Columns", "Single Column"])
        displayFormatControl.selectedSegmentIndex = 0
        displayFormatControl.addTarget(self, action: #selector(changeDisplayFormat), for: .valueChanged)
        displayFormatControl.translatesAutoresizingMaskIntoConstraints = false
        displayFormatControl.isHidden = true
        view.addSubview(displayFormatControl)
       
        NSLayoutConstraint.activate([
            searchBar.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            displayFormatControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            displayFormatControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            displayFormatControl.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 10),
            displayFormatControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            collectionView.topAnchor.constraint(equalTo: displayFormatControl.bottomAnchor, constant: 10),
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
                if isLoading && self?.isFirstPageLoading == true {
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
                    self?.displayFormatControl.isHidden = true
                } else {
                    self?.hideNoResultsLabel()
                    self?.displayFormatControl.isHidden = false
                    self?.isFirstPageLoading = false
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
            tableViewHeightConstraint 
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
    
    @objc func didTapOutside(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: view)
        
        if !tableView.frame.contains(location) {
            tableView.isHidden = true
        }
        
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
        tableView.reloadData() // Перезагружаем таблицу с новыми данными
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
        
        if let url = URL(string: result.urls.regular) {
            cell.imageView.loadImage(from: url, placeholder: UIImage(named: "placeholder"))
        }
        cell.label.text = result.description ?? "📷"
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let result = viewModel.results[indexPath.item]
        if let url = URL(string: result.urls.regular) {
            (cell as? CustomCollectionViewCell)?.imageView.loadImage(from: url, placeholder: UIImage(named: "placeholder"))
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let frameHeight = scrollView.frame.size.height
        
        
        if offsetY > contentHeight - frameHeight * 2 && !viewModel.results.isEmpty {
            viewModel.loadMoreImages(query: searchBar.text ?? "")
        }
    }
    
    @objc private func changeDisplayFormat(_ sender: UISegmentedControl) {
        let layout = UICollectionViewFlowLayout()
        
        if sender.selectedSegmentIndex == 0 {
            updateLayoutForTwoColumns(layout)
        } else {
            updateLayoutForSingleColumn(layout)
        }
        
        collectionView.setCollectionViewLayout(layout, animated: true)
    }
    
    private func updateLayoutForTwoColumns(_ layout: UICollectionViewFlowLayout) {
        let itemWidth = (view.frame.width - 30) / 2 // 2 столбца
        layout.itemSize = CGSize(width: itemWidth, height: itemWidth)
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
    }
    
    private func updateLayoutForSingleColumn(_ layout: UICollectionViewFlowLayout) {
        let itemWidth = view.frame.width - 20 // Одна плитка
        layout.itemSize = CGSize(width: itemWidth, height: itemWidth)
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
    }
}
