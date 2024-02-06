//
//  DetailViewController.swift
//  ShareConnect
//
//  Created by laijiaaa1 on 2023/11/17.
//

import UIKit
import Kingfisher
import DatePicker
import Firebase
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage

class DetailViewController: UIViewController {
    var product: Product?
    let titleLabel = UILabel()
    let detailImage = UIImageView()
    let price = UILabel()
    let priceImage = UIImageView()
    let addCartButton = UIButton()
    let chatButton = UIButton()
    let availabilityView = UIView()
    let availability = UILabel()
    let descriptionView = UIView()
    let descriptionLabel = UILabel()
    let descriptionButton = UIButton()
    let descriptionLabel2 = UILabel()
    let sort = UILabel()
    let quantity = UILabel()
    let use = UILabel()
    let otherView = UIView()
    let otherLabel = UILabel()
    let otherButton = UIButton()
    let collectionButton = UIButton()
    let shareButton = UIButton()
    var productID: String?
    let sellerButton = UIButton()
    let contentDescriptionView = UIScrollView()
    var isCollected = false
    let scrollView = UIScrollView()
    let contentView = UIView()
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = true
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupView()
        if let product = product {
            titleLabel.text = product.name
            let url = URL(string: product.imageString)
            detailImage.kf.setImage(with: url)
            price.text = product.price
            productID = product.productId
        }
        loadSavedCollections()
    }
    override func viewDidLayoutSubviews() {
           super.viewDidLayoutSubviews()
           // 在 Auto Layout 設置完成後，設置 contentView 的尺寸為 scrollView 的＋高度
           contentView.frame.size = CGSize(width: scrollView.bounds.width, height: scrollView.bounds.height + 70)
           // 設置 scrollView 的 contentSize 為 contentView 的尺寸
           scrollView.contentSize = contentView.frame.size
       }
    func setupView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.backgroundColor = .black
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            contentView.heightAnchor.constraint(equalTo: view.heightAnchor, constant: 100)
        ])
        contentView.addSubview(titleLabel)
        titleLabel.text = "Title"
        titleLabel.font = UIFont(name: "PingFangTC-Semibold", size: 30)
        titleLabel.textColor = .white
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 120).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 30).isActive = true
        titleLabel.widthAnchor.constraint(equalToConstant: 200).isActive = true
        contentView.addSubview(detailImage)
        detailImage.image = UIImage(named: "wait")
        detailImage.contentMode = .scaleAspectFill
        detailImage.clipsToBounds = true
        detailImage.layer.cornerRadius = 15
        detailImage.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            detailImage.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            detailImage.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            detailImage.heightAnchor.constraint(equalToConstant: 180),
            detailImage.widthAnchor.constraint(equalToConstant: 320)
        ])
        contentView.addSubview(priceImage)
        priceImage.image = UIImage(named: "icons8-price-50 (1)")
        priceImage.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            priceImage.topAnchor.constraint(equalTo: detailImage.bottomAnchor, constant: 30),
            priceImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 30),
            priceImage.heightAnchor.constraint(equalToConstant: 30),
            priceImage.widthAnchor.constraint(equalToConstant: 30)
        ])
        contentView.addSubview(price)
        price.text = "800 / Day"
        price.font = UIFont(name: "PingFangTC-Semibold", size: 18)
        price.textColor = .white
        price.translatesAutoresizingMaskIntoConstraints = false
        price.centerYAnchor.constraint(equalTo: priceImage.centerYAnchor).isActive = true
        price.leadingAnchor.constraint(equalTo: priceImage.trailingAnchor, constant: 20).isActive = true
        price.widthAnchor.constraint(equalToConstant: 200)
        contentView.addSubview(addCartButton)
        addCartButton.setImage(UIImage(named: "icons8-cart-90"), for: .normal)
        addCartButton.translatesAutoresizingMaskIntoConstraints = false
        addCartButton.addTarget(self, action: #selector(goSelectedPage), for: .touchUpInside)
        addCartButton.startAnimatingPressActions()
        NSLayoutConstraint.activate([
            addCartButton.centerYAnchor.constraint(equalTo: price.centerYAnchor),
            addCartButton.leadingAnchor.constraint(equalTo: price.trailingAnchor, constant: 120),
            addCartButton.heightAnchor.constraint(equalToConstant: 30),
            addCartButton.widthAnchor.constraint(equalToConstant: 30)
        ])
        contentView.addSubview(chatButton)
        chatButton.addTarget(self, action: #selector(goChatPage), for: .touchUpInside)
        chatButton.setImage(UIImage(named: "icons8-customer-support-90 (1)"), for: .normal)
        chatButton.startAnimatingPressActions()
        chatButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            chatButton.centerYAnchor.constraint(equalTo: price.centerYAnchor),
            chatButton.leadingAnchor.constraint(equalTo: addCartButton.trailingAnchor, constant: 30),
            chatButton.heightAnchor.constraint(equalToConstant: 30),
            chatButton.widthAnchor.constraint(equalToConstant: 30)
        ])
        contentView.addSubview(collectionButton)
        collectionButton.setImage(UIImage(named: "icons8-bookmark-72(@3×)"), for: .normal)
        collectionButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionButton.bottomAnchor.constraint(equalTo: titleLabel.bottomAnchor),
            collectionButton.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 40),
            collectionButton.heightAnchor.constraint(equalToConstant: 30),
            collectionButton.widthAnchor.constraint(equalToConstant: 30)
        ])
        collectionButton.addTarget(self, action: #selector(addCollection), for: .touchUpInside)
        collectionButton.startAnimatingPressActions()
        contentView.addSubview(shareButton)
        shareButton.setImage(UIImage(named: "icons8-share-96"), for: .normal)
        shareButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            shareButton.bottomAnchor.constraint(equalTo: titleLabel.bottomAnchor),
            shareButton.leadingAnchor.constraint(equalTo: collectionButton.trailingAnchor, constant: 30),
            shareButton.heightAnchor.constraint(equalToConstant: 30),
            shareButton.widthAnchor.constraint(equalToConstant: 30)
        ])
        shareButton.addTarget(self, action: #selector(share), for: .touchUpInside)
        shareButton.startAnimatingPressActions()
        contentView.addSubview(availabilityView)
        availabilityView.backgroundColor = .white
        availabilityView.layer.cornerRadius = 10
        availabilityView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            availabilityView.topAnchor.constraint(equalTo: priceImage.bottomAnchor, constant: 30),
            availabilityView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 30),
            availabilityView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -30),
            availabilityView.heightAnchor.constraint(equalToConstant: 70)
        ])
        availabilityView.addSubview(availability)
        availability.text = "Availability"
        availability.font = UIFont(name: "PingFangTC-Semibold", size: 20)
        availability.textColor = .black
        availability.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            availability.centerYAnchor.constraint(equalTo: availabilityView.centerYAnchor),
            availability.leadingAnchor.constraint(equalTo: availabilityView.leadingAnchor, constant: 30)
        ])
        let dateImage = UIImageView()
        availabilityView.addSubview(dateImage)
        dateImage.image = UIImage(named: "icons8-today-72(@3×)-1")
        dateImage.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            dateImage.centerYAnchor.constraint(equalTo: availability.centerYAnchor),
            dateImage.widthAnchor.constraint(equalToConstant: 30),
            dateImage.heightAnchor.constraint(equalToConstant: 30),
            dateImage.trailingAnchor.constraint(equalTo: availabilityView.trailingAnchor, constant: -30)
        ])
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dateImageTapped))
        dateImage.isUserInteractionEnabled = true
        dateImage.addGestureRecognizer(tapGesture)
        contentView.addSubview(descriptionView)
        descriptionView.backgroundColor = .white /*UIColor(named: "G2")*/
        descriptionView.layer.cornerRadius = 10
        descriptionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            descriptionView.topAnchor.constraint(equalTo: availabilityView.bottomAnchor, constant: 30),
            descriptionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 30),
            descriptionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -30),
            descriptionView.heightAnchor.constraint(equalToConstant: 70)
        ])
        descriptionView.addSubview(descriptionLabel)
        descriptionLabel.text = "Product details"
        descriptionLabel.numberOfLines = 0
        descriptionLabel.font = UIFont(name: "PingFangTC-Semibold", size: 20)
        descriptionLabel.textColor = .black
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            descriptionLabel.centerYAnchor.constraint(equalTo: descriptionView.centerYAnchor),
            descriptionLabel.leadingAnchor.constraint(equalTo: descriptionView.leadingAnchor, constant: 30)
        ])
        descriptionView.addSubview(descriptionButton)
        descriptionButton.setImage(UIImage(named: "icons8-next-72(@3×)"), for: .normal)
        descriptionButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            descriptionButton.centerYAnchor.constraint(equalTo: descriptionView.centerYAnchor),
            descriptionButton.trailingAnchor.constraint(equalTo: descriptionView.trailingAnchor, constant: -30),
            descriptionButton.heightAnchor.constraint(equalToConstant: 20),
            descriptionButton.widthAnchor.constraint(equalToConstant: 20)
        ])
        let tap = UITapGestureRecognizer(target: self, action: #selector(descriptionButtonTapped))
        descriptionButton.isUserInteractionEnabled = true
        descriptionButton.addGestureRecognizer(tap)
        contentView.addSubview(otherView)
        otherView.backgroundColor = .white /*UIColor(named: "G2")*/
        otherView.layer.cornerRadius = 10
        otherView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            otherView.topAnchor.constraint(equalTo: descriptionView.bottomAnchor, constant: 30),
            otherView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 30),
            otherView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -30),
            otherView.heightAnchor.constraint(equalToConstant: 70)
        ])
        otherView.addSubview(otherLabel)
        otherLabel.text = "Other remark"
        otherLabel.font = UIFont(name: "PingFangTC-Semibold", size: 20)
        otherLabel.textColor = .black
        otherLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            otherLabel.centerYAnchor.constraint(equalTo: otherView.centerYAnchor),
            otherLabel.leadingAnchor.constraint(equalTo: otherView.leadingAnchor, constant: 30)
        ])
        otherView.addSubview(otherButton)
        otherButton.setImage(UIImage(named: "icons8-next-72(@3×)"), for: .normal)
        otherButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            otherButton.centerYAnchor.constraint(equalTo: otherView.centerYAnchor),
            otherButton.trailingAnchor.constraint(equalTo: otherView.trailingAnchor, constant: -30),
            otherButton.heightAnchor.constraint(equalToConstant: 20),
            otherButton.widthAnchor.constraint(equalToConstant: 20)
        ])
        let backButton = UIButton()
        contentView.addSubview(backButton)
        backButton.setImage(UIImage(named: "icons8-back-to-50"), for: .normal)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 65),
            backButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 30),
            backButton.heightAnchor.constraint(equalToConstant: 40),
            backButton.widthAnchor.constraint(equalToConstant: 40)
        ])
        backButton.addTarget(self, action: #selector(back), for: .touchUpInside)
        backButton.startAnimatingPressActions()
        contentView.addSubview(sellerButton)
        sellerButton.translatesAutoresizingMaskIntoConstraints = false
        sellerButton.backgroundColor = .black
        sellerButton.startAnimatingPressActions()
        sellerButton.setImage(UIImage(named: "icons8-comment-48(@2×)"), for: .normal)
        NSLayoutConstraint.activate([
            sellerButton.centerYAnchor.constraint(equalTo: addCartButton.centerYAnchor),
            sellerButton.trailingAnchor.constraint(equalTo: addCartButton.leadingAnchor, constant: -25),
            sellerButton.widthAnchor.constraint(equalToConstant: 25),
            sellerButton.heightAnchor.constraint(equalToConstant: 25)
        ])
        sellerButton.addTarget(self, action: #selector(sellerInfoShow), for: .touchUpInside)
    }
    @objc func sellerInfoShow() {
        let sellerInfo = SellerInfoViewController()
        sellerInfo.sellerID = product?.seller.sellerID
        navigationController?.pushViewController(sellerInfo, animated: true)
    }
    @objc func back() {
        navigationController?.popViewController(animated: true)
    }
    @objc func share() {
        guard let product = product else { return }
        let productDetail = "Product Name: \(product.name)\nPrice: \(product.price)\nDescription: \(product.description)"
        let activityVC = UIActivityViewController(activityItems: [productDetail], applicationActivities: nil)
        present(activityVC, animated: true, completion: nil)
    }
    @objc func goChatPage() {
        let chatVC = ChatViewController()
        chatVC.sellerID = product?.seller.sellerID
        chatVC.buyerID = Auth.auth().currentUser?.uid
        navigationController?.pushViewController(chatVC, animated: true)
    }
    @objc func addCollection() {
        isCollected.toggle()
        guard let currentUserID = Auth.auth().currentUser?.uid,
              let product = product else {
            return
        }
        CollectionManager.shared.toggleCollectionStatus(for: currentUserID, product: product) { success, error in
            if let error = error {
                print("Error updating collection status: \(error)")
            } else {
                print("Collection status updated successfully.")
            }
        }
        if isCollected {
            collectionButton.setImage(UIImage(named: "icons9-bookmark-72(@3×)"), for: .normal)
            addToLocalStorage(productData: product.toDictionary())
        } else {
            collectionButton.setImage(UIImage(named: "icons8-bookmark-72(@3×)"), for: .normal)
            removeFromLocalStorage(productID: product.productId)
        }
    }
    func addToLocalStorage(productData: [String: Any]) {
        var savedCollections = UserDefaults.standard.array(forKey: "SavedCollections") as? [[String: Any]] ?? []
        savedCollections.append(productData)
        UserDefaults.standard.set(savedCollections, forKey: "SavedCollections")
    }
    func removeFromLocalStorage(productID: String) {
        var savedCollections = UserDefaults.standard.array(forKey: "SavedCollections") as? [[String: Any]] ?? []
        savedCollections.removeAll { $0["productId"] as? String == productID }
        UserDefaults.standard.set(savedCollections, forKey: "SavedCollections")
    }
    func showDatePicker() {
        let minDate = DatePickerHelper.shared.dateFrom(day: 18, month: 08, year: 1990)!
        let maxDate = DatePickerHelper.shared.dateFrom(day: 18, month: 08, year: 2030)!
        let today = Date()
        let datePicker = DatePicker()
        datePicker.setup(beginWith: today, min: minDate, max: maxDate) { (selected, date) in
            if selected, let selectedDate = date {
                print(selectedDate.string())
                self.availability.text = selectedDate.string()
            } else {
                print("Cancelled")
            }
        }
        datePicker.show(in: self, on: self.view)
    }
    func loadSavedCollections() {
        let savedCollections = UserDefaults.standard.array(forKey: "SavedCollections") as? [[String: Any]] ?? []
        collectionButton.reloadInputViews()
    }
    @objc func dateImageTapped() {
        showDatePicker()
    }
    @objc func goSelectedPage() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "SelectedViewController") as! SelectedViewController
        if let imageURL = URL(string: product?.imageString ?? ""),
           let startTimeString = availability.text {
            print("startTimeString:", startTimeString)
            let dateFormats = ["MM月 dd, yyyy", "yyyy-MM-dd", "your-other-date-format"]
            for format in dateFormats {
                if DateFormatter.customDateFormat.date(from: startTimeString) != nil {
                    vc.product = product
                    self.navigationController?.pushViewController(vc, animated: true)
                    break
                }
            }
        } else {
            print("Failed to get availability or create image URL")
        }
    }
    @objc func descriptionButtonTapped() {
        UIView.animate(withDuration: 0.5) {
            self.contentDescriptionView.frame.origin.y = 600
            self.descriptionButton.isSelected.toggle()
            if self.descriptionButton.isSelected {
                self.view.addSubview(self.contentDescriptionView)
                self.contentDescriptionView.backgroundColor = .white
                self.contentDescriptionView.layer.cornerRadius = 10
                self.contentDescriptionView.translatesAutoresizingMaskIntoConstraints = false
                self.contentDescriptionView.transform = CGAffineTransform(translationX: 30, y: 560)
                NSLayoutConstraint.activate([
                    self.contentDescriptionView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 600),
                    self.contentDescriptionView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 30),
                    self.contentDescriptionView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -30),
                    self.contentDescriptionView.heightAnchor.constraint(equalToConstant: 150)
                ])
                UIView.animate(withDuration: 0.5) {
                    self.contentDescriptionView.transform = .identity
                }
                self.addDescriptionLabel()
            } else {
                self.removeDescriptionLabel()
                UIView.animate(withDuration: 0.5, animations: {
                    self.contentDescriptionView.transform = CGAffineTransform(translationX: 0, y: -self.contentDescriptionView.frame.height)
                }) { _ in
                    self.contentDescriptionView.removeFromSuperview()
                }
            }
        }
    }
    func addDescriptionLabel() {
        if descriptionLabel2.superview == nil {
            contentDescriptionView.addSubview(descriptionLabel2)
            contentDescriptionView.isScrollEnabled = true
            descriptionLabel2.numberOfLines = 0
            contentDescriptionView.showsVerticalScrollIndicator = true
            contentDescriptionView.showsHorizontalScrollIndicator = true
            descriptionLabel2.text = "\(product?.description ?? "")\n \(product?.sort ?? "")\n \(product?.use ?? "")\n \(product?.endTime ?? "")"
            descriptionLabel2.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                descriptionLabel2.topAnchor.constraint(equalTo: contentDescriptionView.topAnchor, constant: 10),
                descriptionLabel2.leadingAnchor.constraint(equalTo: contentDescriptionView.leadingAnchor, constant: 30),
                descriptionLabel2.trailingAnchor.constraint(equalTo: contentDescriptionView.trailingAnchor, constant: -30)
            ])
            contentDescriptionView.addSubview(sort)
            sort.text = product?.sort
            sort.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                sort.topAnchor.constraint(equalTo: descriptionLabel2.bottomAnchor, constant: 10),
                sort.leadingAnchor.constraint(equalTo: contentDescriptionView.leadingAnchor, constant: 30),
                sort.trailingAnchor.constraint(equalTo: contentDescriptionView.trailingAnchor, constant: -30),
                sort.heightAnchor.constraint(equalToConstant: 20)
            ])
            contentDescriptionView.addSubview(quantity)
            quantity.text = product?.quantity.codingKey.stringValue
            quantity.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                quantity.topAnchor.constraint(equalTo: sort.bottomAnchor, constant: 10),
                quantity.leadingAnchor.constraint(equalTo: contentDescriptionView.leadingAnchor, constant: 30),
                quantity.trailingAnchor.constraint(equalTo: contentDescriptionView.trailingAnchor, constant: -30),
                quantity.heightAnchor.constraint(equalToConstant: 20)
            ])
            contentDescriptionView.addSubview(use)
            use.text = product?.use
            use.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                use.topAnchor.constraint(equalTo: quantity.bottomAnchor, constant: 10),
                use.leadingAnchor.constraint(equalTo: contentDescriptionView.leadingAnchor, constant: 30),
                use.trailingAnchor.constraint(equalTo: contentDescriptionView.trailingAnchor, constant: -30),
                use.heightAnchor.constraint(equalToConstant: 20)
            ])
        } else {
            removeDescriptionLabel()
        }
    }
    func removeDescriptionLabel() {
        descriptionLabel2.removeFromSuperview()
        sort.removeFromSuperview()
        quantity.removeFromSuperview()
        use.removeFromSuperview()
        contentDescriptionView.removeFromSuperview()
    }
}
