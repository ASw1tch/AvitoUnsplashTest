//
//  AvitoUnsplashTests.swift
//  AvitoUnsplashTests
//
//  Created by Anatoliy Petrov on 12.9.24..
//

import XCTest
@testable import AvitoUnsplashTest

class SearchViewModelTests: XCTestCase {
    
    var viewModel: SearchViewModel!
    
    override func setUp() {
        super.setUp()
        viewModel = SearchViewModel()
        UserDefaults.standard.removeObject(forKey: "searchHistory")
    }
    
    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }
    
    func testSaveSearchQuery() {
        viewModel.saveSearchQuery("Swift")
        viewModel.saveSearchQuery("UIKit")
        
        let history = viewModel.getSearchHistory()
        XCTAssertEqual(history.count, 2)
        XCTAssertEqual(history.first, "UIKit")
    }
}
