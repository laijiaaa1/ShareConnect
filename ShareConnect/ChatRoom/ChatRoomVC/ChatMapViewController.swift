//
//  ChatMapViewController.swift
//  ShareConnect
//
//  Created by laijiaaa1 on 2023/12/2.
//

import UIKit
import CoreLocation
import MapKit

protocol MapSelectionDelegate: AnyObject {
    func didSelectLocation(_ coordinate: CLLocationCoordinate2D)
}
class MapSelectionViewController: UIViewController, MKMapViewDelegate {
    weak var delegate: MapSelectionDelegate?
    var mapView: MKMapView!
    var locationManager: CLLocationManager!
    var searchController: UISearchController!
    var confirmButton: UIButton!
    var returnToUserLocationButton: UIButton!
    var selectedCoordinate: CLLocationCoordinate2D? {
        didSet {
            if let coordinate = selectedCoordinate {
                let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
                mapView.setRegion(region, animated: true)
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView = MKMapView(frame: view.bounds)
        mapView.delegate = self
        view.addSubview(mapView)
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false   // 模糊
        searchController.searchBar.showsCancelButton = false
        navigationItem.searchController = searchController
        definesPresentationContext = true
        view.addSubview(searchController.searchBar)
        view.bringSubviewToFront(searchController.searchBar)
        searchController.searchBar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            searchController.searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchController.searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchController.searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        confirmButton = UIButton(type: .system)
        confirmButton.setTitle("Confirm Location", for: .normal)
        confirmButton.titleLabel?.font = .systemFont(ofSize: 16)
        confirmButton.setTitleColor(.white, for: .normal)
        confirmButton.backgroundColor = .black
        confirmButton.layer.cornerRadius = 10
        confirmButton.addTarget(self, action: #selector(confirmButtonTapped), for: .touchUpInside)
        view.addSubview(confirmButton)
        confirmButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            confirmButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            confirmButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            confirmButton.widthAnchor.constraint(equalToConstant: 180),
            confirmButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        returnToUserLocationButton = UIButton()
        returnToUserLocationButton.setImage(UIImage(systemName: "location.fill"), for: .normal)
        returnToUserLocationButton.backgroundColor = .black
        returnToUserLocationButton.layer.cornerRadius = 10
        returnToUserLocationButton.addTarget(self, action: #selector(returnToUserLocationButtonTapped), for: .touchUpInside)
        view.addSubview(returnToUserLocationButton)
        returnToUserLocationButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            returnToUserLocationButton.topAnchor.constraint(equalTo: confirmButton.topAnchor),
            returnToUserLocationButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            returnToUserLocationButton.widthAnchor.constraint(equalToConstant: 50),
            returnToUserLocationButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        let initialLocation = CLLocationCoordinate2D(latitude: 25.0422, longitude: 121.5354)
        let userLocation = locationManager.location?.coordinate
        // 地圖在初始位置周圍可見的程度
        let regionRadius: CLLocationDistance = 1000
        let coordinateRegion = MKCoordinateRegion(
            center: initialLocation,
            latitudinalMeters: regionRadius,
            longitudinalMeters: regionRadius
        )
        mapView.setRegion(coordinateRegion, animated: true)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        mapView.addGestureRecognizer(tapGesture)
    }
    @objc func returnToUserLocationButtonTapped() {
        if CLLocationManager.locationServicesEnabled() {
            switch locationManager.authorizationStatus {
                // 為選擇時、無權使用定位服務、拒絕應用的位置服務
            case .notDetermined, .restricted, .denied:
                print("Location services disabled")
            case .authorizedAlways, .authorizedWhenInUse:
                locationManagerDidChangeAuthorization(locationManager)
            @unknown default:
                print("Unknown location authorization status.")
            }
        }
    }
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            if let userLocation = manager.location?.coordinate {
                let region = MKCoordinateRegion(center: userLocation, latitudinalMeters: 1000, longitudinalMeters: 1000)
                DispatchQueue.main.async {
                    self.mapView.setRegion(region, animated: true)
                }
            }
        }
    }
    @objc func confirmButtonTapped() {
        if let selectedCoordinate = selectedCoordinate {
            delegate?.didSelectLocation(selectedCoordinate)
            navigationController?.popViewController(animated: true)
        } else {
            print("No location selected.")
        }
    }
    @objc func handleTap(sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            let locationInView = sender.location(in: mapView)
            // 點擊位置轉換為地理座標
            let tappedCoordinate = mapView.convert(locationInView, toCoordinateFrom: mapView)
            let annotation = MKPointAnnotation()
            annotation.coordinate = tappedCoordinate
            // 確保一次只顯示一個大頭針
            mapView.removeAnnotations(mapView.annotations)
            mapView.addAnnotation(annotation)
            selectedCoordinate = tappedCoordinate
        }
    }
}

extension MapSelectionViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last?.coordinate else { return }
        print("Updated Location: \(location.latitude), \(location.longitude)")
        let region = MKCoordinateRegion(center: location, latitudinalMeters: 1000, longitudinalMeters: 1000)
        mapView.setRegion(region, animated: true)
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
    }
}
extension MapSelectionViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text, !searchText.isEmpty else {
            mapView.removeAnnotations(mapView.annotations)
            return
        }
        // 區域設置為地圖的當前可見區域 (MKMapView.region)
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchText
        request.region = mapView.region
        let localSearch = MKLocalSearch(request: request)
        localSearch.start { [weak self] (response, error) in
            guard let self = self else { return }
            if let error = error {
                print("Local search error: \(error.localizedDescription)")
                return
            }
            self.mapView.removeAnnotations(self.mapView.annotations)
            // 迴圈搜尋結果都標上大頭針
            for item in response?.mapItems ?? [] {
                let annotation = MKPointAnnotation()
                annotation.coordinate = item.placemark.coordinate
                annotation.title = item.name
                self.mapView.addAnnotation(annotation)
            }
        }
    }
}
extension MapSelectionViewController {
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let annotation = view.annotation else {
            return
        }
        let alertController = UIAlertController(title: "Location Tapped", message: annotation.title ?? "Unknown", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    // 為每個地圖註記提供檢視，重用大頭針
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "CustomAnnotation"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        // 如果不是nil，則作為新的大頭針
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
        } else {
            annotationView?.annotation = annotation
        }
        return annotationView
    }
}
