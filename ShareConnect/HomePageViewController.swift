//
//  ViewController.swift
//  ShareConnect
//
//  Created by laijiaaa1 on 2023/11/14.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import Kingfisher

struct CustomColors {
    static let B1 = UIColor(red: 246/255, green: 246/255, blue: 244/255, alpha: 1)
}
class HomePageViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    let searchTextField = UITextField()
    let productView = UIView()
    let placeView = UIView()
    let courseView = UIView()
    let foodView = UIView()
    let hotItems = [("Camping", "icons8-camp-64"),
                    ("Hiking", "icons8-camp-64"),
                    ("Fishing", "icons8-camp-64"),
                    ("Picnic", "icons8-camp-64"),
                    ("Travel", "icons8-camp-64")]
    let browsingHistory = UILabel()
    var browsingHistoryItems = [(String, String)]() {
        didSet {
            browsingHistoryCollection.reloadData()
        }
    }
    
    //        ("Camping", "icons8-camp-64"),
    //                                ("Hiking", "icons8-camp-64"),
    //                                ("Fishing", "icons8-camp-64"),
    //                                ("Picnic", "icons8-camp-64"),
    //                                ("Travel", "icons8-camp-64")
    
    let hotCollection = UICollectionView(frame: CGRect(x: 0, y: 0, width: 800, height: 150), collectionViewLayout: UICollectionViewFlowLayout())
    var browsingHistoryCollection = UICollectionView(frame: CGRect(x: 0, y: 0, width: 800, height: 150), collectionViewLayout: UICollectionViewFlowLayout())
    let db = Firestore.firestore()
    override func viewDidLoad() {
        super.viewDidLoad()
        //refresh
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshrefresh), for: .valueChanged)
        hotCollection.refreshControl = refreshControl
        browsingHistoryCollection.refreshControl = refreshControl
        let textAttributes = [NSAttributedString.Key.font:UIFont(name: "GeezaPro-Bold", size: 20)]
        view.backgroundColor = CustomColors.B1
        searchTextField.layer.borderWidth = 1
        searchTextField.layer.cornerRadius = 22
        searchTextField.layer.masksToBounds = true
        searchTextField.frame = CGRect(x: 30, y: 100, width: 330, height: 44)
        let leftView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        let imageView = UIImageView(frame: CGRect(x: 10, y: 10, width: 24, height: 24))
        imageView.image = UIImage(named: "icons8-search-90(@3×)")
        leftView.addSubview(imageView)
        searchTextField.leftView = leftView
        searchTextField.leftViewMode = .always
        let rightView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        let rightImageView = UIImageView(frame: CGRect(x: 10, y: 12, width: 18, height: 18))
        rightImageView.image = UIImage(named: "icons8-filter-48(@3×)")
        rightView.addSubview(rightImageView)
        searchTextField.rightView = rightView
        searchTextField.rightViewMode = .always
        searchTextField.backgroundColor = .white
        view.addSubview(searchTextField)
        let views = [productView, placeView, courseView, foodView]
        let labels = ["Product", "Place", "Course", "Food"]
        let images = ["icons8-camping-tent-72(@3×)", "icons8-room-72(@3×)", "icons8-course-72(@3×)", "icons8-pizza-five-eighths-32"]
        for i in 0..<4 {
            views[i].backgroundColor = .white
            views[i].frame = CGRect(x: 30 + 88 * i, y: 170, width: 70, height: 70)
            views[i].layer.cornerRadius = 10
            views[i].layer.masksToBounds = true
            views[i].layer.borderWidth = 1
            view.addSubview(views[i])
            let imageView = UIImageView(frame: CGRect(x: 15, y: 15, width: 40, height: 40))
            imageView.image = UIImage(named: images[i])
            views[i].addSubview(imageView)
            let label = UILabel(frame: CGRect(x: 30 + 90 * i, y: 250, width: 70, height: 20))
            label.text = labels[i]
            label.font = UIFont(name: "GeezaPro-Bold", size: 15)
            label.textAlignment = .center
            view.addSubview(label)
            let button = UIButton(frame: CGRect(x: 30 + 88 * i, y: 170, width: 70, height: 70))
            button.tag = i
            button.addTarget(self, action: #selector(buttonClick), for: .touchUpInside)
            view.addSubview(button)
        }
        let line = UIView(frame: CGRect(x: 0, y: 280, width: view.frame.width, height: 1))
        line.backgroundColor = .lightGray
        view.addSubview(line)
        let hotCollectionLabel = UILabel(frame: CGRect(x: 30, y: 310, width: 160, height: 20))
        hotCollectionLabel.text = "Hot Collections"
        hotCollectionLabel.font = UIFont(name: "GeezaPro-Bold", size: 18)
        view.addSubview(hotCollectionLabel)
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let scrollView = UIScrollView(frame: CGRect(x: 30, y: 350, width: view.frame.width - 60, height: 150))
        
        view.addSubview(hotCollection)
//        view.addSubview(scrollView)
//        scrollView.addSubview(hotCollection)
        let totalWidth = CGFloat(hotItems.count) * 160
        scrollView.contentSize = CGSize(width: totalWidth, height: hotCollection.frame.height)
        hotCollection.backgroundColor = .clear
        hotCollection.delegate = self
        hotCollection.dataSource = self
        scrollView.showsHorizontalScrollIndicator = false
        hotCollection.showsHorizontalScrollIndicator = false
        let line2 = UIView(frame: CGRect(x: 0, y: 530, width: view.frame.width, height: 1))
        line2.backgroundColor = .lightGray
        view.addSubview(line2)
        browsingHistory.frame = CGRect(x: 30, y: 560, width: 160, height: 20)
        browsingHistory.text = "Browsing History"
        browsingHistory.font = UIFont(name: "GeezaPro-Bold", size: 18)
        view.addSubview(browsingHistory)
        let layout2 = UICollectionViewFlowLayout()
        layout2.scrollDirection = .horizontal
        let scrollView2 = UIScrollView(frame: CGRect(x: 30, y: 600, width: view.frame.width - 60, height: 150))
        view.addSubview(scrollView2)
        let collectionViewWidth = scrollView2.frame.width
        let totalWidth2 = CGFloat(browsingHistoryItems.count) * 320

        self.browsingHistoryCollection = UICollectionView(frame: CGRect(x: 0, y: 0, width: Int(min(collectionViewWidth, totalWidth2)), height: Int(scrollView2.frame.height)), collectionViewLayout: layout2)
      
        view.addSubview(browsingHistoryCollection)

        
//        scrollView2.addSubview(browsingHistoryCollection)
        browsingHistoryCollection.backgroundColor = .clear
        browsingHistoryCollection.delegate = self
        browsingHistoryCollection.dataSource = self
        browsingHistoryCollection.showsHorizontalScrollIndicator = false
        scrollView2.showsHorizontalScrollIndicator = false
        scrollView2.contentSize = CGSize(width: min(collectionViewWidth, totalWidth2), height: browsingHistoryCollection.frame.height)

//        hotCollection.register(HistoryCell.self, forCellWithReuseIdentifier: "hotHistoryCell")
        browsingHistoryCollection.register(HistoryCell.self, forCellWithReuseIdentifier: "cell")

        
        listenForBrowsingHistory()
    }
    @objc func refreshrefresh() {
        self.browsingHistoryCollection.reloadData()
        self.hotCollection.reloadData()
        
    }
    func listenForBrowsingHistory() {
        FirestoreService.shared.listenForBrowsingHistoryChanges { [weak self] browsingRecords in
            DispatchQueue.main.async {
                self?.browsingHistoryItems = browsingRecords.map { ($0.name, $0.image) }
                self?.browsingHistoryCollection.reloadData()
            }
        }
    }

    
    @objc func buttonClick(sender: UIButton) {
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        if hotCollection.isEqual(collectionView) {
//            return hotItems.count
//        } else if browsingHistoryCollection.isEqual(collectionView){
            return browsingHistoryItems.count
//        }
//        return 2
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        if collectionView == hotCollection {
//         let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "hotHistoryCell", for: indexPath) as? HistoryCell
//        }
//        else if collectionView == browsingHistoryCollection {
         let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? HistoryCell ?? HistoryCell()
        cell.item = browsingHistoryItems[indexPath.row]
        cell.label.text = browsingHistoryItems[indexPath.row].0
        cell.imageView.kf.setImage(with: URL(string: browsingHistoryItems[indexPath.row].1))
      
        
            return cell ?? UICollectionViewCell()
        
//        }
//        return UICollectionViewCell()
    }

    @objc func imageButtonClick(sender: UIButton) {
        if sender.superview == hotCollection {
            let selectedItem = hotItems[sender.tag]
            print("Selected item from Hot Collection: \(selectedItem.0)")
        } else if sender.superview == browsingHistoryCollection {
            let selectedItem = browsingHistoryItems[sender.tag]
            print("Selected item from Browsing History: \(selectedItem.0)")
        }
    }
}

class HistoryCell: UICollectionViewCell{
  
    var item: (String, String)! {
       didSet {
         label.text = item.0
           
       }
     }
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.kf.setImage(with: URL(string: "https://i.imgur.com/2X2f4Ym.jpg"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    let label: UILabel = {
        let label = UILabel()
        label.text = "1"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "GeezaPro-Bold", size: 15)
        label.textAlignment = .center
        return label
    }()
    let imageButton: UIButton = {
        let imageButton = UIButton()
        imageButton.translatesAutoresizingMaskIntoConstraints = false
        return imageButton
    }()
    func setupViews() {
        addSubview(imageView)
        addSubview(label)
        addSubview(imageButton)
        imageView.topAnchor.constraint(equalTo: topAnchor, constant: 20).isActive = true
        imageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 25).isActive = true
        imageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -25).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 150).isActive = true
        label.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 0).isActive = true
        label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0).isActive = true
        label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0).isActive = true
        label.heightAnchor.constraint(equalToConstant: 20).isActive = true
        imageButton.topAnchor.constraint(equalTo: topAnchor, constant: 0).isActive = true
        imageButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0).isActive = true
        imageButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0).isActive = true
        imageButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0).isActive = true
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
