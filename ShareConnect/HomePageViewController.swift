//
//  ViewController.swift
//  ShareConnect
//
//  Created by laijiaaa1 on 2023/11/14.
//

import UIKit

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
    let browsingHistoryItems = [("Camping", "icons8-camp-64"),
                                ("Hiking", "icons8-camp-64"),
                                ("Fishing", "icons8-camp-64"),
                                ("Picnic", "icons8-camp-64"),
                                ("Travel", "icons8-camp-64")]
    
    let hotCollection = UICollectionView(frame: CGRect(x: 0, y: 0, width: 800, height: 150), collectionViewLayout: UICollectionViewFlowLayout())
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        view.addSubview(scrollView)
        
        scrollView.addSubview(hotCollection)
        
        let totalWidth = CGFloat(hotItems.count) * 160
        scrollView.contentSize = CGSize(width: totalWidth, height: hotCollection.frame.height)
        
        hotCollection.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
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
        let browsingHistoryCollection = UICollectionView(frame: CGRect(x: 0, y: 0, width: browsingHistoryItems.count * 320, height: Int(scrollView2.frame.height)), collectionViewLayout: layout2)
        scrollView2.addSubview(browsingHistoryCollection)
        browsingHistoryCollection.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        
        browsingHistoryCollection.backgroundColor = .clear
        browsingHistoryCollection.delegate = self
        browsingHistoryCollection.dataSource = self
        browsingHistoryCollection.showsHorizontalScrollIndicator = false
        scrollView2.showsHorizontalScrollIndicator = false
        let totalWidth2 = CGFloat(browsingHistoryItems.count) * 320
        scrollView2.contentSize = CGSize(width: totalWidth2, height: browsingHistoryCollection.frame.height)
        
    }
    @objc func buttonClick(sender: UIButton) {

    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == hotCollection {
            return hotItems.count
        } else {
            return browsingHistoryItems.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        
        cell.backgroundColor = .white
        cell.layer.cornerRadius = 10
        cell.layer.masksToBounds = true
        cell.layer.borderWidth = 1
        
        if collectionView == hotCollection {
            let xpoint = CGFloat(indexPath.item) * 160
            cell.frame = CGRect(x: xpoint, y: 0, width: 150, height: 150)
            
            let imageView = UIImageView(frame: CGRect(x: 25, y: 20, width: 100, height: 100))
            imageView.image = UIImage(named: hotItems[indexPath.row].1)
            cell.addSubview(imageView)
            
            let label = UILabel(frame: CGRect(x: 0, y: 120, width: 150, height: 20))
            label.text = hotItems[indexPath.row].0
            label.font = UIFont(name: "GeezaPro-Bold", size: 15)
            label.textAlignment = .center
            cell.addSubview(label)
            
            let imageButton = UIButton(frame: CGRect(x: 0, y: 0, width: 150, height: 150))
            imageButton.tag = indexPath.row
            imageButton.addTarget(self, action: #selector(imageButtonClick), for: .touchUpInside)
            cell.addSubview(imageButton)
        } else {
            let xpoint = CGFloat(indexPath.item) * 320
            cell.frame = CGRect(x: xpoint, y: 0, width: 150, height: 150)
            
            var view = UIView()
            let viewPoint = CGFloat(indexPath.item) * 320
            view.frame = CGRect(x: 20+viewPoint, y: 35, width: 80, height: 80)
            view.layer.cornerRadius = 10
            view.layer.borderWidth = 1
            
            collectionView.addSubview(view)
            let historyXpoint = CGFloat(indexPath.item) * 320
            cell.frame = CGRect(x: historyXpoint, y: 0, width: 310, height: 150)
            let imageView = UIImageView(frame: CGRect(x: 10, y: 10, width: 60, height: 60))
            imageView.image = UIImage(named: browsingHistoryItems[indexPath.row].1)
            view.addSubview(imageView)
            
            let label = UILabel(frame: CGRect(x: 80, y: 50, width: 150, height: 20))
            label.text = browsingHistoryItems[indexPath.row].0
            label.font = UIFont(name: "GeezaPro-Bold", size: 15)
            label.textAlignment = .center
            cell.addSubview(label)
            
            let imageButton = UIButton(frame: CGRect(x: 230, y: 80, width: 60, height: 30))
            
            imageButton.setTitle("Detail", for: .normal)
            imageButton.setTitleColor(.black, for: .normal)
            imageButton.layer.cornerRadius = 10
            imageButton.layer.borderWidth = 1
            imageButton.titleLabel?.font = UIFont(name: "GeezaPro-Bold", size: 15)
          
            imageButton.tag = indexPath.row
            imageButton.addTarget(self, action: #selector(imageButtonClick), for: .touchUpInside)
            cell.addSubview(imageButton)
            
        }
        return cell
    }
    @objc func imageButtonClick(sender: UIButton) {
        let selectedItem = hotItems[sender.tag]
        print("Selected item: \(selectedItem.0)")
    }
    
}
