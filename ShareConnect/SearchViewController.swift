//
//  SearchViewController.swift
//  ShareConnect
//
//  Created by laijiaaa1 on 2023/11/16.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseAuth
import FirebaseCore
import FirebaseStorage
import MJRefresh
import Kingfisher

class SearchViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allRequests.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! SearchCollectionViewCell
        let cellWidth = collectionView.frame.width / 2
        let cellHeight = collectionView.frame.height / 2
        let xPosition = CGFloat(indexPath.item % 2) * cellWidth
        let yPosition = CGFloat(indexPath.item / 2) * cellHeight
        
        cell.frame = CGRect(x: xPosition, y: yPosition, width: cellWidth, height: cellHeight)
        if indexPath.item < allRequests.count {
            cell.request = allRequests[indexPath.item]
        } else {
            cell.request = nil
        }
        
        //select cell to show detail
        cell.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tap(_:))))
        return cell
    }
    @objc func tap(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: self.collectionView)
        let indexPath = self.collectionView.indexPathForItem(at: location)
        if let index = indexPath {
            let cell = self.collectionView.cellForItem(at: index) as! SearchCollectionViewCell
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
//            vc.request = cell.request
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    var allRequests: [RequestData] = []
    
    let scrollView = UIScrollView()
    let stackView = UIStackView()
    let lineView = UIView()
    let button1 = UIButton()
    let button2 = UIButton()
    let buttonClassification = UIButton()
    
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(SearchCollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.backgroundColor = .white
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    override func viewDidLoad() {
        view.backgroundColor = CustomColors.B1
        super.viewDidLoad()
        setupUI()
        navigationItem.title = "SHARECONNECT"
        collectionView.delegate = self
        collectionView.dataSource = self
        let userID = Auth.auth().currentUser?.uid ?? ""
        fetchRequestsForUser(userID: userID)
        collectionView.refreshControl = UIRefreshControl()
        collectionView.refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
        
    }
    @objc func refresh() {
        let userID = Auth.auth().currentUser?.uid ?? ""
        fetchRequestsForUser(userID: userID)
        collectionView.reloadData()
        collectionView.refreshControl?.endRefreshing()
    }
    func setupUI() {
        
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
//        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stackView.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        button1.setTitle("Request", for: .normal)
        button1.setTitleColor(.black, for: .normal)
        button1.layer.borderWidth = 1
        button1.addTarget(self, action: #selector(button1Action), for: .touchUpInside)
        
        button2.setTitle("Available", for: .normal)
        button2.setTitleColor(.black, for: .normal)
        button2.layer.borderWidth = 1
        button2.addTarget(self, action: #selector(button2Action), for: .touchUpInside)
        
        stackView.addArrangedSubview(button1)
        stackView.addArrangedSubview(button2)
        
        lineView.backgroundColor = .black
        lineView.translatesAutoresizingMaskIntoConstraints = false
        lineView.center.x = button1.center.x
        view.addSubview(lineView)
        NSLayoutConstraint.activate([
            lineView.topAnchor.constraint(equalTo: stackView.bottomAnchor),
            lineView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            lineView.widthAnchor.constraint(equalToConstant: view.frame.width / 2),
            lineView.heightAnchor.constraint(equalToConstant: 2)
        ])
        
        buttonClassification.backgroundColor = .white
        buttonClassification.translatesAutoresizingMaskIntoConstraints = false
        buttonClassification.layer.borderWidth = 1
        buttonClassification.layer.cornerRadius = 20
        buttonClassification.setTitle("Class", for: .normal)
        buttonClassification.setTitleColor(.black, for: .normal)
        view.addSubview(buttonClassification)
        NSLayoutConstraint.activate([
            buttonClassification.topAnchor.constraint(equalTo: lineView.bottomAnchor, constant: 10),
            buttonClassification.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            buttonClassification.widthAnchor.constraint(equalToConstant: 60),
            buttonClassification.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        view.addSubview(collectionView)
        collectionView.backgroundColor = CustomColors.B1
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: buttonClassification.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        scrollView.contentSize = CGSize(width: view.frame.width, height: lineView.frame.origin.y + collectionView.frame.height)
    }
    @objc func button1Action() {
        UIView.animate(withDuration: 0.3) {
            self.lineView.frame.origin.x = 0
        }
        
        let userID = Auth.auth().currentUser?.uid ?? ""
        fetchRequestsForUser(userID: userID)
    }

    @objc func button2Action() {
        UIView.animate(withDuration: 0.3) {
            self.lineView.frame.origin.x = self.view.frame.width / 2
        }
        let userID = Auth.auth().currentUser?.uid ?? ""
        fetchRequestsForUser(userID: userID)
    }

    func fetchRequestsForUser(userID: String) {
        let db = Firestore.firestore()
        
        print("Current user UID: \(userID)")
      
        var collectionName = "request"
        if lineView.frame.origin.x == view.frame.width / 2 {
            collectionName = "supply"
        }

        guard !collectionName.isEmpty else {
            print("Error: Collection name is empty")
            return
        }

        
        db.collection("users").document(userID).collection(collectionName).getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                self.allRequests = []
                print("Number of documents: \(querySnapshot?.documents.count ?? 0)")
                
                for document in querySnapshot!.documents {
                    let requestData = document.data()
                    print("Document data: \(requestData)")
                    
                    if let name = requestData["Name"] as? String,
                       let price = requestData["Price"] as? String,
                       let startTime = requestData["Start Time"] as? String,
                       let imageString = requestData["image"] as? String,
                       let date = DateFormatter.iso8601Full.date(from: startTime) {
                        
                        let request = RequestData(name: name, price: price, date: date, imageString: imageString)
                        self.allRequests.append(request)
                    }
                }
                
                print("Number of requests: \(self.allRequests.count)")
                
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            }
        }
    }
    
}

class SearchCollectionViewCell: UICollectionViewCell {
    let underView = UIView()
    let imageView = UIImageView()
    let priceLabel = UILabel()
    let button = UIButton()
    let dateLabel = UILabel()
    let nameLabel = UILabel()
    let collectionButton = UIButton()
    
    var request: RequestData? {
        didSet {
            print("Request didSet")
            updateUI()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func setupUI(){
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .yellow
        imageView.layer.cornerRadius = 10
        contentView.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            imageView.widthAnchor.constraint(equalTo: contentView.widthAnchor, constant: -20),
            imageView.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.6)
        ])
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.text = "Name"
        nameLabel.font = UIFont.systemFont(ofSize: 12)
        contentView.addSubview(nameLabel)
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 15),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            nameLabel.widthAnchor.constraint(equalToConstant: contentView.frame.width),
            nameLabel.heightAnchor.constraint(equalToConstant: 15)
        ])
        
        priceLabel.translatesAutoresizingMaskIntoConstraints = false
        priceLabel.text = "$ 0.00"
        priceLabel.font = UIFont.systemFont(ofSize: 12)
        contentView.addSubview(priceLabel)
        NSLayoutConstraint.activate([
            priceLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 15),
            priceLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            priceLabel.widthAnchor.constraint(equalToConstant: contentView.frame.width),
            priceLabel.heightAnchor.constraint(equalToConstant: 15)
        ])
        
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.text = "Date"
        dateLabel.font = UIFont.systemFont(ofSize: 12)
        contentView.addSubview(dateLabel)
        NSLayoutConstraint.activate([
            dateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            dateLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 15),
            dateLabel.heightAnchor.constraint(equalToConstant: 15)
        ])
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Provide", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        button.backgroundColor = .white
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 10
        contentView.addSubview(button)
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: priceLabel.bottomAnchor, constant: 15),
            button.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            button.heightAnchor.constraint(equalToConstant: 30),
            button.widthAnchor.constraint(equalToConstant: 100)
        ])
        button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
    }
    @objc func buttonAction(sender: UIButton!) {
       let storyboard = UIStoryboard(name: "Main", bundle: nil)
         let vc = storyboard.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
//          vc.request = request
          vc.modalPresentationStyle = .fullScreen
          self.window?.rootViewController?.present(vc, animated: true, completion: nil)
    }
    func updateUI() {
        if let request = request {
            nameLabel.text = request.name
            priceLabel.text = "$\(request.price)"
            dateLabel.text = DateFormatter.localizedString(from: request.date, dateStyle: .short, timeStyle: .short)
            
            if let url = URL(string: request.imageString) {
                imageView.kf.setImage(with: url)
            }
        }
    }
}
struct RequestData {
    let name: String
    let price: String
    let date: Date
    let imageString: String
}
extension DateFormatter {
    static let iso8601Full: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }()
}
