//
//  Setting.swift
//  ShareConnect
//
//  Created by laijiaaa1 on 2023/11/18.
//

import Foundation
import UIKit

extension DateFormatter {
    static let iso8601Full: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }()
}
extension DateFormatter {
    static let customDateFormat: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM dd, yyyy"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }()
}
extension UIImage {
    func resized(toSize size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: size))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}
struct CustomColors {
    static let B1 = UIColor(red: 246/255, green: 246/255, blue: 244/255, alpha: 1)
}
class StarRatingView: UIView {
    var rating: Int = 0 {
        didSet {
            setNeedsLayout()
        }
    }
    var ratingButtons = [UIButton]()
    var spacing = 5
    var stars = 5
    override var intrinsicContentSize: CGSize {
        let buttonSize = Int(frame.size.height)
        let width = (buttonSize + spacing) * stars
        return CGSize(width: width, height: buttonSize)
    }
    override func layoutSubviews() {
        var buttonFrame = CGRect(x: 0, y: 0, width: 50, height: 50)
        for (index, button) in ratingButtons.enumerated() {
            buttonFrame.origin.x = CGFloat(index * (50 + spacing))
            button.frame = buttonFrame
        }
        updateButtonSelectionStates()
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        spacing = 5
        stars = 5
        setupButtons()
    }
    required init(coder: NSCoder) {
        super.init(coder: coder)!
        spacing = 5
        stars = 5
        setupButtons()
    }
    private func setupButtons() {
        for _ in 0..<stars {
            let button = UIButton()
            button.backgroundColor = .black
            button.tintColor = UIColor(named: "G3")
            button.setImage(UIImage(systemName: "star"), for: .normal)
            button.setImage(UIImage(systemName: "star.fill"), for: .selected)
            button.adjustsImageWhenHighlighted = false
            button.addTarget(self, action: #selector(ratingButtonTapped(button:)), for: .touchUpInside)
            ratingButtons.append(button)
            addSubview(button)
        }
    }
    @objc func ratingButtonTapped(button: UIButton) {
        guard let index = ratingButtons.firstIndex(of: button) else {
            fatalError("The button, \(button), is not in the ratingButtons array: \(ratingButtons)")
        }
        let selectedRating = index + 1
        if selectedRating == rating {
            rating = 0
        } else {
            rating = selectedRating
        }
    }
    func updateButtonSelectionStates() {
        for (index, button) in ratingButtons.enumerated() {
            button.isSelected = index < rating
        }
    }
}
