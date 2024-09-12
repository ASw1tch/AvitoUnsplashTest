//
//  AvitoUnsplashUITests.swift
//  AvitoUnsplashUITests
//
//  Created by Anatoliy Petrov on 12.9.24..
//

import XCTest

class SearchViewControllerUITests: XCTestCase {
    
    func testSearchAndDisplayCollectionView() {
        let app = XCUIApplication()
        app.launch()

        let searchBar = app.searchFields["Search Images"]
        XCTAssertTrue(searchBar.exists, "Поисковая строка не найдена")

        searchBar.tap()
        searchBar.typeText("Nature")

        app.keyboards.buttons["Search"].tap()
        
        let collectionView = app.collectionViews["CollectionViewIdentifier"]
        XCTAssertTrue(collectionView.exists, "Коллекция не появилась после поиска")
                                
        let firstCell = collectionView.cells.element(boundBy: 0)
        XCTAssertTrue(firstCell.exists, "Не найдено ни одного результата в коллекции")
    }
}
