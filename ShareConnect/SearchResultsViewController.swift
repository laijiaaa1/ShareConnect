import UIKit
import Firebase
import FirebaseFirestore
import FirebaseAuth
import FirebaseCore
import FirebaseStorage
import MJRefresh
import Kingfisher

class SearchResultsViewController: SearchViewController{
    var searchResults: [Product] = []
    var products: [Product] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Search Results"
    }
    // MARK: - UICollectionViewDataSource
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndexPath = indexPath
        if collectionView == classCollectionView {
            let cell = collectionView.cellForItem(at: indexPath) as? ClassCollectionViewCell
            cell?.updateUI()
        }
        if collectionView == self.collectionView {
            if let cell = collectionView.cellForItem(at: indexPath) as? SearchCollectionViewCell {
                guard let name = cell.product?.name else { return }
                let image = cell.product?.imageString ?? ""
                let price = cell.product?.price ?? ""
                let type = cell.product?.itemType ?? .request
                let productId = cell.product?.productId ?? ""
                FirestoreService.shared.addBrowsingRecord(name: name, image: image, price: price, type: type.rawValue, productId: productId)
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "ProvideViewController") as! ProvideViewController
                let deVC = storyboard.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
                vc.product = cell.product
                deVC.product = cell.product
                if currentButtonType == .request {
                    self.navigationController?.pushViewController(vc, animated: true)
                } else if currentButtonType == .supply{
                    self.navigationController?.pushViewController(deVC, animated: true)
                }
            }
        }
    }
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == classCollectionView {
            return 1
        }
        if collectionView == collectionView {
            if currentButtonType == .request {
                return searchResults.count
            } else if currentButtonType == .supply {
                return searchResults.count
            }
            return 0
        }
        return 0
    }
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == classCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "classCell", for: indexPath) as! ClassCollectionViewCell
            cell.currentButtonType = currentButtonType
            cell.delegate = self
            cell.updateUI()
            return cell
        }
        if collectionView == collectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! SearchCollectionViewCell
            if currentButtonType == .request {
                cell.product = searchResults[indexPath.item]
            } else if currentButtonType == .supply {
                cell.product = searchResults[indexPath.item]
            }
            return cell
        }
        return UICollectionViewCell()
    }
}
