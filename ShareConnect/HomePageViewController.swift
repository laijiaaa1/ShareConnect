//
//  ViewController.swift
//  ShareConnect
//
//  Created by laijiaaa1 on 2023/11/14.
//

import UIKit

class HomePageViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {


    let searchTextField = UITextField()
    let view1 = UIView()
    let view2 = UIView()
    let view3 = UIView()
    let view4 = UIView()
    
    let items = [("Camping", "icons8-camp-64"),
                     ("Hiking", "icons8-hiking-64"),
                     ("Fishing", "icons8-fishing-64"),
                     ("Picnic", "icons8-picnic-64"),
                     ("Travel", "icons8-travel-64")]
        
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let textAttributes = [NSAttributedString.Key.font:UIFont(name: "GeezaPro-Bold", size: 20)]

        view.backgroundColor = UIColor(red: 246/255, green: 246/255, blue: 244/255, alpha: 1)
        
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
        
        let views = [view1, view2, view3, view4]
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
        let hotCollection = UICollectionView(frame: CGRect(x: 30, y: 350, width: view.frame.width - 60, height: 150), collectionViewLayout: layout)
        hotCollection.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        hotCollection.backgroundColor = .clear
        hotCollection.delegate = self
        hotCollection.dataSource = self
        view.addSubview(hotCollection)
        
        let line2 = UIView(frame: CGRect(x: 0, y: 540, width: view.frame.width, height: 1))
        line2.backgroundColor = .lightGray
        view.addSubview(line2)

    }
    @objc func buttonClick(sender: UIButton) {
//            switch sender.tag {
//            case 0:
//                let vc = ProductViewController()
//                navigationController?.pushViewController(vc, animated: true)
//            case 1:
//                let vc = PlaceViewController()
//                navigationController?.pushViewController(vc, animated: true)
//            case 2:
//                let vc = CourseViewController()
//                navigationController?.pushViewController(vc, animated: true)
//            case 3:
//                let vc = FoodViewController()
//                navigationController?.pushViewController(vc, animated: true)
//            default:
//                break
//            }
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)

            cell.backgroundColor = .white
            cell.frame = CGRect(x: 0, y: 0, width: 150, height: 150)
            cell.layer.cornerRadius = 10
            cell.layer.masksToBounds = true
            cell.layer.borderWidth = 1

            let imageView = UIImageView(frame: CGRect(x: 25, y: 20, width: 100, height: 100))
            imageView.image = UIImage(named: items[indexPath.row].1)
            cell.addSubview(imageView)

            let label = UILabel(frame: CGRect(x: 0, y: 120, width: 150, height: 20))
            label.text = items[indexPath.row].0
            label.font = UIFont(name: "GeezaPro-Bold", size: 15)
            label.textAlignment = .center
            cell.addSubview(label)
            
            let imageButton = UIButton(frame: CGRect(x: 0, y: 0, width: 150, height: 150))
            imageButton.tag = indexPath.row
            imageButton.addTarget(self, action: #selector(imageButtonClick), for: .touchUpInside)
            cell.addSubview(imageButton)

            return cell
        }
        @objc func imageButtonClick(sender: UIButton) {
            let selectedItem = items[sender.tag]
            print("Selected item: \(selectedItem.0)")
        }
    
}
