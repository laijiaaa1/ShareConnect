//
//  ChatMapViewController.swift
//  ShareConnect
//
//  Created by laijiaaa1 on 2023/12/2.
//

import UIKit
import CoreLocation
import MapKit

class MapSelectionViewController: UIViewController, MKMapViewDelegate {

    weak var delegate: MapSelectionDelegate?
    var mapView: MKMapView!
    var locationManager: CLLocationManager!
    var searchController: UISearchController!
    var confirmButton: UIButton!
    var selectedCoordinate: CLLocationCoordinate2D? {
           didSet {
               if let coordinate = selectedCoordinate {
                   // Update the map region to the selected coordinate
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
        searchController.obscuresBackgroundDuringPresentation = false
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
        confirmButton.addTarget(self, action: #selector(confirmButtonTapped), for: .touchUpInside)
        view.addSubview(confirmButton)

        confirmButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            confirmButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            confirmButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])

        let initialLocation = CLLocationCoordinate2D(latitude: 25.0422, longitude: 121.5354)  // Taipei coordinates
        let regionRadius: CLLocationDistance = 1000
        let coordinateRegion = MKCoordinateRegion(
            center: initialLocation,
            latitudinalMeters: regionRadius,
            longitudinalMeters: regionRadius
        )
        mapView.setRegion(coordinateRegion, animated: true)

        // Add a long press gesture recognizer to add a custom annotation
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        mapView.addGestureRecognizer(longPressGesture)
    }

    @objc func confirmButtonTapped() {
        if let selectedCoordinate = selectedCoordinate {
            delegate?.didSelectLocation(selectedCoordinate)
            dismiss(animated: true, completion: nil)
        } else {
            print("No location selected.")
        }
    }
    @objc func handleLongPress(sender: UILongPressGestureRecognizer) {
            if sender.state == .began {
                let locationInView = sender.location(in: mapView)
                let tappedCoordinate = mapView.convert(locationInView, toCoordinateFrom: mapView)
                
                // Add a custom annotation with coordinates
                let annotation = MKPointAnnotation()
                annotation.coordinate = tappedCoordinate
                mapView.addAnnotation(annotation)
                
                // Save the selected coordinates
                selectedCoordinate = tappedCoordinate
                
                // Display information about the tapped location
                let alertController = UIAlertController(
                    title: "Location Tapped",
                    message: "Coordinates: \(tappedCoordinate.latitude), \(tappedCoordinate.longitude)",
                    preferredStyle: .alert
                )
                alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                present(alertController, animated: true, completion: nil)
            }
        }
}
protocol MapSelectionDelegate: AnyObject {
    func didSelectLocation(_ coordinate: CLLocationCoordinate2D)
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
        
        // Display information about the tapped location
        let alertController = UIAlertController(title: "Location Tapped", message: annotation.title ?? "Unknown", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
          let identifier = "CustomAnnotation"
          var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
          if annotationView == nil {
              annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
              annotationView?.canShowCallout = true
          } else {
              annotationView?.annotation = annotation
          }
          return annotationView
      }
}

