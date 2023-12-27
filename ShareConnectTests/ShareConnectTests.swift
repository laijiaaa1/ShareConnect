//
//  ShareConnectTests.swift
//  ShareConnectTests
//
//  Created by laijiaaa1 on 2023/12/25.
//

import XCTest
import FirebaseAuth
@testable import ShareConnect

class StarRatingViewTests: XCTestCase {
    var starRatingView: StarRatingView!
    override func setUp() {
        super.setUp()
        starRatingView = StarRatingView()
    }
    override func tearDown() {
        starRatingView = nil
        super.tearDown()
    }
    func testRatingButtonTapped() {
        let button1 = UIButton()
        let button2 = UIButton()
        let button3 = UIButton()
        starRatingView.ratingButtons = [button1, button2, button3]
        starRatingView.ratingButtonTapped(button: button2)
        XCTAssertEqual(starRatingView.rating, 2, "Rating should be set to the index + 1 of the tapped button.")
        starRatingView.ratingButtonTapped(button: button2)
        XCTAssertEqual(starRatingView.rating, 0, "Tapping the same button again should reset the rating.")
    }
    func testUpdateButtonSelectionStates() {
            let button1 = UIButton()
            let button2 = UIButton()
            let button3 = UIButton()
            starRatingView.ratingButtons = [button1, button2, button3]
            starRatingView.rating = 2
            starRatingView.updateButtonSelectionStates()
            XCTAssertTrue(button1.isSelected, "Button 1 should be selected because its index is less than the rating.")
            XCTAssertTrue(button2.isSelected, "Button 2 should be selected because its index is less than the rating.")
            XCTAssertFalse(button3.isSelected, "Button 3 should not be selected because its index is greater than the rating.")
            starRatingView.rating = 0
            starRatingView.updateButtonSelectionStates()
            XCTAssertFalse(button1.isSelected, "Button 1 should not be selected because the rating is 0.")
            XCTAssertFalse(button2.isSelected, "Button 2 should not be selected because the rating is 0.")
            XCTAssertFalse(button3.isSelected, "Button 3 should not be selected because the rating is 0.")
        }
}
